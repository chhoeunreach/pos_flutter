import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: 'user_data', value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: 'user_data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> savePermissions(List<String> permissions) async {
    await _storage.write(
        key: 'user_permissions', value: jsonEncode(permissions));
  }

  Future<List<String>> getPermissions() async {
    final data = await _storage.read(key: 'user_permissions');
    if (data != null) {
      return List<String>.from(jsonDecode(data) as List);
    }
    return [];
  }

  Future<void> saveSelectedLocationId(int locationId) async {
    await _storage.write(
        key: 'selected_location', value: locationId.toString());
  }

  Future<int?> getSelectedLocationId() async {
    final data = await _storage.read(key: 'selected_location');
    return data != null ? int.tryParse(data) : null;
  }

  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: 'base_url', value: url);
  }

  Future<String?> getBaseUrl() async {
    return await _storage.read(key: 'base_url');
  }

  Future<void> savePrinterIp(String ip) async {
    await _storage.write(key: 'printer_ip', value: ip);
  }

  Future<String?> getPrinterIp() async {
    return await _storage.read(key: 'printer_ip');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> clearAuthData() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'user_permissions');
    await _storage.delete(key: 'selected_location');
  }
}
