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
    T Function(dynamic rawData)? parseData,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return ApiResponse.fromJson(response.data ?? const {}, parseData);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
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

    final message = (body is Map && body['message'] is String)
        ? body['message'] as String
        : (e.message ?? 'Terjadi kesalahan pada server.');
    final code = (body is Map && body['code'] is String)
        ? body['code'] as String
        : 'HTTP_ERROR';
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

