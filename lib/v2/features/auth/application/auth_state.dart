import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _AuthInitial;

  const factory AuthState.loading() = _AuthLoading;

  const factory AuthState.authenticated({
    required User user,
    required String token,
    @Default([]) List<String> permissions,
    @Default(false) bool canAccessAllLocations,
    @Default([]) List<Map<String, dynamic>> locations,
    int? selectedLocationId,
  }) = _AuthAuthenticated;

  const factory AuthState.failure(String message) = _AuthFailure;
}
