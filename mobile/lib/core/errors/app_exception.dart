sealed class AppException implements Exception {
  const AppException({
    required this.message,
    required this.code,
    this.statusCode,
    this.errors,
  });

  final String message;
  final String code;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  String get displayMessage {
    final errMap = errors;
    if (errMap != null) {
      for (final value in errMap.values) {
        if (value is List && value.isNotEmpty) {
          final first = value.first?.toString().trim();
          if (first != null && first.isNotEmpty) return first;
        } else if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return message;
  }

  @override
  String toString() => '[$code] ($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Tidak dapat terhubung ke server. Mode offline aktif.',
    super.code = 'NETWORK_ERROR',
    super.statusCode,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sesi autentikasi tidak valid atau telah berakhir.',
    super.code = 'UNAUTHENTICATED',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Anda tidak memiliki izin mengakses sumber daya ini.',
    super.code = 'FORBIDDEN',
    super.statusCode = 403,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.statusCode = 422,
    super.errors,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code = 'CONFLICT',
    super.statusCode = 409,
    super.errors,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.statusCode = 500,
    super.errors,
  });
}

class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code = 'DATABASE_ERROR',
  });
}

