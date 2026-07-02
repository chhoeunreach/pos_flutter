import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart' as legacy;

import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/screens/connect_screen.dart' as v2;
import '../../features/auth/presentation/screens/login_screen.dart' as v2;
import '../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../features/navigation/presentation/app_shell.dart';
import '../../../features/pos/presentation/screens/pos_screen.dart';
import '../../../features/products/presentation/screens/product_list_screen.dart';
import '../../../features/products/presentation/screens/product_detail_screen.dart';
import '../../../features/products/presentation/screens/product_form_screen.dart';
import '../../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../../features/customers/presentation/screens/customer_detail_screen.dart';
import '../../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../../features/suppliers/presentation/screens/supplier_list_screen.dart';
import '../../../features/suppliers/presentation/screens/supplier_detail_screen.dart';
import '../../../features/suppliers/presentation/screens/supplier_form_screen.dart';
import '../../../features/sales/presentation/screens/sale_list_screen.dart';
import '../../../features/sales/presentation/screens/sale_detail_screen.dart';
import '../../../features/purchases/presentation/screens/purchase_list_screen.dart';
import '../../../features/purchases/presentation/screens/purchase_detail_screen.dart';
import '../../../features/purchases/presentation/screens/purchase_form_screen.dart';
import '../../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../../features/expenses/presentation/screens/expense_form_screen.dart';
import '../../../features/stock/presentation/screens/stock_list_screen.dart';
import '../../../features/stock/presentation/screens/stock_transfer_screen.dart';
import '../../../features/payments/presentation/screens/payment_list_screen.dart';
import '../../../features/reports/presentation/screens/cashier_report_screen.dart';
import '../../../features/reports/presentation/screens/report_selection_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../features/todo/presentation/screens/todo_list_screen.dart';

class _GoRouterNotifier extends ChangeNotifier {
  void update() => notifyListeners();
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _GoRouterNotifier();
  ref.listen<AuthState>(authStateProvider, (prev, next) {
    if (prev != next) notifier.update();
  });
  return GoRouter(
    initialLocation: '/connect',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final isConnect = state.matchedLocation == '/connect';
      final isLogin = state.matchedLocation == '/login';
      final isAuth = auth.mapOrNull(authenticated: (_) => true) ?? false;
      final isLoading = auth.whenOrNull(loading: () => true) ?? false;
      final isCheckingAuth = isLoading && !isAuth;

      if (!legacy.AppConfig.hasServerUrl && !isConnect) return '/connect';
      if (isCheckingAuth) return null;
      if (isAuth && (isLogin || isConnect)) return '/';
      if (!isAuth && !isLogin && !isConnect && legacy.AppConfig.hasServerUrl) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
          path: '/connect',
          builder: (context, state) => const v2.ConnectScreen()),
      GoRoute(path: '/login', builder: (context, state) => const v2.LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/pos', builder: (context, state) => const PosScreen()),
          GoRoute(
              path: '/products',
              builder: (context, state) => const ProductListScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) => ProductDetailScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => ProductFormScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: 'create',
                    builder: (context, state) => const ProductFormScreen()),
              ]),
          GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomerListScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) => CustomerDetailScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => CustomerFormScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: 'create',
                    builder: (context, state) => const CustomerFormScreen()),
              ]),
          GoRoute(
              path: '/suppliers',
              builder: (context, state) => const SupplierListScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) => SupplierDetailScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => SupplierFormScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: 'create',
                    builder: (context, state) => const SupplierFormScreen()),
              ]),
          GoRoute(
              path: '/sales',
              builder: (context, state) => const SaleListScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    builder: (context, state) => SaleDetailScreen(
                        id: int.parse(state.pathParameters['id']!)))
              ]),
          GoRoute(
              path: '/purchases',
              builder: (context, state) => const PurchaseListScreen(),
              routes: [
                GoRoute(
                    path: 'create',
                    builder: (context, state) => const PurchaseFormScreen()),
                GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => PurchaseFormScreen(
                        id: int.parse(state.pathParameters['id']!))),
                GoRoute(
                    path: ':id',
                    builder: (context, state) => PurchaseDetailScreen(
                        id: int.parse(state.pathParameters['id']!))),
              ]),
          GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpenseListScreen(),
              routes: [
                GoRoute(
                    path: 'create',
                    builder: (context, state) => const ExpenseFormScreen()),
                GoRoute(
                    path: ':id/edit',
                    builder: (context, state) => ExpenseFormScreen(
                        id: int.parse(state.pathParameters['id']!))),
              ]),
          GoRoute(
              path: '/stock',
              builder: (context, state) => const StockListScreen()),
          GoRoute(
              path: '/transfers',
              builder: (context, state) => const StockTransferScreen()),
          GoRoute(
              path: '/payments',
              builder: (context, state) => const PaymentListScreen()),
          GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportSelectionScreen(),
              routes: [
                GoRoute(
                    path: 'cashier',
                    builder: (context, state) => const CashierReportScreen()),
                GoRoute(
                    path: 'sales',
                    builder: (context, state) =>
                        const CashierReportScreen(reportType: 'sales')),
              ]),
          GoRoute(
              path: '/todos',
              builder: (context, state) => const TodoListScreen()),
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
