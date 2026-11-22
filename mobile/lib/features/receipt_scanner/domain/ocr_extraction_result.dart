class OcrExtractionResult {
  const OcrExtractionResult({
    required this.rawText,
    this.merchantName,
    this.detectedAmount,
    this.detectedDate,
    this.lineItems = const [],
    this.suggestedCategory,
    this.providerLabel,
    this.fallbackUsed = false,
  });

  final String rawText;
  final String? merchantName;
  final int? detectedAmount;
  final DateTime? detectedDate;
  final List<String> lineItems;
  final String? suggestedCategory;
  final String? providerLabel;
  final bool fallbackUsed;

  Map<String, dynamic> toJson() {
    return {
      'merchant_name': merchantName,
      'detected_amount': detectedAmount,
      'detected_date': detectedDate?.toIso8601String(),
      'line_items': lineItems,
      if (suggestedCategory != null) 'suggested_category': suggestedCategory,
      if (providerLabel != null) 'provider_label': providerLabel,
      'fallback_used': fallbackUsed,
    };
  }
}
