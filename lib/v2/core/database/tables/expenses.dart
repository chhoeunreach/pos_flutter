import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer()();
  IntColumn get expenseCategoryId => integer().nullable()();
  IntColumn get locationId => integer()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseCategories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
