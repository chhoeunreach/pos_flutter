import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_item.freezed.dart';
part 'sale_item.g.dart';

@freezed
class SaleItem with _$SaleItem {
  const factory SaleItem({
    required int id,
    required int saleId,
    required int productId,
    int? variationId,
    required double quantity,
    required double unitPrice,
    required double subtotal,
    @Default(0) double itemTax,
  }) = _SaleItem;

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
}
