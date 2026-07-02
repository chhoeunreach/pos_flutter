import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get parentId => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
