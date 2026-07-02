// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleItemImpl _$$SaleItemImplFromJson(Map<String, dynamic> json) =>
    _$SaleItemImpl(
      id: (json['id'] as num).toInt(),
      saleId: (json['saleId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      variationId: (json['variationId'] as num?)?.toInt(),
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      itemTax: (json['itemTax'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$SaleItemImplToJson(_$SaleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'variationId': instance.variationId,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'subtotal': instance.subtotal,
      'itemTax': instance.itemTax,
    };
