import 'package:dio/dio.dart';

import '../api/api_client.dart';
import 'interfaces.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;

  AuthRepositoryImpl(this._api);

  @override
  Future<bool> checkConnection() async {
    try {
      final res = await _api.dio.get(
        '',
        options:
            Options(validateStatus: (status) => status != null && status < 500),
      );
      final statusCode = res.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/login',
      data: {'username': username, 'password': password},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (res.success && res.data != null && res.data!['token'] != null) {
      await _api.setToken(res.data!['token'] as String);
    }
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<void> clearAuthData() async {
    await _api.clearToken();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } finally {
      await _api.clearToken();
    }
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/me',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getPermissions() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/permissions',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (!res.success) {
      throw Exception(
          res.message.isNotEmpty ? res.message : 'Failed to load permissions');
    }
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<List<Map<String, dynamic>>> getLocations() async {
    final res = await _api.get<List<dynamic>>(
      '/locations',
      fromJson: (json) => json as List<dynamic>,
    );
    if (!res.success) {
      throw Exception(
          res.message.isNotEmpty ? res.message : 'Failed to load locations');
    }
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }
}

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiClient _api;

  DashboardRepositoryImpl(this._api);

  @override
  Future<Map<String, dynamic>> getDashboard(
      {int? locationId, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final res = await _api.get<Map<String, dynamic>>(
      '/dashboard',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }
}

class PosRepositoryImpl implements PosRepository {
  final ApiClient _api;

  PosRepositoryImpl(this._api);

  @override
  Future<Map<String, dynamic>> getPosSettings() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/pos/settings',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<List<Map<String, dynamic>>> getPosProducts(
      {int? locationId, int? categoryId, int? brandId, String? search}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (categoryId != null) params['category_id'] = categoryId;
    if (brandId != null) params['brand_id'] = brandId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/pos/products',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> validateCart(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/pos/validate-cart',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/pos/sales',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getReceipt(int transactionId) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/pos/receipt/$transactionId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }
}

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _api;

  ProductRepositoryImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getAll(
      {int? page,
      int? categoryId,
      int? brandId,
      String? search,
      int? locationId}) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (categoryId != null) params['category_id'] = categoryId;
    if (brandId != null) params['brand_id'] = brandId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (locationId != null) params['location_id'] = locationId;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/products',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/products/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> getStockByLocation(int id,
      {int? locationId}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    final res = await _api.get<List<dynamic>>(
      '/products/$id/stock',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/products',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await _api.put<Map<String, dynamic>>(
      '/products/$id',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _api.get<List<dynamic>>(
      '/categories',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getBrands() async {
    final res = await _api.get<List<dynamic>>(
      '/brands',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }
}

class ContactRepositoryImpl implements ContactRepository {
  final ApiClient _api;

  ContactRepositoryImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getCustomers({String? search}) async {
    final params = <String, dynamic>{'per_page': 500};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/customers',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<List<Map<String, dynamic>>> getSuppliers({String? search}) async {
    final params = <String, dynamic>{'per_page': 500};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/suppliers',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> getById(int id,
      {String type = 'customer'}) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/${type}s/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data,
      {String type = 'customer'}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/${type}s',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data,
      {String type = 'customer'}) async {
    final res = await _api.put<Map<String, dynamic>>(
      '/${type}s/$id',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getLedger(int id,
      {String? startDate,
      String? endDate,
      int? locationId,
      String type = 'customer'}) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (locationId != null) params['location_id'] = locationId;
    final res = await _api.get<Map<String, dynamic>>(
      '/${type}s/$id/ledger',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> payDue(int id, double amount, String method,
      {int? accountId, String? note, String type = 'customer'}) async {
    final data = <String, dynamic>{
      'amount': amount,
      'method': method,
    };
    if (accountId != null) data['account_id'] = accountId;
    if (note != null) data['note'] = note;
    final res = await _api.post<Map<String, dynamic>>(
      '/${type}s/$id/pay-due',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  final ApiClient _api;

  TransactionRepositoryImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getSales(
      {int? locationId,
      int? customerId,
      int? cashierId,
      String? paymentStatus,
      String? startDate,
      String? endDate,
      String? status,
      String? search}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (customerId != null) params['customer_id'] = customerId;
    if (cashierId != null) params['cashier_id'] = cashierId;
    if (paymentStatus != null) params['payment_status'] = paymentStatus;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (status != null) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/sales',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> getSaleById(int id) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/sales/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  @override
  Future<List<Map<String, dynamic>>> getPurchases(
      {int? locationId,
      int? supplierId,
      String? status,
      String? paymentStatus,
      String? startDate,
      String? endDate}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (supplierId != null) params['supplier_id'] = supplierId;
    if (status != null) params['status'] = status;
    if (paymentStatus != null) params['payment_status'] = paymentStatus;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/purchases',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> getPurchaseById(int id) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/purchases/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  @override
  Future<Map<String, dynamic>> createPurchase(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/purchases',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> addPayment(
      int transactionId, double amount, String method,
      {int? accountId,
      String? paidOn,
      String? note,
      String type = 'sale'}) async {
    final data = <String, dynamic>{
      'amount': amount,
      'method': method,
    };
    if (accountId != null) data['account_id'] = accountId;
    if (paidOn != null) data['paid_on'] = paidOn;
    if (note != null) data['note'] = note;
    final endpoint = type == 'purchase'
        ? '/purchases/$transactionId/payment'
        : '/sales/$transactionId/payment';
    final res = await _api.post<Map<String, dynamic>>(
      endpoint,
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final res = await _api.get<List<dynamic>>(
      '/expenses',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }

  @override
  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/expenses',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> updateExpense(
      int id, Map<String, dynamic> data) async {
    final res = await _api.put<Map<String, dynamic>>(
      '/expenses/$id',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _api.delete('/expenses/$id');
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    final res = await _api.get<List<dynamic>>(
      '/expenses/categories',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }
}

class StockRepositoryImpl implements StockRepository {
  final ApiClient _api;

  StockRepositoryImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getAll({int? locationId}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/stock',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<List<Map<String, dynamic>>> getLowStock() async {
    final res = await _api.get<List<dynamic>>(
      '/stock/low',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getTransfers({int? locationId}) async {
    final params = <String, dynamic>{'per_page': 100, 'type': 'sell_transfer'};
    if (locationId != null) params['location_id'] = locationId;
    final res = await _api.getPaginated<Map<String, dynamic>>(
      '/stock/transfers',
      queryParams: params,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data;
  }

  @override
  Future<Map<String, dynamic>> adjust(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/stock/adjustments',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> transfer(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/stock/transfers',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }
}

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiClient _api;

  PaymentRepositoryImpl(this._api);

  @override
  Future<List<Map<String, dynamic>>> getAll(
      {int? contactId,
      String? method,
      String? startDate,
      String? endDate}) async {
    final params = <String, dynamic>{};
    if (contactId != null) params['contact_id'] = contactId;
    if (method != null) params['method'] = method;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final res = await _api.get<List<dynamic>>(
      '/payments',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }

  @override
  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _api.get<Map<String, dynamic>>(
      '/payments/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return res.data ?? {};
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/payments',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'message': res.message, 'data': res.data};
  }
}

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient _api;

  ReportRepositoryImpl(this._api);

  @override
  Future<Map<String, dynamic>> getCashierReport(
      {int? locationId, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final res = await _api.get<Map<String, dynamic>>(
      '/reports/local-cashier',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getSalesReport(
      {int? locationId, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (locationId != null) params['location_id'] = locationId;
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    final res = await _api.get<Map<String, dynamic>>(
      '/reports/sales',
      queryParams: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getCustomersDue() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/reports/customers-due',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }

  @override
  Future<Map<String, dynamic>> getStockReport() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/reports/stock',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data};
  }
}

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _api;

  SettingsRepositoryImpl(this._api);

  @override
  Future<Map<String, dynamic>> get() async {
    final res = await _api.get<Map<String, dynamic>>(
      '/settings',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return {'success': res.success, 'data': res.data, 'message': res.message};
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final res = await _api.get<List<dynamic>>(
      '/payment-methods',
      fromJson: (json) => json as List<dynamic>,
    );
    return List<Map<String, dynamic>>.from(res.data ?? []);
  }
}
