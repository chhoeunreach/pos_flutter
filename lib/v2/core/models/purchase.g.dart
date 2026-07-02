// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseImpl _$$PurchaseImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseImpl(
      id: (json['id'] as num).toInt(),
      referenceNo: json['referenceNo'] as String,
      supplierId: (json['supplierId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'received',
      note: json['note'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PurchaseImplToJson(_$PurchaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'referenceNo': instance.referenceNo,
      'supplierId': instance.supplierId,
      'locationId': instance.locationId,
      'total': instance.total,
      'discount': instance.discount,
      'tax': instance.tax,
      'shipping': instance.shipping,
      'grandTotal': instance.grandTotal,
      'paymentStatus': instance.paymentStatus,
      'status': instance.status,
      'note': instance.note,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
