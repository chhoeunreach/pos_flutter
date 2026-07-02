// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      brandId: (json['brandId'] as num?)?.toInt(),
      type: json['type'] as String? ?? 'single',
      hasSerial: json['hasSerial'] as bool? ?? false,
      hasVariations: json['hasVariations'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'price': instance.price,
      'cost': instance.cost,
      'categoryId': instance.categoryId,
      'brandId': instance.brandId,
      'type': instance.type,
      'hasSerial': instance.hasSerial,
      'hasVariations': instance.hasVariations,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
