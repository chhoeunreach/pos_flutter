import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required int id,
    required String referenceNo,
    int? supplierId,
    required int locationId,
    required double total,
    @Default(0) double discount,
    @Default(0) double tax,
    @Default(0) double shipping,
    required double grandTotal,
    @Default('pending') String paymentStatus,
    @Default('received') String status,
    String? note,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}
