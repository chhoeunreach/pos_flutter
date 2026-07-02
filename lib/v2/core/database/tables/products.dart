import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get brandId => integer().nullable()();
  TextColumn get type => text().withDefault(const Constant('single'))();
  BoolColumn get hasSerial => boolean().withDefault(const Constant(false))();
  BoolColumn get hasVariations => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
