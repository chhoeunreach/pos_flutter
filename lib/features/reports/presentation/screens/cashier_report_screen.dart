import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/app_card.dart';

class CashierReportScreen extends StatefulWidget {
  final String reportType;
  const CashierReportScreen({super.key, this.reportType = 'cashier'});

  @override
  State<CashierReportScreen> createState() => _CashierReportScreenState();
}

class _CashierReportScreenState extends State<CashierReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  void _load() {
    sl<ReportBloc>().add(LoadCashierReportEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>.value(
      value: sl<ReportBloc>(),
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.reportType == 'cashier'
                ? 'Cashier Report'
                : 'Sales Report'),
            bottom: TabBar(controller: _tabController, tabs: const [
              Tab(text: 'Sales'),
              Tab(text: 'Customer Payments'),
              Tab(text: 'Expenses'),
              Tab(text: 'Summary')
            ])),
        body: BlocBuilder<ReportBloc, ReportState>(builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(fullScreen: true);
          }
          if (state.error != null) {
            return AppErrorWidget(message: state.error!, onRetry: _load);
          }
          if (state.cashierReport == null) {
            return const AppEmptyWidget(message: 'No report data');
          }
          final r = state.cashierReport!;
          return TabBarView(controller: _tabController, children: [
            _buildSalesTab(r),
            _buildCustomerPaymentsTab(r),
            _buildExpensesTab(r),
            _buildSummaryTab(r),
          ]);
        }),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) => GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: [
          StatCard(
              label: 'Total Sale',
              value: MoneyFormatter.instance.format(summary['total_sale']),
              icon: Icons.shopping_cart,
              color: Colors.blue),
          StatCard(
              label: 'Actual Income',
              value: MoneyFormatter.instance.format(summary['actual_income']),
              icon: Icons.account_balance_wallet,
              color: Colors.green),
          StatCard(
              label: 'Customer Payment',
              value:
                  MoneyFormatter.instance.format(summary['customer_payment']),
              icon: Icons.payments,
              color: Colors.teal),
          StatCard(
              label: 'Collection Payment',
              value:
                  MoneyFormatter.instance.format(summary['collection_payment']),
              icon: Icons.collections,
              color: Colors.indigo),
          StatCard(
              label: 'Expenses',
              value: MoneyFormatter.instance.format(summary['expenses']),
              icon: Icons.money_off,
              color: Colors.red),
          StatCard(
              label: 'Due',
              value: MoneyFormatter.instance.format(summary['due']),
              icon: Icons.pending,
              color: Colors.orange),
        ],
      );

  Widget _buildSummaryTab(Map<String, dynamic> r) {
    final summary = r['summary'] as Map<String, dynamic>? ?? {};
    final userC = r['user_cashier'] as Map<String, dynamic>? ?? {};
    final location = r['location'] as Map<String, dynamic>? ?? {};
    final pm = r['payment_method'] as Map<String, dynamic>? ?? {};
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildSummaryCards(summary),
          const SizedBox(height: 24),
          Text('User / Cashier', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
              child: ListTile(
                  title: const Text('Amount'),
                  trailing: Text(
                      MoneyFormatter.instance.format(userC['amount']),
                      style: const TextStyle(fontWeight: FontWeight.bold)))),
          const SizedBox(height: 16),
          Text('By Location', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...location.entries.map((e) => Card(
              child: ListTile(
                  title: Text(e.key),
                  trailing: Text(
                      MoneyFormatter.instance
                          .format((e.value as Map)['amount']),
                      style: const TextStyle(fontWeight: FontWeight.bold))))),
          const SizedBox(height: 16),
          Text('By Payment Method',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...pm.entries.map((e) => Card(
              child: ListTile(
                  title: Text(e.key),
                  trailing: Text(MoneyFormatter.instance.format(e.value),
                      style: const TextStyle(fontWeight: FontWeight.bold))))),
        ]));
  }

  Widget _buildSalesTab(Map<String, dynamic> r) {
    final detail = r['detail'] as Map<String, dynamic>? ?? {};
    final sales = detail['sales'] as List? ?? [];
    if (sales.isEmpty) {
      return const Center(child: Text('No sales'));
    }
    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sales.length,
        itemBuilder: (context, i) {
          final s = sales[i] as Map<String, dynamic>;
          return Card(
              child: ListTile(
            title: Text(s['invoice_no'] ?? ''),
            subtitle: Text(
                '${s['contact_name'] ?? ''} \u2022 ${s['payment_status']}'),
            trailing: Text(MoneyFormatter.instance.format(s['final_total']),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ));
        });
  }

  Widget _buildCustomerPaymentsTab(Map<String, dynamic> r) {
    final detail = r['detail'] as Map<String, dynamic>? ?? {};
    final payments = detail['customer_payments'] as List? ?? [];
    if (payments.isEmpty) {
      return const Center(child: Text('No customer payments'));
    }
    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: payments.length,
        itemBuilder: (context, i) {
          final p = payments[i] as Map<String, dynamic>;
          return Card(
              child: ListTile(
            title: Text(p['customer_name'] ?? ''),
            subtitle: Text('Method: ${p['method']}'),
            trailing: Text(MoneyFormatter.instance.format(p['amount']),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ));
        });
  }

  Widget _buildExpensesTab(Map<String, dynamic> r) {
    final detail = r['detail'] as Map<String, dynamic>? ?? {};
    final expenses = detail['expenses'] as List? ?? [];
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses'));
    }
    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: expenses.length,
        itemBuilder: (context, i) {
          final e = expenses[i] as Map<String, dynamic>;
          return Card(
              child: ListTile(
            title: Text(e['category_name'] ?? ''),
            subtitle: Text(e['note'] ?? ''),
            trailing: Text(MoneyFormatter.instance.format(e['amount']),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
          ));
        });
  }
}
