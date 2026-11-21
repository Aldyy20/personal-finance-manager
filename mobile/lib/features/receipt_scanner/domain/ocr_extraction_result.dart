class OcrExtractionResult {
  const OcrExtractionResult({
    required this.rawText,
    this.merchantName,
    this.detectedAmount,
    this.detectedDate,
    this.lineItems = const [],
  });

  final String rawText;
  final String? merchantName;
  final int? detectedAmount;
  final DateTime? detectedDate;
  final List<String> lineItems;

  Map<String, dynamic> toJson() {
    return {
      'merchant_name': merchantName,
      'detected_amount': detectedAmount,
      'detected_date': detectedDate?.toIso8601String(),
      'line_items': lineItems,
    };
  }
}

