import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/approval_queue.dart';
import 'tables/audit_logs.dart';
import 'tables/brands.dart';
import 'tables/categories.dart';
import 'tables/customers.dart';
import 'tables/expenses.dart';
import 'tables/payments.dart';
import 'tables/product_serials.dart';
import 'tables/products.dart';
import 'tables/purchase_items.dart';
import 'tables/purchases.dart';
import 'tables/sale_items.dart';
import 'tables/sales.dart';
import 'tables/stock_locations.dart';
import 'tables/suppliers.dart';
import 'tables/sync_queue.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    ProductSerials,
    Categories,
    Brands,
    Customers,
    Suppliers,
    Sales,
    SaleItems,
    Purchases,
    PurchaseItems,
    Expenses,
    ExpenseCategories,
    Payments,
    StockLocations,
    SyncQueue,
    AuditLogs,
    ApprovalQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'ky_store.sqlite'));
    return NativeDatabase(file);
  });
}
