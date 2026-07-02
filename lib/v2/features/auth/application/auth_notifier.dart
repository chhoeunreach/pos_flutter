import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/models/user.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._repo, this._storage) : super(const AuthState.initial());

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        state = const AuthState.initial();
        return;
      }
      final userDataRaw = await _storage.read(key: 'user_data');
      if (userDataRaw == null) {
        state = const AuthState.initial();
        return;
      }
      final userData = jsonDecode(userDataRaw) as Map<String, dynamic>;
      final user = User.fromJson(userData);
      final permsRaw = await _storage.read(key: 'user_permissions');
      final permissions = permsRaw != null
          ? List<String>.from(jsonDecode(permsRaw) as List)
          : <String>[];
      state = AuthState.authenticated(
        user: user,
        token: token,
        permissions: permissions,
      );
    } catch (_) {
      state = const AuthState.initial();
    }
  }

  Future<void> login(String username, String password) async {
    state = const AuthState.loading();
    try {
      final response = await _repo.login(username, password);
      if (response.success) {
        await _storage.write(key: 'auth_token', value: response.token);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(response.user.toJson()),
        );
        await _storage.write(
          key: 'user_permissions',
          value: jsonEncode(response.permissions),
        );
        state = AuthState.authenticated(
          user: response.user,
          token: response.token,
          permissions: response.permissions,
          canAccessAllLocations: response.canAccessAllLocations,
          locations: response.locations,
        );
      } else {
        state = AuthState.failure(response.message ?? 'Login failed');
      }
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      state = AuthState.failure(msg);
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repo.logout();
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'user_permissions');
    state = const AuthState.initial();
  }

  void selectLocation(int locationId) {
    final newState = state.mapOrNull(
      authenticated: (s) => s.copyWith(selectedLocationId: locationId),
    );
    if (newState != null) state = newState;
  }
}
