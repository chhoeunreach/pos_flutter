import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required int id,
    int? transactionId,
    String? transactionType,
    int? contactId,
    required double amount,
    required String method,
    int? accountId,
    String? note,
    required DateTime paidOn,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
