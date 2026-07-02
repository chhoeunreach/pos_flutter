import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    String? currencySymbol,
    @Default(2) int decimalDigits,
    String? thousandSeparator,
    double? defaultTaxRate,
    String? defaultDiscountType,
    String? dateFormat,
    String? timeFormat,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
