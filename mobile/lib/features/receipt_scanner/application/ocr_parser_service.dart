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

  static const Map<String, int> _monthMap = {
    'jan': 1,
    'januari': 1,
    'january': 1,
    'feb': 2,
    'februari': 2,
    'february': 2,
    'mar': 3,
    'maret': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'mei': 5,
    'may': 5,
    'jun': 6,
    'juni': 6,
    'june': 6,
    'jul': 7,
    'juli': 7,
    'july': 7,
    'agu': 8,
    'ags': 8,
    'agustus': 8,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'okt': 10,
    'oktober': 10,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'des': 12,
    'desember': 12,
    'dec': 12,
    'december': 12,
  };

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

  /// Recommends a category name keyword based on scanned merchant & receipt items.
  String? recommendCategoryKeyword(String rawText, String? merchantName) {
    final combined = '${merchantName ?? ''} $rawText'.toLowerCase();

    bool containsAny(List<String> terms) =>
        terms.any((term) => combined.contains(term));

    if (containsAny([
      'apotek',
      'kimia farma',
      'k24',
      'guardian',
      'watson',
      'klinik',
      'rumah sakit',
      'rs ',
      'obat',
      'vitamin',
    ])) {
      return 'kesehatan';
    }

    if (containsAny([
      'pertamina',
      'spbu',
      'shell',
      'vivo',
      'bensin',
      'pertalite',
      'pertamax',
      'parkir',
      'tol',
      'grab',
      'gojek',
      'krl',
      'mrt',
    ])) {
      return 'transport';
    }

    if (containsAny([
      'pln',
      'listrik',
      'token',
      'pdam',
      'telkom',
      'indihome',
      'wifi',
      'pulsa',
      'tagihan',
    ])) {
      return 'tagihan';
    }

    if (containsAny(['gramedia', 'buku', 'kampus', 'sekolah', 'kursus'])) {
      return 'pendidikan';
    }

    if (containsAny([
      'xxi',
      'cgv',
      'cinema',
      'bioskop',
      'game',
      'steam',
      'netflix',
      'spotify',
    ])) {
      return 'hiburan';
    }

    if (containsAny([
      'resto',
      'warung',
      'cafe',
      'kafe',
      'kopi',
      'coffee',
      'makan',
      'ayam',
      'bakso',
      'nasi',
      'kitchen',
      'bakery',
      'starbucks',
      'fore',
      'kenangan',
    ])) {
      return 'makan';
    }

    if (containsAny([
      'indomaret',
      'alfamart',
      'alfamidi',
      'super indo',
      'superindo',
      'hypermart',
      'transmart',
      'minimarket',
      'mart',
    ])) {
      return 'belanja';
    }

    return null;
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
    // 1. ISO date: 2026-11-21, 2026/11/21, 2026.11.21
    final isoMatch =
        RegExp(r'\b(20\d{2})[-/.](\d{1,2})[-/.](\d{1,2})\b').firstMatch(line);
    if (isoMatch != null) {
      final year = int.parse(isoMatch.group(1)!);
      final month = int.parse(isoMatch.group(2)!);
      final day = int.parse(isoMatch.group(3)!);
      return _safeDate(year, month, day);
    }

    // 2. DMY 4-digit year: 21/11/2026, 21-11-2026, 21.11.2026
    final dmy4Match =
        RegExp(r'\b(\d{1,2})[-/.](\d{1,2})[-/.](20\d{2})\b').firstMatch(line);
    if (dmy4Match != null) {
      final day = int.parse(dmy4Match.group(1)!);
      final month = int.parse(dmy4Match.group(2)!);
      final year = int.parse(dmy4Match.group(3)!);
      return _safeDate(year, month, day);
    }

    // 3. DMY 2-digit year: 21/11/26, 21-11-26, 21.11.26
    final dmy2Match =
        RegExp(r'\b(\d{1,2})[-/.](\d{1,2})[-/.](\d{2})\b').firstMatch(line);
    if (dmy2Match != null) {
      final day = int.parse(dmy2Match.group(1)!);
      final month = int.parse(dmy2Match.group(2)!);
      final year = 2000 + int.parse(dmy2Match.group(3)!);
      return _safeDate(year, month, day);
    }

    // 4. Textual month (Indonesian / English): 21 Nov 2026, 21 November 2026
    final namedMonthMatch = RegExp(
      r'\b(\d{1,2})[\s-]+([A-Za-z]+)[\s-]+(20\d{2}|\d{2})\b',
    ).firstMatch(line);
    if (namedMonthMatch != null) {
      final day = int.parse(namedMonthMatch.group(1)!);
      final monthName = namedMonthMatch.group(2)!.toLowerCase();
      final month = _monthMap[monthName];
      if (month != null) {
        final rawYear = int.parse(namedMonthMatch.group(3)!);
        final year = rawYear < 100 ? 2000 + rawYear : rawYear;
        return _safeDate(year, month, day);
      }
    }

    return null;
  }

  DateTime? _safeDate(int year, int month, int day) {
    if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    return DateTime(year, month, day);
  }

  int? _extractTotalAmount(List<String> lines) {
    // Priority 1: Explicit GRAND TOTAL / TOTAL BAYAR / JUMLAH TAGIHAN / HARGA JUAL / TOTAL lines
    final priorityPatterns = [
      RegExp(
        r'\b(GRAND\s*TOTAL|TOTAL\s*BAYAR|JUMLAH\s*TAGIHAN|TAGIHAN|TOTAL\s*BELANJA|HARGA\s*JUAL)\b',
        caseSensitive: false,
      ),
      RegExp(r'\b(TOTAL|JUMLAH)\b', caseSensitive: false),
    ];

    for (final pattern in priorityPatterns) {
      for (var i = lines.length - 1; i >= 0; i--) {
        final line = lines[i];
        final lower = line.toLowerCase();
        if (lower.contains('subtotal') ||
            lower.contains('kembali') ||
            lower.contains('change') ||
            lower.contains('hemat')) {
          continue;
        }
        if (pattern.hasMatch(line)) {
          final parsed = _extractLastAmountInLine(line);
          if (parsed != null && parsed > 0) {
            return parsed;
          }
          // Handle split-line totals scanned from two-column thermal receipts
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            final nextLower = nextLine.toLowerCase();
            if (!nextLower.contains('kembali') &&
                !nextLower.contains('change') &&
                !nextLower.contains('subtotal') &&
                !nextLower.contains('tunai')) {
              final nextParsed = _extractLastAmountInLine(nextLine);
              if (nextParsed != null && nextParsed > 0) {
                return nextParsed;
              }
            }
          }
        }
      }
    }

    // Fallback: Largest monetary candidate excluding dates/times/kembali/tunai
    int? maxAmount;
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('kembali') ||
          lower.contains('tunai') ||
          lower.contains('cash') ||
          lower.contains('change')) {
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
    return RegExp(
      r'\b(total|jumlah|tunai|kembali|ppn|tax|subtotal|tagihan|harga\s*jual)\b',
      caseSensitive: false,
    ).hasMatch(line);
  }

  int? _extractLastAmountInLine(String line) {
    // Strip dates and times so 2026 in 21/11/2026 doesn't masquerade as price
    final cleaned = line
        .replaceAll(RegExp(r'\b20\d{2}[-/.]\d{1,2}[-/.]\d{1,2}\b'), ' ')
        .replaceAll(RegExp(r'\b\d{1,2}[-/.]\d{1,2}[-/.]20\d{2}\b'), ' ')
        .replaceAll(RegExp(r'\b\d{1,2}[-/.]\d{1,2}[-/.]\d{2}\b'), ' ')
        .replaceAll(RegExp(r'\b\d{1,2}:\d{2}\b'), ' ');

    final matches =
        RegExp(r'(?:Rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})+(?:,\d{2})?|\d{4,9})')
            .allMatches(cleaned)
            .toList();
    if (matches.isEmpty) return null;

    var token = matches.last.group(1)!;
    // Strip trailing ,00 or .00 decimals
    token = token.replaceFirst(RegExp(r'[.,]\d{2}$'), '');
    final digitsOnly = token.replaceAll(RegExp(r'[.,]'), '');
    return int.tryParse(digitsOnly);
  }

  List<String> _extractLineItems(List<String> lines) {
    final items = <String>[];
    for (final line in lines) {
      if (_containsTotalKeyword(line)) continue;
      if (_parseDateFromLine(line) != null && _extractLastAmountInLine(line) == null) {
        continue;
      }
      if (_extractLastAmountInLine(line) != null) {
        items.add(line);
      }
    }
    return items;
  }
}
