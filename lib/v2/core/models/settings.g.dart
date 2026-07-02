// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      currencySymbol: json['currencySymbol'] as String?,
      decimalDigits: (json['decimalDigits'] as num?)?.toInt() ?? 2,
      thousandSeparator: json['thousandSeparator'] as String?,
      defaultTaxRate: (json['defaultTaxRate'] as num?)?.toDouble(),
      defaultDiscountType: json['defaultDiscountType'] as String?,
      dateFormat: json['dateFormat'] as String?,
      timeFormat: json['timeFormat'] as String?,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'currencySymbol': instance.currencySymbol,
      'decimalDigits': instance.decimalDigits,
      'thousandSeparator': instance.thousandSeparator,
      'defaultTaxRate': instance.defaultTaxRate,
      'defaultDiscountType': instance.defaultDiscountType,
      'dateFormat': instance.dateFormat,
      'timeFormat': instance.timeFormat,
    };
