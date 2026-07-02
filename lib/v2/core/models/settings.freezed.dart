// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  String? get currencySymbol => throw _privateConstructorUsedError;
  int get decimalDigits => throw _privateConstructorUsedError;
  String? get thousandSeparator => throw _privateConstructorUsedError;
  double? get defaultTaxRate => throw _privateConstructorUsedError;
  String? get defaultDiscountType => throw _privateConstructorUsedError;
  String? get dateFormat => throw _privateConstructorUsedError;
  String? get timeFormat => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {String? currencySymbol,
      int decimalDigits,
      String? thousandSeparator,
      double? defaultTaxRate,
      String? defaultDiscountType,
      String? dateFormat,
      String? timeFormat});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currencySymbol = freezed,
    Object? decimalDigits = null,
    Object? thousandSeparator = freezed,
    Object? defaultTaxRate = freezed,
    Object? defaultDiscountType = freezed,
    Object? dateFormat = freezed,
    Object? timeFormat = freezed,
  }) {
    return _then(_value.copyWith(
      currencySymbol: freezed == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      decimalDigits: null == decimalDigits
          ? _value.decimalDigits
          : decimalDigits // ignore: cast_nullable_to_non_nullable
              as int,
      thousandSeparator: freezed == thousandSeparator
          ? _value.thousandSeparator
          : thousandSeparator // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTaxRate: freezed == defaultTaxRate
          ? _value.defaultTaxRate
          : defaultTaxRate // ignore: cast_nullable_to_non_nullable
              as double?,
      defaultDiscountType: freezed == defaultDiscountType
          ? _value.defaultDiscountType
          : defaultDiscountType // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFormat: freezed == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      timeFormat: freezed == timeFormat
          ? _value.timeFormat
          : timeFormat // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? currencySymbol,
      int decimalDigits,
      String? thousandSeparator,
      double? defaultTaxRate,
      String? defaultDiscountType,
      String? dateFormat,
      String? timeFormat});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currencySymbol = freezed,
    Object? decimalDigits = null,
    Object? thousandSeparator = freezed,
    Object? defaultTaxRate = freezed,
    Object? defaultDiscountType = freezed,
    Object? dateFormat = freezed,
    Object? timeFormat = freezed,
  }) {
    return _then(_$AppSettingsImpl(
      currencySymbol: freezed == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String?,
      decimalDigits: null == decimalDigits
          ? _value.decimalDigits
          : decimalDigits // ignore: cast_nullable_to_non_nullable
              as int,
      thousandSeparator: freezed == thousandSeparator
          ? _value.thousandSeparator
          : thousandSeparator // ignore: cast_nullable_to_non_nullable
              as String?,
      defaultTaxRate: freezed == defaultTaxRate
          ? _value.defaultTaxRate
          : defaultTaxRate // ignore: cast_nullable_to_non_nullable
              as double?,
      defaultDiscountType: freezed == defaultDiscountType
          ? _value.defaultDiscountType
          : defaultDiscountType // ignore: cast_nullable_to_non_nullable
              as String?,
      dateFormat: freezed == dateFormat
          ? _value.dateFormat
          : dateFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      timeFormat: freezed == timeFormat
          ? _value.timeFormat
          : timeFormat // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {this.currencySymbol,
      this.decimalDigits = 2,
      this.thousandSeparator,
      this.defaultTaxRate,
      this.defaultDiscountType,
      this.dateFormat,
      this.timeFormat});

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  @override
  final String? currencySymbol;
  @override
  @JsonKey()
  final int decimalDigits;
  @override
  final String? thousandSeparator;
  @override
  final double? defaultTaxRate;
  @override
  final String? defaultDiscountType;
  @override
  final String? dateFormat;
  @override
  final String? timeFormat;

  @override
  String toString() {
    return 'AppSettings(currencySymbol: $currencySymbol, decimalDigits: $decimalDigits, thousandSeparator: $thousandSeparator, defaultTaxRate: $defaultTaxRate, defaultDiscountType: $defaultDiscountType, dateFormat: $dateFormat, timeFormat: $timeFormat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.currencySymbol, currencySymbol) ||
                other.currencySymbol == currencySymbol) &&
            (identical(other.decimalDigits, decimalDigits) ||
                other.decimalDigits == decimalDigits) &&
            (identical(other.thousandSeparator, thousandSeparator) ||
                other.thousandSeparator == thousandSeparator) &&
            (identical(other.defaultTaxRate, defaultTaxRate) ||
                other.defaultTaxRate == defaultTaxRate) &&
            (identical(other.defaultDiscountType, defaultDiscountType) ||
                other.defaultDiscountType == defaultDiscountType) &&
            (identical(other.dateFormat, dateFormat) ||
                other.dateFormat == dateFormat) &&
            (identical(other.timeFormat, timeFormat) ||
                other.timeFormat == timeFormat));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currencySymbol,
      decimalDigits,
      thousandSeparator,
      defaultTaxRate,
      defaultDiscountType,
      dateFormat,
      timeFormat);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {final String? currencySymbol,
      final int decimalDigits,
      final String? thousandSeparator,
      final double? defaultTaxRate,
      final String? defaultDiscountType,
      final String? dateFormat,
      final String? timeFormat}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override
  String? get currencySymbol;
  @override
  int get decimalDigits;
  @override
  String? get thousandSeparator;
  @override
  double? get defaultTaxRate;
  @override
  String? get defaultDiscountType;
  @override
  String? get dateFormat;
  @override
  String? get timeFormat;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
