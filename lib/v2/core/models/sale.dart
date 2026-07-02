import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

@freezed
class Sale with _$Sale {
  const factory Sale({
    required int id,
    required String invoiceNo,
    int? customerId,
    required int locationId,
    required double total,
    @Default(0) double discount,
    @Default(0) double tax,
    @Default(0) double shipping,
    required double grandTotal,
    @Default('pending') String paymentStatus,
    @Default('final') String status,
    int? cashierId,
    String? note,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) =>
      _$SaleFromJson(json);
}
