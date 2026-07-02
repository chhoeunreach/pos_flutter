import 'package:drift/drift.dart';

class Purchases extends Table {
  IntColumn get id => integer()();
  TextColumn get referenceNo => text()();
  IntColumn get supplierId => integer().nullable()();
  IntColumn get locationId => integer()();
  RealColumn get total => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get shipping => real().withDefault(const Constant(0))();
  RealColumn get grandTotal => real()();
  TextColumn get paymentStatus => text().withDefault(const Constant('pending'))();
  TextColumn get status => text().withDefault(const Constant('received'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
