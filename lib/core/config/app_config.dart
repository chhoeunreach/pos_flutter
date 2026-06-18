import '../storage/secure_storage.dart';

class AppConfig {
  static String? serverUrl;
  static bool get hasServerUrl => serverUrl != null && serverUrl!.isNotEmpty;

  static Future<void> init() async {
    final storage = SecureStorageService();
    serverUrl = await storage.getBaseUrl();
  }

  static Future<void> setServerUrl(String url) async {
    serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final storage = SecureStorageService();
    await storage.saveBaseUrl(serverUrl!);
  }

  static Future<void> clear() async {
    serverUrl = null;
    final storage = SecureStorageService();
    await storage.saveBaseUrl('');
  }
}
