import 'package:dio/dio.dart';

import '../../../../core/models/user.dart';

abstract class AuthRepository {
  Future<bool> checkConnection();
  Future<AuthResponseData> login(String username, String password);
  Future<void> logout();
}

class AuthResponseData {
  final bool success;
  final String? message;
  final User user;
  final String token;
  final List<String> permissions;
  final bool canAccessAllLocations;
  final List<Map<String, dynamic>> locations;

  const AuthResponseData({
    required this.success,
    this.message,
    required this.user,
    required this.token,
    this.permissions = const [],
    this.canAccessAllLocations = false,
    this.locations = const [],
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<bool> checkConnection() async {
    try {
      final res = await _dio.get(
        '',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );
      return res.statusCode != null && res.statusCode! < 500;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthResponseData> login(String username, String password) async {
    final response = await _dio.post(
      '/login',
      data: {'username': username, 'password': password},
    );
    final json = response.data as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;
    if (!success) {
      return AuthResponseData(
        success: false,
        message: json['message'] as String? ?? 'Invalid credentials',
        user: User(id: 0, username: ''),
        token: '',
      );
    }
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      return AuthResponseData(
        success: false,
        message: 'Invalid response: missing data',
        user: User(id: 0, username: ''),
        token: '',
      );
    }
    final token = data['token'] as String?;
    final userRaw = data['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty || userRaw == null) {
      return AuthResponseData(
        success: false,
        message: 'Invalid response: missing token or user',
        user: User(id: 0, username: ''),
        token: '',
      );
    }
    final user = User.fromJson(userRaw);
    return AuthResponseData(
      success: true,
      user: user,
      token: token,
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
  }
}
