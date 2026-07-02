import 'package:drift/drift.dart';

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer()();
  IntColumn get productId => integer()();
  IntColumn get variationId => integer().nullable()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get subtotal => real()();
  RealColumn get itemTax => real().withDefault(const Constant(0))();
}
