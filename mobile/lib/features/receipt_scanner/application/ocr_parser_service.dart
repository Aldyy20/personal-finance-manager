import '../domain/ocr_extraction_result.dart';

class OcrParserService {
  const OcrParserService();

  static const List<({String title, String fileName, String rawText})> sampleReceipts = [
    (
      title: 'Struk Minimarket',
      fileName: 'struk_minimarket.jpg',
      rawText: 'INDOMARET SUDIRMAN\n21/11/2026 14:25\nAir Mineral 600ml 4.500\nRoti Tawar 18.500\nKopi Susu 12.000\nTOTAL Rp 35.000\nTUNAI 50.000\nKEMBALI 15.000',
    ),
    (
      title: 'Struk Restoran',
      fileName: 'struk_restoran.jpg',
      rawText: 'WARUNG NUSANTARA\nTanggal: 2026-11-20\nNasi Goreng Spesial Rp 45.000\nEs Teh Manis Rp 10.000\nPPN 10% Rp 5.500\nGRAND TOTAL: Rp 60.500',
    ),
    (
      title: 'Struk Apotek',
      fileName: 'struk_apotek.jpg',
      rawText: 'APOTEK SEHAT SENTOSA\n19-11-2026\nVitamin C 1000mg 85.000\nMasker Medis 40.000\nJUMLAH TAGIHAN 125.000,00',
    ),
  ];

  OcrExtractionResult parseReceiptText(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return OcrExtractionResult(rawText: rawText);
    }

    final merchant = _extractMerchant(lines);
    final detectedDate = _extractDate(lines);
    final detectedAmount = _extractTotalAmount(lines);
    final lineItems = _extractLineItems(lines);

    return OcrExtractionResult(
      rawText: rawText,
      merchantName: merchant,
      detectedAmount: detectedAmount,
      detectedDate: detectedDate,
      lineItems: lineItems,
    );
  }

  String? _extractMerchant(List<String> lines) {
    for (final line in lines.take(3)) {
      if (_parseDateFromLine(line) != null) continue;
      if (RegExp(r'^[\d\W]+$').hasMatch(line)) continue;
      if (_containsTotalKeyword(line)) continue;
      return line;
    }
    return lines.first;
  }

  DateTime? _extractDate(List<String> lines) {
    for (final line in lines) {
      final parsed = _parseDateFromLine(line);
      if (parsed != null) return parsed;
    }
    return null;
  }

  DateTime? _parseDateFromLine(String line) {
    final isoMatch = RegExp(r'\b(20\d{2})[-/](\d{1,2})[-/](\d{1,2})\b').firstMatch(line);
    if (isoMatch != null) {
      final year = int.parse(isoMatch.group(1)!);
      final month = int.parse(isoMatch.group(2)!);
      final day = int.parse(isoMatch.group(3)!);
      return _safeDate(year, month, day);
    }

    final dmyMatch = RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](20\d{2})\b').firstMatch(line);
    if (dmyMatch != null) {
      final day = int.parse(dmyMatch.group(1)!);
      final month = int.parse(dmyMatch.group(2)!);
      final year = int.parse(dmyMatch.group(3)!);
      return _safeDate(year, month, day);
    }
    return null;
  }

  DateTime? _safeDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }

  int? _extractTotalAmount(List<String> lines) {
    // Priority 1: Explicit GRAND TOTAL / TOTAL BAYAR / JUMLAH TAGIHAN / TOTAL lines
    final priorityPatterns = [
      RegExp(r'\b(GRAND\s*TOTAL|TOTAL\s*BAYAR|JUMLAH\s*TAGIHAN|TAGIHAN|TOTAL\s*BELANJA)\b',
          caseSensitive: false),
      RegExp(r'\b(TOTAL|JUMLAH)\b', caseSensitive: false),
    ];

    for (final pattern in priorityPatterns) {
      for (final line in lines.reversed) {
        final lower = line.toLowerCase();
        if (lower.contains('subtotal') || lower.contains('kembali') || lower.contains('change')) {
          continue;
        }
        if (pattern.hasMatch(line)) {
          final parsed = _extractLastAmountInLine(line);
          if (parsed != null && parsed > 0) {
            return parsed;
          }
        }
      }
    }

    // Fallback: Largest monetary candidate excluding dates/times/kembali/tunai
    int? maxAmount;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('kembali') || lower.contains('tunai') || lower.contains('cash')) {
        continue;
      }
      final amount = _extractLastAmountInLine(line);
      if (amount != null && (maxAmount == null || amount > maxAmount)) {
        maxAmount = amount;
      }
    }
    return maxAmount;
  }

  bool _containsTotalKeyword(String line) {
    return RegExp(r'\b(total|jumlah|tunai|kembali|ppn|tax|subtotal|tagihan)\b',
            caseSensitive: false)
        .hasMatch(line);
  }

  int? _extractLastAmountInLine(String line) {
    // Strip dates so 2026 in 21/11/2026 doesn't masquerade as price
    final cleaned = line
        .replaceAll(RegExp(r'\b20\d{2}[-/]\d{1,2}[-/]\d{1,2}\b'), ' ')
        .replaceAll(RegExp(r'\b\d{1,2}[-/]\d{1,2}[-/]20\d{2}\b'), ' ')
        .replaceAll(RegExp(r'\b\d{1,2}:\d{2}\b'), ' ');

    final matches = RegExp(r'(?:Rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})+(?:,\d{2})?|\d{4,9})')
        .allMatches(cleaned)
        .toList();
    if (matches.isEmpty) return null;

    var token = matches.last.group(1)!;
    // Strip trailing ,00 decimals (Indonesian format)
    token = token.replaceFirst(RegExp(r',\d{2}$'), '');
    final digitsOnly = token.replaceAll(RegExp(r'[.,]'), '');
    return int.tryParse(digitsOnly);
  }

  List<String> _extractLineItems(List<String> lines) {
    final items = <String>[];
    for (final line in lines) {
      if (_containsTotalKeyword(line)) continue;
      if (_parseDateFromLine(line) != null && _extractLastAmountInLine(line) == null) continue;
      if (_extractLastAmountInLine(line) != null) {
        items.add(line);
      }
    }
    return items;
  }
}

