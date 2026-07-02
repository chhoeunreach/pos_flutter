// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: (json['id'] as num).toInt(),
      transactionId: (json['transactionId'] as num?)?.toInt(),
      transactionType: json['transactionType'] as String?,
      contactId: (json['contactId'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      accountId: (json['accountId'] as num?)?.toInt(),
      note: json['note'] as String?,
      paidOn: DateTime.parse(json['paidOn'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'transactionType': instance.transactionType,
      'contactId': instance.contactId,
      'amount': instance.amount,
      'method': instance.method,
      'accountId': instance.accountId,
      'note': instance.note,
      'paidOn': instance.paidOn.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
