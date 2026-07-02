import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import '../utils/constants.dart';
import 'api_response.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.serverUrl ?? AppConstants.defaultBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _ErrorInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Dio get dio => _dio;

  Future<void> updateBaseUrl(String baseUrl) async {
    _dio.options.baseUrl = baseUrl;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    final json = response.data;
    if (json == null) {
      return ApiResponse(success: false, message: 'Empty response from server');
    }
    return ApiResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<PaginatedResponse<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParams);
    final json = response.data;
    if (json == null) {
      return PaginatedResponse(success: false, message: 'Empty response from server');
    }
    return PaginatedResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    final json = response.data;
    if (json == null) {
      return ApiResponse(success: false, message: 'Empty response from server');
    }
    return ApiResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.put(path, data: data);
    final json = response.data;
    if (json == null) {
      return ApiResponse(success: false, message: 'Empty response from server');
    }
    return ApiResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.delete(path);
    final json = response.data;
    if (json == null) {
      return ApiResponse(success: false, message: 'Empty response from server');
    }
    return ApiResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<ApiResponse<T>> upload<T>(
    String path, {
    required FormData data,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.post(path,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
        ));
    final json = response.data;
    if (json == null) {
      return ApiResponse(success: false, message: 'Empty response from server');
    }
    return ApiResponse.fromJson(
        json as Map<String, dynamic>, fromJson);
  }

  Future<void> setToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    await _storage.saveToken(token);
  }

  Future<void> clearToken() async {
    _dio.options.headers.remove('Authorization');
    await _storage.clearAuthData();
  }

  static void Function()? onUnauthorized;
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.clearAuthData();
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: const TimeoutException('Request timed out. Please try again.'),
        type: err.type,
      ));
      return;
    }

    if (err.type == DioExceptionType.connectionError) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: const NetworkException('Network error. Check your connection.'),
        type: err.type,
      ));
      return;
    }

    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;

      if (statusCode == 422) {
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: ValidationException(
            message: data is Map
                ? (data['message'] as String? ?? 'Validation failed')
                : 'Validation failed',
            errors:
                data is Map ? data['errors'] as Map<String, dynamic>? : null,
          ),
          response: err.response,
          type: err.type,
        ));
        return;
      }

      if (statusCode == 401) {
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error:
              const UnauthorizedException('Unauthorized. Please login again.'),
          response: err.response,
          type: err.type,
        ));
        return;
      }

      if (statusCode == 403) {
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: const PermissionDeniedException('You do not have permission.'),
          response: err.response,
          type: err.type,
        ));
        return;
      }

      if (statusCode == 404) {
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: const NotFoundException('Resource not found.'),
          response: err.response,
          type: err.type,
        ));
        return;
      }

      if (statusCode! >= 500) {
        final message = data is Map
            ? (data['message'] as String? ??
                'Server error. Please try again later.')
            : 'Server error. Please try again later.';
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: ServerException(message),
          response: err.response,
          type: err.type,
        ));
        return;
      }
    }

    handler.next(err);
  }
}
