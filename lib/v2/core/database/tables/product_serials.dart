import 'package:drift/drift.dart';

class ProductSerials extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get variationId => integer().nullable()();
  TextColumn get serialNumber => text().unique()();
  TextColumn get status => text().withDefault(const Constant('in_stock'))();
  IntColumn get locationId => integer()();
  IntColumn get purchaseId => integer().nullable()();
  IntColumn get saleId => integer().nullable()();
  IntColumn get transferId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
