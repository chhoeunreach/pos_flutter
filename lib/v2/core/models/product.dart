import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required String sku,
    String? barcode,
    required double price,
    double? cost,
    int? categoryId,
    int? brandId,
    @Default('single') String type,
    @Default(false) bool hasSerial,
    @Default(false) bool hasVariations,
    @Default(true) bool isActive,
    String? imageUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
