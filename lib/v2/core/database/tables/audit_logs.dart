import 'package:drift/drift.dart';

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();
  TextColumn get oldValues => text().nullable()();
  TextColumn get newValues => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
