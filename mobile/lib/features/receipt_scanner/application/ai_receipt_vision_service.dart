import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/config/env_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/secure_storage_service.dart';
import '../domain/ocr_extraction_result.dart';

class AiVisionScanOutcome {
  const AiVisionScanOutcome({
    this.result,
    required this.providerCode,
    this.fallbackUsed = false,
    this.diagnosticMessage,
  });

  final OcrExtractionResult? result;
  final String providerCode;
  final bool fallbackUsed;
  final String? diagnosticMessage;

  bool get hasExtraction => result != null;
}

class AiReceiptVisionService {
  AiReceiptVisionService({
    required this.envConfig,
    required this.secureStorage,
    required this.apiClient,
    Dio? externalDio,
  }) : _externalDio = externalDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 25),
              ),
            );

  final EnvConfig envConfig;
  final SecureStorageService secureStorage;
  final ApiClient apiClient;
  final Dio _externalDio;

  Future<({String geminiKey, String groqKey})> resolveEffectiveKeys() async {
    final storedGemini = (await secureStorage.getGeminiApiKey())?.trim() ?? '';
    final storedGroq = (await secureStorage.getGroqApiKey())?.trim() ?? '';

    return (
      geminiKey:
          storedGemini.isNotEmpty ? storedGemini : envConfig.geminiApiKey.trim(),
      groqKey: storedGroq.isNotEmpty ? storedGroq : envConfig.groqApiKey.trim(),
    );
  }

  Future<({bool hasGeminiKey, bool hasGroqKey})> getConfiguredKeyStatus() async {
    final keys = await resolveEffectiveKeys();
    return (
      hasGeminiKey: keys.geminiKey.isNotEmpty,
      hasGroqKey: keys.groqKey.isNotEmpty,
    );
  }

  Future<AiVisionScanOutcome> scanReceiptImage({
    required File imageFile,
    required List<String> categoryNames,
    required bool isCloudAuthenticated,
  }) async {
    final bytes = await imageFile.readAsBytes();
    return scanReceiptBytes(
      bytes: bytes,
      fileNameHint: imageFile.path,
      categoryNames: categoryNames,
      isCloudAuthenticated: isCloudAuthenticated,
    );
  }

  Future<AiVisionScanOutcome> scanReceiptBytes({
    required Uint8List bytes,
    String fileNameHint = 'struk.jpg',
    required List<String> categoryNames,
    required bool isCloudAuthenticated,
  }) async {
    if (bytes.isEmpty) {
      return const AiVisionScanOutcome(
        providerCode: 'failed',
        diagnosticMessage: 'File gambar struk kosong atau rusak.',
      );
    }

    if (bytes.length > envConfig.maxReceiptSizeBytes) {
      return const AiVisionScanOutcome(
        providerCode: 'failed',
        diagnosticMessage: 'Ukuran gambar melebihi batas maksimal 5 MB.',
      );
    }

    final mimeType = detectImageMimeType(bytes, fileNameHint);
    final base64Image = base64Encode(bytes);
    final prompt = buildExtractionPrompt(categoryNames);
    final keys = await resolveEffectiveKeys();

    final errors = <String>[];
    var geminiAttempted = false;

    if (keys.geminiKey.isNotEmpty) {
      geminiAttempted = true;
      try {
        final rawPayload = await _callGemini(
          apiKey: keys.geminiKey,
          mimeType: mimeType,
          base64Image: base64Image,
          prompt: prompt,
        );
        final parsed = parseAiJsonPayload(
          rawPayload,
          providerLabel: 'Pemindai Cerdas',
          fallbackUsed: false,
        );
        if (parsed != null) {
          return AiVisionScanOutcome(
            result: parsed,
            providerCode: 'gemini',
            fallbackUsed: false,
          );
        }
        errors.add('Gemini mengembalikan format tidak terbaca');
      } on DioException catch (e) {
        errors.add('Gemini (${_extractDioReason(e)})');
      } catch (e) {
        errors.add('Gemini ($e)');
      }
    }

    if (keys.groqKey.isNotEmpty) {
      try {
        final rawPayload = await _callGroq(
          apiKey: keys.groqKey,
          mimeType: mimeType,
          base64Image: base64Image,
          prompt: prompt,
        );
        final parsed = parseAiJsonPayload(
          rawPayload,
          providerLabel: 'Pemindai Cerdas',
          fallbackUsed: geminiAttempted,
        );
        if (parsed != null) {
          return AiVisionScanOutcome(
            result: parsed,
            providerCode: 'groq',
            fallbackUsed: geminiAttempted,
          );
        }
        errors.add('Groq mengembalikan format tidak terbaca');
      } on DioException catch (e) {
        errors.add('Groq (${_extractDioReason(e)})');
      } catch (e) {
        errors.add('Groq ($e)');
      }
    }

    if (isCloudAuthenticated) {
      try {
        final ext = switch (mimeType) {
          'image/png' => 'png',
          'image/webp' => 'webp',
          _ => 'jpg',
        };
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.$ext',
          ),
        });
        for (final cat in categoryNames.take(50)) {
          final trimmed = cat.trim();
          if (trimmed.isNotEmpty) {
            formData.fields.add(MapEntry('categories[]', trimmed));
          }
        }

        final res = await apiClient.postMultipart<Map<String, dynamic>>(
          '/receipts/scan-ai',
          formData: formData,
          parseData: (raw) => Map<String, dynamic>.from(raw as Map),
        );

        final data = res.data;
        if (data != null) {
          final backendProvider =
              (data['provider'] ?? 'gemini').toString().toLowerCase();
          final backendFallback = data['fallback_used'] == true;
          final lineItems = (data['line_items'] as List? ?? const [])
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList();

          final result = OcrExtractionResult(
            rawText: (data['raw_text'] ?? '').toString(),
            merchantName: _nullableString(data['merchant_name']),
            detectedAmount: parseAmountDynamic(data['detected_amount']),
            detectedDate: parseDateDynamic(data['detected_date']),
            lineItems: lineItems,
            suggestedCategory: _nullableString(data['suggested_category']),
            providerLabel: 'Pemindai Cerdas',
            fallbackUsed: backendFallback,
          );
          return AiVisionScanOutcome(
            result: result,
            providerCode: 'backend_$backendProvider',
            fallbackUsed: backendFallback,
          );
        }
      } catch (e) {
        errors.add('Server ($e)');
      }
    }

    if (keys.geminiKey.isEmpty && keys.groqKey.isEmpty && !isCloudAuthenticated) {
      return const AiVisionScanOutcome(
        providerCode: 'none',
      );
    }

    return const AiVisionScanOutcome(
      providerCode: 'failed',
    );
  }

  Future<String> _callGemini({
    required String apiKey,
    required String mimeType,
    required String base64Image,
    required String prompt,
  }) async {
    final model = Uri.encodeComponent(envConfig.geminiModel);
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';

    final response = await _externalDio.post<Map<String, dynamic>>(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
      ),
      data: {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'responseMimeType': 'application/json',
        },
      },
    );

    final body = response.data;
    final candidates = body?['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final first = candidates.first;
      if (first is Map) {
        final content = first['content'];
        if (content is Map) {
          final parts = content['parts'];
          if (parts is List && parts.isNotEmpty) {
            final text = (parts.first as Map)['text']?.toString() ?? '';
            if (text.trim().isNotEmpty) return text;
          }
        }
      }
    }
    throw const FormatException('Respon Gemini kosong.');
  }

  Future<String> _callGroq({
    required String apiKey,
    required String mimeType,
    required String base64Image,
    required String prompt,
  }) async {
    const url = 'https://api.groq.com/openai/v1/chat/completions';

    final response = await _externalDio.post<Map<String, dynamic>>(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': envConfig.groqVisionModel,
        'temperature': 0.1,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
      },
    );

    final body = response.data;
    final choices = body?['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = (choices.first as Map)['message'];
      if (message is Map) {
        final content = message['content']?.toString() ?? '';
        if (content.trim().isNotEmpty) return content;
      }
    }
    throw const FormatException('Respon Groq kosong.');
  }

  static String buildExtractionPrompt(List<String> categoryNames) {
    final cleaned = categoryNames
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    final catPrompt = cleaned.isNotEmpty
        ? 'Pilih suggested_category paling cocok dari daftar berikut: ${cleaned.join(', ')}.'
        : 'Pilih suggested_category singkat berbahasa Indonesia (contoh: Makanan, Belanja, Transportasi, Kesehatan, Tagihan, Hiburan, Lainnya).';

    return '''
Kamu adalah AI pembaca nota/struk belanja Indonesia & internasional yang sangat akurat.
Ekstrak informasi dari foto struk ini ke JSON valid dengan struktur PERSIS berikut:
{
  "merchant_name": "string nama toko/merchant/restoran atau null",
  "total_amount": 0,
  "transaction_date": "YYYY-MM-DD HH:MM:SS atau YYYY-MM-DD atau null",
  "suggested_category": "string kategori pengeluaran atau null",
  "line_items": ["string ringkas item dan harganya, maksimal 15 item"],
  "raw_text": "string ringkasan transkrip teks utama struk"
}
Aturan:
1. Untuk struk Indonesia seperti Rp 25.000 atau 25.000,00 -> total_amount harus integer 25000 (abaikan ,00/.00 desimal di akhir).
2. Utamakan GRAND TOTAL / TOTAL BAYAR / TOTAL TAGIHAN / TOTAL BELANJA. Jangan ambil uang Tunai/Cash atau Kembalian.
3. $catPrompt
''';
  }

  static OcrExtractionResult? parseAiJsonPayload(
    String rawResponseText, {
    required String providerLabel,
    bool fallbackUsed = false,
  }) {
    final decoded = decodeJsonObject(rawResponseText);
    if (decoded == null) return null;

    final merchant = _nullableString(decoded['merchant_name']);
    final amount = parseAmountDynamic(
      decoded['total_amount'] ?? decoded['detected_amount'],
    );
    final date = parseDateDynamic(
      decoded['transaction_date'] ?? decoded['detected_date'],
    );
    final suggestedCategory = _nullableString(decoded['suggested_category']);

    final lineItems = <String>[];
    final rawItems = decoded['line_items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        final str = item.toString().trim();
        if (str.isNotEmpty) {
          lineItems.add(str);
        }
        if (lineItems.length >= 20) break;
      }
    }

    var rawText = (decoded['raw_text'] ?? '').toString().trim();
    if (rawText.isEmpty) {
      final parts = <String>[
        ?merchant,
        if (date != null) date.toIso8601String(),
        ...lineItems,
        if (amount != null) 'TOTAL Rp $amount',
      ];
      rawText = parts.join('\n');
    }

    if (merchant == null && amount == null && lineItems.isEmpty && rawText.isEmpty) {
      return null;
    }

    return OcrExtractionResult(
      rawText: rawText,
      merchantName: merchant,
      detectedAmount: amount,
      detectedDate: date,
      lineItems: lineItems,
      suggestedCategory: suggestedCategory,
      providerLabel: providerLabel,
      fallbackUsed: fallbackUsed,
    );
  }

  static Map<String, dynamic>? decodeJsonObject(String rawText) {
    var trimmed = rawText.trim();
    if (trimmed.isEmpty) return null;

    final fenceMatch =
        RegExp(r'```(?:json)?\s*([\s\S]*?)```', caseSensitive: false)
            .firstMatch(trimmed);
    if (fenceMatch != null) {
      trimmed = (fenceMatch.group(1) ?? '').trim();
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      final first = trimmed.indexOf('{');
      final last = trimmed.lastIndexOf('}');
      if (first != -1 && last > first) {
        try {
          final slice = trimmed.substring(first, last + 1);
          final decoded = jsonDecode(slice);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }
    }
    return null;
  }

  static int? parseAmountDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is double) {
      final rounded = value.round();
      return rounded > 0 ? rounded : null;
    }

    var clean = value.toString().trim().replaceAll(RegExp(r'[^0-9.,]'), '');
    if (clean.isEmpty) return null;

    if (RegExp(r'[.,]\d{2}$').hasMatch(clean) &&
        !RegExp(r'^\d+[.,]\d{3}$').hasMatch(clean)) {
      clean = clean.substring(0, clean.length - 3);
    }

    final digits = clean.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final amount = int.tryParse(digits);
    return (amount != null && amount > 0) ? amount : null;
  }

  static DateTime? parseDateDynamic(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    final iso = DateTime.tryParse(text.replaceAll(' ', 'T'));
    if (iso != null) return iso;

    final dmy = RegExp(
      r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})(?:\s+(\d{1,2}):(\d{2}))?',
    ).firstMatch(text);
    if (dmy != null) {
      final day = int.parse(dmy.group(1)!);
      final month = int.parse(dmy.group(2)!);
      var year = int.parse(dmy.group(3)!);
      if (year < 100) year += 2000;
      final hour = dmy.group(4) != null ? int.parse(dmy.group(4)!) : 12;
      final minute = dmy.group(5) != null ? int.parse(dmy.group(5)!) : 0;
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day, hour.clamp(0, 23), minute.clamp(0, 59));
      }
    }
    return null;
  }

  static String detectImageMimeType(Uint8List bytes, String filePath) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return null;
    return str;
  }

  String _extractDioReason(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? apiMsg;
    if (data is Map && data['error'] is Map) {
      apiMsg = (data['error'] as Map)['message']?.toString();
    } else if (data is Map && data['message'] is String) {
      apiMsg = data['message'] as String;
    }
    if (status != null) {
      return apiMsg != null && apiMsg.isNotEmpty
          ? 'HTTP $status: $apiMsg'
          : 'HTTP $status';
    }
    return e.type.name;
  }
}
