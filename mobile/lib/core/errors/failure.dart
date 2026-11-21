import 'app_exception.dart';

class Failure {
  const Failure({
    required this.message,
    required this.code,
    this.isRetryable = false,
  });

  final String message;
  final String code;
  final bool isRetryable;

  factory Failure.fromException(Object error) {
    if (error is NetworkException || error is ServerException) {
      final appError = error as AppException;
      return Failure(
        message: appError.message,
        code: appError.code,
        isRetryable: true,
      );
    }
    if (error is AppException) {
      return Failure(
        message: error.message,
        code: error.code,
        isRetryable: false,
      );
    }
    return Failure(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
      isRetryable: false,
    );
  }
}

