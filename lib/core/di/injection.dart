import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'package:pos_app/features/todo/data/models/todo.dart';
import 'package:pos_app/features/todo/data/repositories/todo_repository_impl.dart';
import '../repositories/interfaces.dart';
import '../repositories/implementations.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(sl<SecureStorageService>()));

  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<PosRepository>(
      () => PosRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<ContactRepository>(
      () => ContactRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<StockRepository>(
      () => StockRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl<ApiClient>()));
  sl.registerLazySingleton<TodoRepository>(() => HiveTodoRepository());

  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl()));
  sl.registerLazySingleton<DashboardBloc>(() => DashboardBloc(sl()));
  sl.registerLazySingleton<PosBloc>(() => PosBloc(sl()));
  sl.registerLazySingleton<ProductBloc>(() => ProductBloc(sl()));
  sl.registerLazySingleton<ContactBloc>(() => ContactBloc(sl()));
  sl.registerLazySingleton<TransactionBloc>(() => TransactionBloc(sl()));
  sl.registerLazySingleton<StockBloc>(() => StockBloc(sl()));
  sl.registerLazySingleton<PaymentBloc>(() => PaymentBloc(sl()));
  sl.registerLazySingleton<ReportBloc>(() => ReportBloc(sl()));
  sl.registerLazySingleton<SettingsBloc>(() => SettingsBloc(sl()));
  sl.registerLazySingleton<TodoBloc>(() => TodoBloc(sl()));
}

