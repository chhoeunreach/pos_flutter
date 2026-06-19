abstract class AuthRepository {
  Future<bool> checkConnection();
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> clearAuthData();
  Future<void> logout();
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> getPermissions();
  Future<List<Map<String, dynamic>>> getLocations();
}

abstract class DashboardRepository {
  Future<Map<String, dynamic>> getDashboard(
      {int? locationId, String? startDate, String? endDate});
}

abstract class PosRepository {
  Future<Map<String, dynamic>> getPosSettings();
  Future<List<Map<String, dynamic>>> getPosProducts(
      {int? locationId, int? categoryId, int? brandId, String? search});
  Future<Map<String, dynamic>> validateCart(Map<String, dynamic> data);
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getReceipt(int transactionId);
}

abstract class ProductRepository {
  Future<List<Map<String, dynamic>>> getAll(
      {int? page,
      int? categoryId,
      int? brandId,
      String? search,
      int? locationId});
  Future<Map<String, dynamic>> getById(int id);
  Future<List<Map<String, dynamic>>> getStockByLocation(int id,
      {int? locationId});
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getBrands();
}

abstract class ContactRepository {
  Future<List<Map<String, dynamic>>> getCustomers({String? search});
  Future<List<Map<String, dynamic>>> getSuppliers({String? search});
  Future<Map<String, dynamic>> getById(int id, {String type = 'customer'});
  Future<Map<String, dynamic>> create(Map<String, dynamic> data,
      {String type = 'customer'});
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data,
      {String type = 'customer'});
  Future<Map<String, dynamic>> getLedger(int id,
      {String? startDate, String? endDate, int? locationId});
  Future<Map<String, dynamic>> payDue(int id, double amount, String method,
      {int? accountId, String? note});
}

abstract class TransactionRepository {
  Future<List<Map<String, dynamic>>> getSales(
      {int? locationId,
      int? customerId,
      int? cashierId,
      String? paymentStatus,
      String? startDate,
      String? endDate,
      String? status,
      String? search});
  Future<Map<String, dynamic>> getSaleById(int id);
  Future<List<Map<String, dynamic>>> getPurchases();
  Future<Map<String, dynamic>> getPurchaseById(int id);
  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updatePurchase(int id, Map<String, dynamic> data);
  Future<void> deletePurchase(int id);
  Future<Map<String, dynamic>> addPayment(
      int transactionId, double amount, String method,
      {int? accountId, String? paidOn, String? note});
  Future<List<Map<String, dynamic>>> getExpenses();
  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateExpense(int id, Map<String, dynamic> data);
  Future<void> deleteExpense(int id);
  Future<List<Map<String, dynamic>>> getExpenseCategories();
}

abstract class StockRepository {
  Future<List<Map<String, dynamic>>> getAll({int? locationId});
  Future<List<Map<String, dynamic>>> getLowStock();
  Future<List<Map<String, dynamic>>> getTransfers({
    int? locationId,
    int? locationToId,
    int? productId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> adjust(Map<String, dynamic> data);
  Future<Map<String, dynamic>> transfer(Map<String, dynamic> data);
}

abstract class PaymentRepository {
  Future<List<Map<String, dynamic>>> getAll(
      {int? contactId, String? method, String? startDate, String? endDate});
  Future<Map<String, dynamic>> getById(int id);
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
}

abstract class ReportRepository {
  Future<Map<String, dynamic>> getCashierReport(
      {int? locationId, String? startDate, String? endDate});
  Future<Map<String, dynamic>> getSalesReport(
      {int? locationId, String? startDate, String? endDate});
  Future<Map<String, dynamic>> getCustomersDue();
  Future<Map<String, dynamic>> getStockReport();
}

abstract class SettingsRepository {
  Future<Map<String, dynamic>> get();
  Future<List<Map<String, dynamic>>> getPaymentMethods();
}

abstract class TodoRepository {
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> add(Map<String, dynamic> todo);
  Future<void> update(String id, Map<String, dynamic> todo);
  Future<void> delete(String id);
  Future<void> toggle(String id);
}
