import 'package:drift/drift.dart';

class Payments extends Table {
  IntColumn get id => integer()();
  IntColumn get transactionId => integer().nullable()();
  TextColumn get transactionType => text().nullable()();
  IntColumn get contactId => integer().nullable()();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  IntColumn get accountId => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get paidOn => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
