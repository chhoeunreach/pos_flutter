import 'package:drift/drift.dart';

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer()();
  IntColumn get productId => integer()();
  IntColumn get variationId => integer().nullable()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real()();
  RealColumn get subtotal => real()();
  RealColumn get itemTax => real().withDefault(const Constant(0))();
}
