// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sale _$SaleFromJson(Map<String, dynamic> json) {
  return _Sale.fromJson(json);
}

/// @nodoc
mixin _$Sale {
  int get id => throw _privateConstructorUsedError;
  String get invoiceNo => throw _privateConstructorUsedError;
  int? get customerId => throw _privateConstructorUsedError;
  int get locationId => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get shipping => throw _privateConstructorUsedError;
  double get grandTotal => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int? get cashierId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get transactionDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaleCopyWith<Sale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleCopyWith<$Res> {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) then) =
      _$SaleCopyWithImpl<$Res, Sale>;
  @useResult
  $Res call(
      {int id,
      String invoiceNo,
      int? customerId,
      int locationId,
      double total,
      double discount,
      double tax,
      double shipping,
      double grandTotal,
      String paymentStatus,
      String status,
      int? cashierId,
      String? note,
      DateTime transactionDate,
      DateTime createdAt});
}

/// @nodoc
class _$SaleCopyWithImpl<$Res, $Val extends Sale>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNo = null,
    Object? customerId = freezed,
    Object? locationId = null,
    Object? total = null,
    Object? discount = null,
    Object? tax = null,
    Object? shipping = null,
    Object? grandTotal = null,
    Object? paymentStatus = null,
    Object? status = null,
    Object? cashierId = freezed,
    Object? note = freezed,
    Object? transactionDate = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      invoiceNo: null == invoiceNo
          ? _value.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      shipping: null == shipping
          ? _value.shipping
          : shipping // ignore: cast_nullable_to_non_nullable
              as double,
      grandTotal: null == grandTotal
          ? _value.grandTotal
          : grandTotal // ignore: cast_nullable_to_non_nullable
              as double,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: freezed == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaleImplCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$$SaleImplCopyWith(
          _$SaleImpl value, $Res Function(_$SaleImpl) then) =
      __$$SaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String invoiceNo,
      int? customerId,
      int locationId,
      double total,
      double discount,
      double tax,
      double shipping,
      double grandTotal,
      String paymentStatus,
      String status,
      int? cashierId,
      String? note,
      DateTime transactionDate,
      DateTime createdAt});
}

/// @nodoc
class __$$SaleImplCopyWithImpl<$Res>
    extends _$SaleCopyWithImpl<$Res, _$SaleImpl>
    implements _$$SaleImplCopyWith<$Res> {
  __$$SaleImplCopyWithImpl(_$SaleImpl _value, $Res Function(_$SaleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? invoiceNo = null,
    Object? customerId = freezed,
    Object? locationId = null,
    Object? total = null,
    Object? discount = null,
    Object? tax = null,
    Object? shipping = null,
    Object? grandTotal = null,
    Object? paymentStatus = null,
    Object? status = null,
    Object? cashierId = freezed,
    Object? note = freezed,
    Object? transactionDate = null,
    Object? createdAt = null,
  }) {
    return _then(_$SaleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      invoiceNo: null == invoiceNo
          ? _value.invoiceNo
          : invoiceNo // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      discount: null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      shipping: null == shipping
          ? _value.shipping
          : shipping // ignore: cast_nullable_to_non_nullable
              as double,
      grandTotal: null == grandTotal
          ? _value.grandTotal
          : grandTotal // ignore: cast_nullable_to_non_nullable
              as double,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cashierId: freezed == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleImpl implements _Sale {
  const _$SaleImpl(
      {required this.id,
      required this.invoiceNo,
      this.customerId,
      required this.locationId,
      required this.total,
      this.discount = 0,
      this.tax = 0,
      this.shipping = 0,
      required this.grandTotal,
      this.paymentStatus = 'pending',
      this.status = 'final',
      this.cashierId,
      this.note,
      required this.transactionDate,
      required this.createdAt});

  factory _$SaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleImplFromJson(json);

  @override
  final int id;
  @override
  final String invoiceNo;
  @override
  final int? customerId;
  @override
  final int locationId;
  @override
  final double total;
  @override
  @JsonKey()
  final double discount;
  @override
  @JsonKey()
  final double tax;
  @override
  @JsonKey()
  final double shipping;
  @override
  final double grandTotal;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  @JsonKey()
  final String status;
  @override
  final int? cashierId;
  @override
  final String? note;
  @override
  final DateTime transactionDate;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Sale(id: $id, invoiceNo: $invoiceNo, customerId: $customerId, locationId: $locationId, total: $total, discount: $discount, tax: $tax, shipping: $shipping, grandTotal: $grandTotal, paymentStatus: $paymentStatus, status: $status, cashierId: $cashierId, note: $note, transactionDate: $transactionDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNo, invoiceNo) ||
                other.invoiceNo == invoiceNo) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.shipping, shipping) ||
                other.shipping == shipping) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      invoiceNo,
      customerId,
      locationId,
      total,
      discount,
      tax,
      shipping,
      grandTotal,
      paymentStatus,
      status,
      cashierId,
      note,
      transactionDate,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      __$$SaleImplCopyWithImpl<_$SaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleImplToJson(
      this,
    );
  }
}

abstract class _Sale implements Sale {
  const factory _Sale(
      {required final int id,
      required final String invoiceNo,
      final int? customerId,
      required final int locationId,
      required final double total,
      final double discount,
      final double tax,
      final double shipping,
      required final double grandTotal,
      final String paymentStatus,
      final String status,
      final int? cashierId,
      final String? note,
      required final DateTime transactionDate,
      required final DateTime createdAt}) = _$SaleImpl;

  factory _Sale.fromJson(Map<String, dynamic> json) = _$SaleImpl.fromJson;

  @override
  int get id;
  @override
  String get invoiceNo;
  @override
  int? get customerId;
  @override
  int get locationId;
  @override
  double get total;
  @override
  double get discount;
  @override
  double get tax;
  @override
  double get shipping;
  @override
  double get grandTotal;
  @override
  String get paymentStatus;
  @override
  String get status;
  @override
  int? get cashierId;
  @override
  String? get note;
  @override
  DateTime get transactionDate;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SaleImplCopyWith<_$SaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
