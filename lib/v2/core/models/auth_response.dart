import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required User user,
    required String token,
    @Default([]) List<String> permissions,
    @Default(false) bool canAccessAllLocations,
    @Default([]) List<Map<String, dynamic>> locations,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
