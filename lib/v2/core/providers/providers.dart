import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_config.dart' as legacy;
import '../database/app_database.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: legacy.AppConfig.serverUrl ?? 'http://localhost:8000/api/mobile',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.addAll([
    _AuthInterceptor(ref),
    _ErrorInterceptor(),
    if (dio.options.connectTimeout != null)
      LogInterceptor(requestBody: true, responseBody: true),
  ]);
  return dio;
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class _AuthInterceptor extends Interceptor {
  final Ref _ref;
  _AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final storage = _ref.read(secureStorageProvider);
      await storage.delete(key: 'auth_token');
      await storage.delete(key: 'user_data');
      await storage.delete(key: 'user_permissions');
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
        error: 'Request timed out. Please try again.',
        type: err.type,
      ));
      return;
    }
    if (err.type == DioExceptionType.connectionError) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: 'Network error. Check your connection.',
        type: err.type,
      ));
      return;
    }
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      final data = err.response!.data;
      if (statusCode == 401) {
        final message = data is Map
            ? (data['message'] as String? ?? 'Unauthorized. Please login again.')
            : 'Unauthorized. Please login again.';
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: message,
          response: err.response,
          type: err.type,
        ));
        return;
      }
      if (statusCode == 422) {
        final message = data is Map
            ? (data['message'] as String? ?? 'Validation failed')
            : 'Validation failed';
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: message,
          response: err.response,
          type: err.type,
        ));
        return;
      }
      if (statusCode == 404) {
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: 'Resource not found.',
          response: err.response,
          type: err.type,
        ));
        return;
      }
      if (statusCode! >= 500) {
        final message = data is Map
            ? (data['message'] as String? ?? 'Server error. Please try again later.')
            : 'Server error. Please try again later.';
        handler.next(DioException(
          requestOptions: err.requestOptions,
          error: message,
          response: err.response,
          type: err.type,
        ));
        return;
      }
    }
    handler.next(err);
  }
}

class LogInterceptor extends Interceptor {
  final bool requestBody;
  final bool responseBody;

  LogInterceptor({this.requestBody = false, this.responseBody = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}
