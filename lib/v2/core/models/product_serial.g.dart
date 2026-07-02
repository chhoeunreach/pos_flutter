// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_serial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductSerialImpl _$$ProductSerialImplFromJson(Map<String, dynamic> json) =>
    _$ProductSerialImpl(
      id: (json['id'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      variationId: (json['variationId'] as num?)?.toInt(),
      serialNumber: json['serialNumber'] as String,
      status: json['status'] as String? ?? 'in_stock',
      locationId: (json['locationId'] as num).toInt(),
      purchaseId: (json['purchaseId'] as num?)?.toInt(),
      saleId: (json['saleId'] as num?)?.toInt(),
      transferId: (json['transferId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductSerialImplToJson(_$ProductSerialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'variationId': instance.variationId,
      'serialNumber': instance.serialNumber,
      'status': instance.status,
      'locationId': instance.locationId,
      'purchaseId': instance.purchaseId,
      'saleId': instance.saleId,
      'transferId': instance.transferId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
