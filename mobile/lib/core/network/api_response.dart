class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta = const {},
    this.errors = const {},
    this.code,
  });

  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> errors;
  final String? code;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? parseData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] == true,
      message: (json['message'] as String?) ?? '',
      data: parseData != null && rawData != null ? parseData(rawData) : rawData as T?,
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : const {},
      errors: json['errors'] is Map<String, dynamic>
          ? json['errors'] as Map<String, dynamic>
          : const {},
      code: json['code'] as String?,
    );
  }
}

