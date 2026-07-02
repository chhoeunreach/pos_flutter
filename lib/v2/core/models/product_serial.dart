import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_serial.freezed.dart';
part 'product_serial.g.dart';

@freezed
class ProductSerial with _$ProductSerial {
  const factory ProductSerial({
    required int id,
    required int productId,
    int? variationId,
    required String serialNumber,
    @Default('in_stock') String status,
    required int locationId,
    int? purchaseId,
    int? saleId,
    int? transferId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ProductSerial;

  factory ProductSerial.fromJson(Map<String, dynamic> json) =>
      _$ProductSerialFromJson(json);
}
