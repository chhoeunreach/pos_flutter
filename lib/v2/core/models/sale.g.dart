// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleImpl _$$SaleImplFromJson(Map<String, dynamic> json) => _$SaleImpl(
      id: (json['id'] as num).toInt(),
      invoiceNo: json['invoiceNo'] as String,
      customerId: (json['customerId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'final',
      cashierId: (json['cashierId'] as num?)?.toInt(),
      note: json['note'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SaleImplToJson(_$SaleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceNo': instance.invoiceNo,
      'customerId': instance.customerId,
      'locationId': instance.locationId,
      'total': instance.total,
      'discount': instance.discount,
      'tax': instance.tax,
      'shipping': instance.shipping,
      'grandTotal': instance.grandTotal,
      'paymentStatus': instance.paymentStatus,
      'status': instance.status,
      'cashierId': instance.cashierId,
      'note': instance.note,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
