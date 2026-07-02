import 'package:drift/drift.dart';

class StockLocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get variationId => integer().nullable()();
  IntColumn get locationId => integer()();
  RealColumn get quantity => real()();
}
