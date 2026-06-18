class AppConstants {
  static const String appName = 'POS App';
  static const String baseUrlKey = 'base_url';
  static const String defaultBaseUrl = 'http://localhost:8000/api/mobile';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String permissionsKey = 'user_permissions';
  static const String locationKey = 'selected_location';
  static const String settingsKey = 'app_settings';

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);

  static const int pageSize = 20;
}
