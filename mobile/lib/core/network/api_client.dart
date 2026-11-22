import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../errors/app_exception.dart';
import '../security/secure_storage_service.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({
    required EnvConfig envConfig,
    required this.secureStorage,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: envConfig.apiBaseUrl,
                connectTimeout: envConfig.connectTimeout,
                receiveTimeout: envConfig.receiveTimeout,
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'User-Agent': 'PersonalFinanceApp/1.0.0 (Android; Mobile)',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService secureStorage;

  Future<ApiResponse<Map<String, dynamic>>> checkHealth() async {
    return get<Map<String, dynamic>>(
      '/health',
      parseData: (raw) => Map<String, dynamic>.from(raw as Map),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? parseData,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data ?? const {}, parseData);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
    T Function(dynamic rawData)? parseData,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: options,
      );
      return ApiResponse.fromJson(response.data ?? const {}, parseData);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Duration receiveTimeout = const Duration(seconds: 45),
    T Function(dynamic rawData)? parseData,
  }) async {
    return post<T>(
      path,
      data: formData,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
        receiveTimeout: receiveTimeout,
      ),
      parseData: parseData,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic rawData)? parseData,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
      );
      return ApiResponse.fromJson(response.data ?? const {}, parseData);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  AppException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        status == null) {
      return const NetworkException();
    }

    final rawMessage = (body is Map && body['message'] is String)
        ? body['message'] as String
        : (body is String ? body : null);

    final isImunify = (rawMessage != null &&
            (rawMessage.contains('Imunify360') ||
                rawMessage.contains('bot-protection') ||
                rawMessage.contains('WebShield'))) ||
        (e.message != null &&
            (e.message!.contains('Imunify360') ||
                e.message!.contains('bot-protection')));

    final String message;
    if (isImunify) {
      message =
          'Akses API diblokir oleh proteksi server hosting (Imunify360 Bot-Protection). '
          'Silakan periksa pengaturan Imunify360/ModSecurity di cPanel atau hubungi pihak hosting.';
    } else if (body is Map &&
        body['message'] is String &&
        (body['message'] as String).trim().isNotEmpty) {
      message = (body['message'] as String).trim();
    } else {
      message = switch (status) {
        400 => 'Permintaan tidak valid (400). Periksa kembali data yang dimasukkan.',
        401 => 'Email atau kata sandi tidak cocok, atau sesi telah berakhir (401).',
        403 => 'Akses ditolak oleh server (403).',
        404 =>
          'Endpoint API tidak ditemukan di server (404). Pastikan backend dan routing di hosting sudah terpasang dengan benar.',
        405 => 'Metode request HTTP tidak diizinkan oleh server (405).',
        408 => 'Waktu permintaan habis (408). Silakan coba lagi.',
        422 => 'Validasi data gagal (422). Periksa kembali isian formulir.',
        429 => 'Terlalu banyak permintaan (429). Silakan tunggu sejenak.',
        500 =>
          'Terjadi gangguan internal pada server (500). Periksa file log Laravel di storage/logs.',
        502 => 'Server gateway bermasalah (502 Bad Gateway).',
        503 => 'Server sedang dalam pemeliharaan atau tidak dapat diakses (503).',
        504 => 'Waktu respon server habis (504 Gateway Timeout).',
        _ => 'Terjadi kesalahan pada server ($status).',
      };
    }

    final code = (body is Map && body['code'] is String)
        ? body['code'] as String
        : switch (status) {
            401 => 'UNAUTHENTICATED',
            403 => 'FORBIDDEN',
            404 => 'NOT_FOUND',
            422 => 'VALIDATION_ERROR',
            _ => 'HTTP_ERROR',
          };

    final errors = (body is Map && body['errors'] is Map<String, dynamic>)
        ? body['errors'] as Map<String, dynamic>
        : null;

    return switch (status) {
      401 => UnauthorizedException(message: message, code: code),
      403 => ForbiddenException(message: message, code: code),
      409 => ConflictException(message: message, code: code, errors: errors),
      422 => ValidationException(message: message, code: code, errors: errors),
      _ => ServerException(
          message: message,
          code: code,
          statusCode: status,
          errors: errors,
        ),
    };
  }
}