// ═══════════════════════════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════════════════════════
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? token;
  final List<String> permissions;
  final bool canAccessAllLocations;
  final String? role;
  final List<Map<String, dynamic>> locations;
  final int? selectedLocationId;
  final String? error;
  final bool? isServerConnected;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.token,
    this.permissions = const [],
    this.canAccessAllLocations = false,
    this.role,
    this.locations = const [],
    this.selectedLocationId,
    this.error,
    this.isServerConnected,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Map<String, dynamic>? user,
    String? token,
    List<String>? permissions,
    bool? canAccessAllLocations,
    String? role,
    List<Map<String, dynamic>>? locations,
    int? selectedLocationId,
    String? error,
    bool? isServerConnected,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        token: token ?? this.token,
        permissions: permissions ?? this.permissions,
        canAccessAllLocations:
            canAccessAllLocations ?? this.canAccessAllLocations,
        role: role ?? this.role,
        locations: locations ?? this.locations,
        selectedLocationId: selectedLocationId ?? this.selectedLocationId,
        error: error,
        isServerConnected: isServerConnected ?? this.isServerConnected,
      );

  bool hasPermission(String p) => permissions.contains(p);
  Map<String, dynamic>? get selectedLocation => locations
      .cast<Map<String, dynamic>?>()
      .firstWhere((l) => l?['id'] == selectedLocationId,
          orElse: () => locations.isNotEmpty ? locations.first : null);

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        user,
        token,
        permissions,
        canAccessAllLocations,
        role,
        locations,
        selectedLocationId,
        error,
        isServerConnected,
      ];
}

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;
  LoginEvent(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class CheckConnectionEvent extends AuthEvent {}

class SelectLocationEvent extends AuthEvent {
  final int locationId;
  SelectLocationEvent(this.locationId);
  @override
  List<Object?> get props => [locationId];
}

class AuthBloc extends Bloc<Object, AuthState> {
  final AuthRepository _repo;
  AuthBloc(this._repo) : super(const AuthState(isLoading: true)) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<CheckConnectionEvent>(_onCheckConnection);
    on<SelectLocationEvent>(
        (e, emit) => emit(state.copyWith(selectedLocationId: e.locationId)));
  }

  Future<void> _onLogin(LoginEvent e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final res = await _repo.login(e.username, e.password);
      if (res['success'] != true) {
        throw Exception(res['message'] as String? ?? 'Login failed');
      }

      final data = res['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid login response: missing data object');
      }

      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Missing auth token from login response');
      }

      final user = data['user'];
      if (user is! Map<String, dynamic>) {
        throw Exception('Invalid login response: missing user object');
      }

      final perms = await _repo.getPermissions();
      final permsData = perms['data'];
      if (permsData is! Map<String, dynamic>) {
        throw Exception('Invalid permissions response: missing data object');
      }

      final locs = await _repo.getLocations();
      final selectedLocationId =
          locs.isNotEmpty ? locs.first['id'] as int? : null;

      emit(state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
        user: user,
        permissions: List<String>.from(permsData['all_permissions'] ?? []),
        canAccessAllLocations:
            permsData['can_access_all_locations'] as bool? ?? false,
        role: permsData['role'] as String?,
        locations: locs,
        selectedLocationId: selectedLocationId,
        error: null,
      ));
    } catch (e, stack) {
      debugPrint('Login failed: $e');
      debugPrintStack(stackTrace: stack);
      await _repo.clearAuthData();
      emit(AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
        isServerConnected: state.isServerConnected,
      ));
    }
  }

  Future<void> _onLogout(LogoutEvent e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repo.logout();
    } catch (_) {}
    emit(const AuthState());
  }

  Future<void> _onCheckConnection(
      CheckConnectionEvent e, Emitter<AuthState> emit) async {
    try {
      final connected = await _repo.checkConnection();
      emit(state.copyWith(isServerConnected: connected, error: null));
    } catch (e, stack) {
      debugPrint('Server check failed: $e');
      debugPrintStack(stackTrace: stack);
      emit(state.copyWith(isServerConnected: false));
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent e, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final me = await _repo.getMe();
      final perms = await _repo.getPermissions();
      final permsData = perms['data'] as Map<String, dynamic>? ?? {};
      final locs = await _repo.getLocations();
      emit(state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: me['data'] as Map<String, dynamic>?,
        permissions: List<String>.from(permsData['all_permissions'] ?? []),
        canAccessAllLocations:
            permsData['can_access_all_locations'] as bool? ?? false,
        role: permsData['role'] as String?,
        locations: locs,
      ));
    } catch (e, stack) {
      debugPrint('Auth check failed: $e');
      debugPrintStack(stackTrace: stack);
      await _repo.clearAuthData();
      emit(AuthState(isLoading: false, error: e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════
class DashboardState extends Equatable {
  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? locationId;
  const DashboardState(
      {this.data,
      this.isLoading = false,
      this.error,
      this.startDate,
      this.endDate,
      this.locationId});
  DashboardState copyWith(
          {Map<String, dynamic>? data,
          bool? isLoading,
          String? error,
          DateTime? startDate,
          DateTime? endDate,
          int? locationId}) =>
      DashboardState(
          data: data ?? this.data,
          isLoading: isLoading ?? this.isLoading,
          error: error,
          startDate: startDate ?? this.startDate,
          endDate: endDate ?? this.endDate,
          locationId: locationId ?? this.locationId);
  @override
  List<Object?> get props =>
      [data, isLoading, error, startDate, endDate, locationId];
}

class LoadDashboardEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? locationId;
  LoadDashboardEvent({this.startDate, this.endDate, this.locationId});
}

class DashboardBloc extends Bloc<Object, DashboardState> {
  final DashboardRepository _repo;
  DashboardBloc(this._repo) : super(const DashboardState()) {
    on<LoadDashboardEvent>((e, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: null,
          startDate: e.startDate,
          endDate: e.endDate,
          locationId: e.locationId));
      try {
        final res = await _repo.getDashboard(
            locationId: e.locationId,
            startDate: e.startDate?.toIso8601String(),
            endDate: e.endDate?.toIso8601String());
        if (res['success'] == true) {
          emit(state.copyWith(
              isLoading: false, data: res['data'] as Map<String, dynamic>));
        } else {
          emit(state.copyWith(
              isLoading: false, error: res['message'] as String?));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// POS
// ═══════════════════════════════════════════════════════════════════
class CartItem extends Equatable {
  final int productId;
  final int variationId;
  final String name;
  final String sku;
  final double price;
  final double priceIncTax;
  final double quantity;
  final String? image;
  final String unit;
  final double? lineDiscount;
  final String? lineDiscountType;
  final int? taxId;
  final double itemTax;

  const CartItem({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.sku,
    required this.price,
    this.priceIncTax = 0,
    this.quantity = 1,
    this.image,
    this.unit = 'pcs',
    this.lineDiscount,
    this.lineDiscountType,
    this.taxId,
    this.itemTax = 0,
  });

  double get lineTotal => (priceIncTax > 0 ? priceIncTax : price) * quantity;
  double get lineTotalExclTax => price * quantity;

  CartItem copyWith(
          {double? quantity,
          double? lineDiscount,
          String? lineDiscountType,
          double? price,
          double? priceIncTax}) =>
      CartItem(
          productId: productId,
          variationId: variationId,
          name: name,
          sku: sku,
          price: price ?? this.price,
          priceIncTax: priceIncTax ?? this.priceIncTax,
          quantity: quantity ?? this.quantity,
          image: image,
          unit: unit,
          lineDiscount: lineDiscount ?? this.lineDiscount,
          lineDiscountType: lineDiscountType ?? this.lineDiscountType,
          taxId: taxId,
          itemTax: itemTax);

  @override
  List<Object?> get props =>
      [productId, variationId, name, sku, price, quantity, image ?? '', unit];
}

class PosState extends Equatable {
  final List<CartItem> items;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? posSettings;
  final double discount;
  final String? discountType;
  final int? taxRateId;
  final String? error;
  final bool isLoading;
  final Map<String, dynamic>? validatedTotals;
  final Map<String, dynamic>? saleResult;

  const PosState({
    this.items = const [],
    this.customer,
    this.posSettings,
    this.discount = 0,
    this.discountType,
    this.taxRateId,
    this.error,
    this.isLoading = false,
    this.validatedTotals,
    this.saleResult,
  });

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  double get discountAmount {
    if (discountType == 'percentage') {
      return subtotal * discount / 100;
    }
    return discount;
  }

  double get tax {
    final taxable = subtotal - discountAmount;
    final taxRate = _toDouble(posSettings?['default_tax_rate']);
    return taxable * taxRate / 100;
  }

  double get total => subtotal - discountAmount + tax;

  PosState copyWith({
    List<CartItem>? items,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? posSettings,
    double? discount,
    String? discountType,
    int? taxRateId,
    String? error,
    bool? isLoading,
    Map<String, dynamic>? validatedTotals,
    Map<String, dynamic>? saleResult,
  }) =>
      PosState(
        items: items ?? this.items,
        customer: customer ?? this.customer,
        posSettings: posSettings ?? this.posSettings,
        discount: discount ?? this.discount,
        discountType: discountType ?? this.discountType,
        taxRateId: taxRateId ?? this.taxRateId,
        error: error,
        isLoading: isLoading ?? this.isLoading,
        validatedTotals: validatedTotals ?? this.validatedTotals,
        saleResult: saleResult ?? this.saleResult,
      );

  @override
  List<Object?> get props => [
        items,
        customer,
        posSettings,
        discount,
        discountType,
        taxRateId,
        error,
        isLoading,
        validatedTotals,
        saleResult
      ];
}

abstract class PosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPosSettingsEvent extends PosEvent {}

class AddToCartEvent extends PosEvent {
  final CartItem item;
  AddToCartEvent(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveFromCartEvent extends PosEvent {
  final int productId;
  final int variationId;
  RemoveFromCartEvent(this.productId, {this.variationId = 0});
  @override
  List<Object?> get props => [productId, variationId];
}

class UpdateCartItemQtyEvent extends PosEvent {
  final int productId;
  final int variationId;
  final double quantity;
  UpdateCartItemQtyEvent(this.productId, this.quantity, {this.variationId = 0});
  @override
  List<Object?> get props => [productId, variationId, quantity];
}

class SetCustomerEvent extends PosEvent {
  final Map<String, dynamic> customer;
  SetCustomerEvent(this.customer);
  @override
  List<Object?> get props => [customer];
}

class SetDiscountEvent extends PosEvent {
  final double amount;
  final String type;
  SetDiscountEvent(this.amount, this.type);
  @override
  List<Object?> get props => [amount, type];
}

class ValidateCartEvent extends PosEvent {}

class SubmitSaleEvent extends PosEvent {
  final double paidAmount;
  final String paymentMethod;
  final List<Map<String, dynamic>>? payments;
  final String? paymentStatus;
  final int? accountId;
  SubmitSaleEvent(
      {required this.paidAmount,
      required this.paymentMethod,
      this.payments,
      this.paymentStatus,
      this.accountId});
  @override
  List<Object?> get props =>
      [paidAmount, paymentMethod, payments, paymentStatus, accountId];
}

class ClearCartEvent extends PosEvent {}

class ResetPosEvent extends PosEvent {}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0;
  if (value is Map) {
    for (final key in const ['amount', 'value', 'rate', 'default_tax_rate']) {
      if (value.containsKey(key)) return _toDouble(value[key]);
    }
  }
  return 0;
}

class PosBloc extends Bloc<Object, PosState> {
  final PosRepository _repo;
  PosBloc(this._repo) : super(const PosState()) {
    on<LoadPosSettingsEvent>(_onLoadSettings);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>((e, emit) => emit(state.copyWith(
        items: state.items
            .where((i) =>
                i.productId != e.productId || i.variationId != e.variationId)
            .toList(),
        validatedTotals: null,
        saleResult: null)));
    on<UpdateCartItemQtyEvent>(_onUpdateQty);
    on<SetCustomerEvent>(
        (e, emit) => emit(state.copyWith(customer: e.customer)));
    on<SetDiscountEvent>((e, emit) =>
        emit(state.copyWith(discount: e.amount, discountType: e.type)));
    on<ValidateCartEvent>(_onValidateCart);
    on<SubmitSaleEvent>(_onSubmitSale);
    on<ClearCartEvent>((e, emit) => emit(state.copyWith(
        items: [],
        discount: 0,
        discountType: null,
        validatedTotals: null,
        saleResult: null)));
    on<ResetPosEvent>((e, emit) => emit(const PosState()));
  }

  Future<void> _onLoadSettings(
      LoadPosSettingsEvent e, Emitter<PosState> emit) async {
    try {
      final res = await _repo.getPosSettings();
      if (res['success'] == true) {
        emit(state.copyWith(posSettings: res['data'] as Map<String, dynamic>?));
      }
    } catch (_) {}
  }

  void _onAddToCart(AddToCartEvent e, Emitter<PosState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) =>
        i.productId == e.item.productId && i.variationId == e.item.variationId);
    if (idx >= 0) {
      items[idx] =
          items[idx].copyWith(quantity: items[idx].quantity + e.item.quantity);
    } else {
      items.add(e.item);
    }
    emit(state.copyWith(items: items, validatedTotals: null, saleResult: null));
  }

  void _onUpdateQty(UpdateCartItemQtyEvent e, Emitter<PosState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere(
        (i) => i.productId == e.productId && i.variationId == e.variationId);
    if (idx >= 0) {
      if (e.quantity <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: e.quantity);
      }
    }
    emit(state.copyWith(items: items, validatedTotals: null, saleResult: null));
  }

  Future<void> _onValidateCart(
      ValidateCartEvent e, Emitter<PosState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = {
        'products': state.items
            .map((i) => {
                  'product_id': i.productId,
                  'variation_id': i.variationId,
                  'quantity': i.quantity,
                  'unit_price_inc_tax':
                      i.priceIncTax > 0 ? i.priceIncTax : i.price,
                  'item_tax': i.itemTax,
                  'tax_id': i.taxId,
                  'line_discount_type': i.lineDiscountType,
                  'line_discount_amount': i.lineDiscount ?? 0,
                })
            .toList(),
        'discount_type': state.discountType,
        'discount_amount': state.discount,
        'tax_rate_id': state.taxRateId,
        'location_id': 1,
      };
      final res = await _repo.validateCart(data);
      if (res['success'] == true) {
        emit(state.copyWith(
            isLoading: false,
            validatedTotals: res['data'] as Map<String, dynamic>));
      } else {
        emit(
            state.copyWith(isLoading: false, error: res['message'] as String?));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSubmitSale(SubmitSaleEvent e, Emitter<PosState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = {
        'contact_id': state.customer?['id'] ?? 1,
        'location_id': 1,
        'transaction_date': DateTime.now().toIso8601String(),
        'status': 'final',
        'products': state.items
            .map((i) => {
                  'product_id': i.productId,
                  'variation_id': i.variationId,
                  'quantity': i.quantity,
                  'unit_price': i.price,
                  'unit_price_inc_tax':
                      i.priceIncTax > 0 ? i.priceIncTax : i.price,
                  'item_tax': i.itemTax,
                  'tax_id': i.taxId,
                  'line_discount_type': i.lineDiscountType,
                  'line_discount_amount': i.lineDiscount ?? 0,
                })
            .toList(),
        'discount_type': state.discountType,
        'discount_amount': state.discount,
        'tax_rate_id': state.taxRateId,
        'payments': e.payments ??
            [
              {
                'method': e.paymentMethod,
                'amount': e.paidAmount,
                'paid_on': DateTime.now().toIso8601String(),
                'account_id': e.accountId ?? 1,
              }
            ],
        'is_suspend': false,
        'shipping_charges': 0,
      };
      final res = await _repo.createSale(data);
      if (res['success'] == true) {
        emit(state.copyWith(
            isLoading: false, saleResult: res['data'] as Map<String, dynamic>));
      } else {
        emit(
            state.copyWith(isLoading: false, error: res['message'] as String?));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// PRODUCTS
// ═══════════════════════════════════════════════════════════════════
class ProductState extends Equatable {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> brands;
  final Map<String, dynamic>? detail;
  final List<Map<String, dynamic>>? stockByLocation;
  final bool isLoading;
  final String? error;
  final int? selectedCategoryId;
  final int? selectedBrandId;
  final String searchQuery;
  const ProductState({
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.detail,
    this.stockByLocation,
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.selectedBrandId,
    this.searchQuery = '',
  });
  ProductState copyWith({
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? brands,
    Map<String, dynamic>? detail,
    List<Map<String, dynamic>>? stockByLocation,
    bool? isLoading,
    String? error,
    int? selectedCategoryId,
    int? selectedBrandId,
    String? searchQuery,
  }) =>
      ProductState(
        products: products ?? this.products,
        categories: categories ?? this.categories,
        brands: brands ?? this.brands,
        detail: detail ?? this.detail,
        stockByLocation: stockByLocation ?? this.stockByLocation,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
        selectedBrandId: selectedBrandId ?? this.selectedBrandId,
        searchQuery: searchQuery ?? this.searchQuery,
      );
  @override
  List<Object?> get props => [
        products,
        categories,
        brands,
        isLoading,
        error,
        selectedCategoryId,
        selectedBrandId,
        searchQuery
      ];
}

class LoadProductsEvent {
  final int? categoryId;
  final int? brandId;
  final String? search;
  final int? locationId;
  LoadProductsEvent(
      {this.categoryId, this.brandId, this.search, this.locationId});
}

class LoadCategoriesEvent {}

class LoadBrandsEvent {}

class LoadProductDetailEvent {
  final int id;
  LoadProductDetailEvent(this.id);
}

class LoadProductStockEvent {
  final int id;
  final int? locationId;
  LoadProductStockEvent(this.id, this.locationId);
}

class ProductBloc extends Bloc<Object, ProductState> {
  final ProductRepository _repo;
  ProductBloc(this._repo) : super(const ProductState()) {
    on<LoadProductsEvent>(_onLoad);
    on<LoadCategoriesEvent>((e, emit) async {
      try {
        emit(state.copyWith(categories: await _repo.getCategories()));
      } catch (_) {}
    });
    on<LoadBrandsEvent>((e, emit) async {
      try {
        emit(state.copyWith(brands: await _repo.getBrands()));
      } catch (_) {}
    });
    on<LoadProductDetailEvent>((e, emit) async {
      try {
        emit(state.copyWith(detail: await _repo.getById(e.id)));
      } catch (_) {}
    });
    on<LoadProductStockEvent>((e, emit) async {
      try {
        emit(state.copyWith(
            stockByLocation: await _repo.getStockByLocation(e.id,
                locationId: e.locationId)));
      } catch (_) {}
    });
  }
  Future<void> _onLoad(LoadProductsEvent e, Emitter<ProductState> emit) async {
    emit(state.copyWith(
        isLoading: true,
        error: null,
        selectedCategoryId: e.categoryId,
        selectedBrandId: e.brandId,
        searchQuery: e.search ?? ''));
    try {
      emit(state.copyWith(
          isLoading: false,
          products: await _repo.getAll(
              categoryId: e.categoryId,
              brandId: e.brandId,
              search: e.search,
              locationId: e.locationId)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONTACTS (Customers & Suppliers)
// ═══════════════════════════════════════════════════════════════════
class ContactState extends Equatable {
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> suppliers;
  final Map<String, dynamic>? detail;
  final Map<String, dynamic>? ledger;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String type; // 'customer' or 'supplier'
  const ContactState({
    this.customers = const [],
    this.suppliers = const [],
    this.detail,
    this.ledger,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.type = 'customer',
  });
  ContactState copyWith({
    List<Map<String, dynamic>>? customers,
    List<Map<String, dynamic>>? suppliers,
    Map<String, dynamic>? detail,
    Map<String, dynamic>? ledger,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? type,
  }) =>
      ContactState(
        customers: customers ?? this.customers,
        suppliers: suppliers ?? this.suppliers,
        detail: detail ?? this.detail,
        ledger: ledger ?? this.ledger,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        searchQuery: searchQuery ?? this.searchQuery,
        type: type ?? this.type,
      );
  List<Map<String, dynamic>> get contacts =>
      type == 'supplier' ? suppliers : customers;
  @override
  List<Object?> get props => [
        customers,
        suppliers,
        detail,
        ledger,
        isLoading,
        error,
        searchQuery,
        type
      ];
}

class LoadCustomersEvent {
  final String? search;
  LoadCustomersEvent({this.search});
}

class LoadSuppliersEvent {
  final String? search;
  LoadSuppliersEvent({this.search});
}

class LoadContactDetailEvent {
  final int id;
  LoadContactDetailEvent(this.id);
}

class LoadContactLedgerEvent {
  final int id;
  final String? startDate;
  final String? endDate;
  LoadContactLedgerEvent(this.id, {this.startDate, this.endDate});
}

class SetContactTypeEvent {
  final String type;
  SetContactTypeEvent(this.type);
}

class ContactBloc extends Bloc<Object, ContactState> {
  final ContactRepository _repo;
  ContactBloc(this._repo) : super(const ContactState()) {
    on<LoadCustomersEvent>((e, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: null,
          searchQuery: e.search ?? '',
          type: 'customer'));
      try {
        emit(state.copyWith(
            isLoading: false,
            customers: await _repo.getCustomers(search: e.search)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadSuppliersEvent>((e, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: null,
          searchQuery: e.search ?? '',
          type: 'supplier'));
      try {
        emit(state.copyWith(
            isLoading: false,
            suppliers: await _repo.getSuppliers(search: e.search)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadContactDetailEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        emit(state.copyWith(
            isLoading: false, detail: await _repo.getById(e.id)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadContactLedgerEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final res = await _repo.getLedger(e.id,
            startDate: e.startDate, endDate: e.endDate);
        if (res['success'] == true) {
          emit(state.copyWith(
              isLoading: false, ledger: res['data'] as Map<String, dynamic>));
        } else {
          emit(state.copyWith(
              isLoading: false, error: res['message'] as String?));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// TRANSACTIONS (Sales + Purchases + Expenses)
// ═══════════════════════════════════════════════════════════════════
class TransactionState extends Equatable {
  final List<Map<String, dynamic>> sales;
  final List<Map<String, dynamic>> purchases;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> expenseCategories;
  final Map<String, dynamic>? detail;
  final bool isLoading;
  final String? error;
  final String type; // 'sale', 'purchase', 'expense'
  const TransactionState({
    this.sales = const [],
    this.purchases = const [],
    this.expenses = const [],
    this.expenseCategories = const [],
    this.detail,
    this.isLoading = false,
    this.error,
    this.type = 'sale',
  });
  TransactionState copyWith({
    List<Map<String, dynamic>>? sales,
    List<Map<String, dynamic>>? purchases,
    List<Map<String, dynamic>>? expenses,
    List<Map<String, dynamic>>? expenseCategories,
    Map<String, dynamic>? detail,
    bool? isLoading,
    String? error,
    String? type,
  }) =>
      TransactionState(
        sales: sales ?? this.sales,
        purchases: purchases ?? this.purchases,
        expenses: expenses ?? this.expenses,
        expenseCategories: expenseCategories ?? this.expenseCategories,
        detail: detail ?? this.detail,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        type: type ?? this.type,
      );
  @override
  List<Object?> get props => [
        sales,
        purchases,
        expenses,
        expenseCategories,
        detail,
        isLoading,
        error,
        type
      ];
}

class LoadSalesEvent {
  final String? paymentStatus;
  final String? search;
  final int? locationId;
  final int? customerId;
  LoadSalesEvent(
      {this.paymentStatus, this.search, this.locationId, this.customerId});
}

class LoadSaleDetailEvent {
  final int id;
  LoadSaleDetailEvent(this.id);
}

class LoadPurchasesEvent {}

class LoadPurchaseDetailEvent {
  final int id;
  LoadPurchaseDetailEvent(this.id);
}

class LoadExpensesEvent {}

class LoadExpenseDetailEvent {
  final int id;
  LoadExpenseDetailEvent(this.id);
}

class LoadExpenseCategoriesEvent {}

class TransactionBloc extends Bloc<Object, TransactionState> {
  final TransactionRepository _repo;
  TransactionBloc(this._repo) : super(const TransactionState()) {
    on<LoadSalesEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, type: 'sale'));
      try {
        emit(state.copyWith(
            isLoading: false,
            sales: await _repo.getSales(
                paymentStatus: e.paymentStatus, search: e.search)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadSaleDetailEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        emit(state.copyWith(
            isLoading: false, detail: await _repo.getSaleById(e.id)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadPurchasesEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, type: 'purchase'));
      try {
        emit(state.copyWith(
            isLoading: false, purchases: await _repo.getPurchases()));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadPurchaseDetailEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        emit(state.copyWith(
            isLoading: false, detail: await _repo.getPurchaseById(e.id)));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadExpensesEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, type: 'expense'));
      try {
        emit(state.copyWith(
            isLoading: false, expenses: await _repo.getExpenses()));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadExpenseCategoriesEvent>((e, emit) async {
      try {
        emit(state.copyWith(
            expenseCategories: await _repo.getExpenseCategories()));
      } catch (_) {}
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// STOCK
// ═══════════════════════════════════════════════════════════════════
class StockState extends Equatable {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? error;
  final bool showLowStock;
  const StockState(
      {this.items = const [],
      this.isLoading = false,
      this.error,
      this.showLowStock = false});
  StockState copyWith(
          {List<Map<String, dynamic>>? items,
          bool? isLoading,
          String? error,
          bool? showLowStock}) =>
      StockState(
          items: items ?? this.items,
          isLoading: isLoading ?? this.isLoading,
          error: error,
          showLowStock: showLowStock ?? this.showLowStock);
  @override
  List<Object?> get props => [items, isLoading, error, showLowStock];
}

class LoadStockEvent {}

class LoadLowStockEvent {}

class StockBloc extends Bloc<Object, StockState> {
  final StockRepository _repo;
  StockBloc(this._repo) : super(const StockState()) {
    on<LoadStockEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, showLowStock: false));
      try {
        emit(state.copyWith(isLoading: false, items: await _repo.getAll()));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadLowStockEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, showLowStock: true));
      try {
        emit(
            state.copyWith(isLoading: false, items: await _repo.getLowStock()));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// PAYMENTS
// ═══════════════════════════════════════════════════════════════════
class PaymentState extends Equatable {
  final List<Map<String, dynamic>> payments;
  final bool isLoading;
  final String? error;
  const PaymentState(
      {this.payments = const [], this.isLoading = false, this.error});
  PaymentState copyWith(
          {List<Map<String, dynamic>>? payments,
          bool? isLoading,
          String? error}) =>
      PaymentState(
          payments: payments ?? this.payments,
          isLoading: isLoading ?? this.isLoading,
          error: error);
  @override
  List<Object?> get props => [payments, isLoading, error];
}

class LoadPaymentsEvent {}

class PaymentBloc extends Bloc<Object, PaymentState> {
  final PaymentRepository _repo;
  PaymentBloc(this._repo) : super(const PaymentState()) {
    on<LoadPaymentsEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        emit(state.copyWith(isLoading: false, payments: await _repo.getAll()));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// REPORTS
// ═══════════════════════════════════════════════════════════════════
class ReportState extends Equatable {
  final Map<String, dynamic>? cashierReport;
  final Map<String, dynamic>? reportData;
  final String reportType;
  final bool isLoading;
  final String? error;
  const ReportState(
      {this.cashierReport,
      this.reportData,
      this.reportType = 'cashier',
      this.isLoading = false,
      this.error});
  ReportState copyWith(
          {Map<String, dynamic>? cashierReport,
          Map<String, dynamic>? reportData,
          String? reportType,
          bool? isLoading,
          String? error}) =>
      ReportState(
          cashierReport: cashierReport ?? this.cashierReport,
          reportData: reportData ?? this.reportData,
          reportType: reportType ?? this.reportType,
          isLoading: isLoading ?? this.isLoading,
          error: error);
  @override
  List<Object?> get props =>
      [cashierReport, reportData, reportType, isLoading, error];
}

class LoadCashierReportEvent {
  final int? locationId;
  final String? startDate;
  final String? endDate;
  LoadCashierReportEvent({this.locationId, this.startDate, this.endDate});
}

class LoadSalesReportEvent {
  final int? locationId;
  final String? startDate;
  final String? endDate;
  LoadSalesReportEvent({this.locationId, this.startDate, this.endDate});
}

class ReportBloc extends Bloc<Object, ReportState> {
  final ReportRepository _repo;
  ReportBloc(this._repo) : super(const ReportState()) {
    on<LoadCashierReportEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, reportType: 'cashier'));
      try {
        final res = await _repo.getCashierReport(
            locationId: e.locationId,
            startDate: e.startDate,
            endDate: e.endDate);
        if (res['success'] == true) {
          emit(state.copyWith(
              isLoading: false,
              cashierReport: res['data'] as Map<String, dynamic>));
        } else {
          emit(state.copyWith(
              isLoading: false, error: res['message'] as String?));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadSalesReportEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null, reportType: 'sales'));
      try {
        final res = await _repo.getSalesReport(
            locationId: e.locationId,
            startDate: e.startDate,
            endDate: e.endDate);
        if (res['success'] == true) {
          emit(state.copyWith(
              isLoading: false,
              reportData: res['data'] as Map<String, dynamic>));
        } else {
          emit(state.copyWith(
              isLoading: false, error: res['message'] as String?));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════════
class SettingsState extends Equatable {
  final Map<String, dynamic>? settings;
  final List<Map<String, dynamic>> paymentMethods;
  final bool isLoading;
  final String? error;
  const SettingsState(
      {this.settings,
      this.paymentMethods = const [],
      this.isLoading = false,
      this.error});
  SettingsState copyWith(
          {Map<String, dynamic>? settings,
          List<Map<String, dynamic>>? paymentMethods,
          bool? isLoading,
          String? error}) =>
      SettingsState(
          settings: settings ?? this.settings,
          paymentMethods: paymentMethods ?? this.paymentMethods,
          isLoading: isLoading ?? this.isLoading,
          error: error);
  @override
  List<Object?> get props => [settings, paymentMethods, isLoading, error];
}

class LoadSettingsEvent {}

class LoadPaymentMethodsEvent {}

class SettingsBloc extends Bloc<Object, SettingsState> {
  final SettingsRepository _repo;
  SettingsBloc(this._repo) : super(const SettingsState()) {
    on<LoadSettingsEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final s = await _repo.get();
        emit(state.copyWith(isLoading: false, settings: s));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<LoadPaymentMethodsEvent>((e, emit) async {
      try {
        emit(state.copyWith(paymentMethods: await _repo.getPaymentMethods()));
      } catch (_) {}
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// TODOS
// ═══════════════════════════════════════════════════════════════════
class TodoState extends Equatable {
  final List<dynamic> todos;
  final bool isLoading;
  final String? error;
  const TodoState({this.todos = const [], this.isLoading = false, this.error});
  TodoState copyWith({List<dynamic>? todos, bool? isLoading, String? error}) =>
      TodoState(
          todos: todos ?? this.todos,
          isLoading: isLoading ?? this.isLoading,
          error: error);
  @override
  List<Object?> get props => [todos, isLoading, error];
}

class LoadTodosEvent {}

class AddTodoEvent {
  final dynamic todo;
  AddTodoEvent(this.todo);
}

class UpdateTodoEvent {
  final dynamic todo;
  UpdateTodoEvent(this.todo);
}

class DeleteTodoEvent {
  final String id;
  DeleteTodoEvent(this.id);
}

class ToggleTodoEvent {
  final String id;
  ToggleTodoEvent(this.id);
}

class TodoBloc extends Bloc<Object, TodoState> {
  final TodoRepository _repo;
  TodoBloc(this._repo) : super(const TodoState()) {
    on<LoadTodosEvent>((e, emit) async {
      emit(state.copyWith(isLoading: true, error: null));
      try {
        final raw = await _repo.getAll();
        final todos = raw.map((j) => Todo.fromJson(j)).toList();
        emit(state.copyWith(isLoading: false, todos: todos));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    on<AddTodoEvent>((e, emit) async {
      try {
        await _repo.add(e.todo.toJson());
        final raw = await _repo.getAll();
        emit(state.copyWith(todos: raw.map((j) => Todo.fromJson(j)).toList()));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<UpdateTodoEvent>((e, emit) async {
      try {
        await _repo.update(e.todo.id, e.todo.toJson());
        final raw = await _repo.getAll();
        emit(state.copyWith(todos: raw.map((j) => Todo.fromJson(j)).toList()));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<DeleteTodoEvent>((e, emit) async {
      try {
        await _repo.delete(e.id);
        final raw = await _repo.getAll();
        emit(state.copyWith(todos: raw.map((j) => Todo.fromJson(j)).toList()));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
    on<ToggleTodoEvent>((e, emit) async {
      try {
        await _repo.toggle(e.id);
        final raw = await _repo.getAll();
        emit(state.copyWith(todos: raw.map((j) => Todo.fromJson(j)).toList()));
      } catch (e) {
        emit(state.copyWith(error: e.toString()));
      }
    });
  }
}
