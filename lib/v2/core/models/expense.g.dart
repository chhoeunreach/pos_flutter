// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: (json['id'] as num).toInt(),
      expenseCategoryId: (json['expenseCategoryId'] as num?)?.toInt(),
      locationId: (json['locationId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseCategoryId': instance.expenseCategoryId,
      'locationId': instance.locationId,
      'amount': instance.amount,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };
