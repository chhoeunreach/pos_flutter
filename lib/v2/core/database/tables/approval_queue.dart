import 'package:drift/drift.dart';

class ApprovalQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get requestType => text()();
  IntColumn get requesterId => integer()();
  TextColumn get data => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get reviewedBy => integer().nullable()();
  TextColumn get reviewNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();
}
