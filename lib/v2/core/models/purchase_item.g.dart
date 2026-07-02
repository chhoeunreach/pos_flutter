// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseItemImpl _$$PurchaseItemImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseItemImpl(
      id: (json['id'] as num).toInt(),
      purchaseId: (json['purchaseId'] as num).toInt(),
      productId: (json['productId'] as num).toInt(),
      variationId: (json['variationId'] as num?)?.toInt(),
      quantity: (json['quantity'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      itemTax: (json['itemTax'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$PurchaseItemImplToJson(_$PurchaseItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'purchaseId': instance.purchaseId,
      'productId': instance.productId,
      'variationId': instance.variationId,
      'quantity': instance.quantity,
      'unitCost': instance.unitCost,
      'subtotal': instance.subtotal,
      'itemTax': instance.itemTax,
    };
