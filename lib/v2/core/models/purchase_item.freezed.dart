// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PurchaseItem _$PurchaseItemFromJson(Map<String, dynamic> json) {
  return _PurchaseItem.fromJson(json);
}

/// @nodoc
mixin _$PurchaseItem {
  int get id => throw _privateConstructorUsedError;
  int get purchaseId => throw _privateConstructorUsedError;
  int get productId => throw _privateConstructorUsedError;
  int? get variationId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get unitCost => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get itemTax => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseItemCopyWith<PurchaseItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseItemCopyWith<$Res> {
  factory $PurchaseItemCopyWith(
          PurchaseItem value, $Res Function(PurchaseItem) then) =
      _$PurchaseItemCopyWithImpl<$Res, PurchaseItem>;
  @useResult
  $Res call(
      {int id,
      int purchaseId,
      int productId,
      int? variationId,
      double quantity,
      double unitCost,
      double subtotal,
      double itemTax});
}

/// @nodoc
class _$PurchaseItemCopyWithImpl<$Res, $Val extends PurchaseItem>
    implements $PurchaseItemCopyWith<$Res> {
  _$PurchaseItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? purchaseId = null,
    Object? productId = null,
    Object? variationId = freezed,
    Object? quantity = null,
    Object? unitCost = null,
    Object? subtotal = null,
    Object? itemTax = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      purchaseId: null == purchaseId
          ? _value.purchaseId
          : purchaseId // ignore: cast_nullable_to_non_nullable
              as int,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int,
      variationId: freezed == variationId
          ? _value.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitCost: null == unitCost
          ? _value.unitCost
          : unitCost // ignore: cast_nullable_to_non_nullable
              as double,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      itemTax: null == itemTax
          ? _value.itemTax
          : itemTax // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseItemImplCopyWith<$Res>
    implements $PurchaseItemCopyWith<$Res> {
  factory _$$PurchaseItemImplCopyWith(
          _$PurchaseItemImpl value, $Res Function(_$PurchaseItemImpl) then) =
      __$$PurchaseItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int purchaseId,
      int productId,
      int? variationId,
      double quantity,
      double unitCost,
      double subtotal,
      double itemTax});
}

/// @nodoc
class __$$PurchaseItemImplCopyWithImpl<$Res>
    extends _$PurchaseItemCopyWithImpl<$Res, _$PurchaseItemImpl>
    implements _$$PurchaseItemImplCopyWith<$Res> {
  __$$PurchaseItemImplCopyWithImpl(
      _$PurchaseItemImpl _value, $Res Function(_$PurchaseItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? purchaseId = null,
    Object? productId = null,
    Object? variationId = freezed,
    Object? quantity = null,
    Object? unitCost = null,
    Object? subtotal = null,
    Object? itemTax = null,
  }) {
    return _then(_$PurchaseItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      purchaseId: null == purchaseId
          ? _value.purchaseId
          : purchaseId // ignore: cast_nullable_to_non_nullable
              as int,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int,
      variationId: freezed == variationId
          ? _value.variationId
          : variationId // ignore: cast_nullable_to_non_nullable
              as int?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unitCost: null == unitCost
          ? _value.unitCost
          : unitCost // ignore: cast_nullable_to_non_nullable
              as double,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      itemTax: null == itemTax
          ? _value.itemTax
          : itemTax // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseItemImpl implements _PurchaseItem {
  const _$PurchaseItemImpl(
      {required this.id,
      required this.purchaseId,
      required this.productId,
      this.variationId,
      required this.quantity,
      required this.unitCost,
      required this.subtotal,
      this.itemTax = 0});

  factory _$PurchaseItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseItemImplFromJson(json);

  @override
  final int id;
  @override
  final int purchaseId;
  @override
  final int productId;
  @override
  final int? variationId;
  @override
  final double quantity;
  @override
  final double unitCost;
  @override
  final double subtotal;
  @override
  @JsonKey()
  final double itemTax;

  @override
  String toString() {
    return 'PurchaseItem(id: $id, purchaseId: $purchaseId, productId: $productId, variationId: $variationId, quantity: $quantity, unitCost: $unitCost, subtotal: $subtotal, itemTax: $itemTax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.purchaseId, purchaseId) ||
                other.purchaseId == purchaseId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.variationId, variationId) ||
                other.variationId == variationId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitCost, unitCost) ||
                other.unitCost == unitCost) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.itemTax, itemTax) || other.itemTax == itemTax));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, purchaseId, productId,
      variationId, quantity, unitCost, subtotal, itemTax);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseItemImplCopyWith<_$PurchaseItemImpl> get copyWith =>
      __$$PurchaseItemImplCopyWithImpl<_$PurchaseItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseItemImplToJson(
      this,
    );
  }
}

abstract class _PurchaseItem implements PurchaseItem {
  const factory _PurchaseItem(
      {required final int id,
      required final int purchaseId,
      required final int productId,
      final int? variationId,
      required final double quantity,
      required final double unitCost,
      required final double subtotal,
      final double itemTax}) = _$PurchaseItemImpl;

  factory _PurchaseItem.fromJson(Map<String, dynamic> json) =
      _$PurchaseItemImpl.fromJson;

  @override
  int get id;
  @override
  int get purchaseId;
  @override
  int get productId;
  @override
  int? get variationId;
  @override
  double get quantity;
  @override
  double get unitCost;
  @override
  double get subtotal;
  @override
  double get itemTax;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseItemImplCopyWith<_$PurchaseItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
