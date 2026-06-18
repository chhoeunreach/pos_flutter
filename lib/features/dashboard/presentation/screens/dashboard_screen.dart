import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedRange = 'month';
  int? _selectedLocationId;
  late final DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = sl<DashboardBloc>();
    _applyRange('month');
  }

  void _applyRange(String range) {
    final now = DateTime.now();
    setState(() => _selectedRange = range);
    switch (range) {
      case 'today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      case 'week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      default:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
    _load();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
    });
    _load();
  }

  void _load() {
    _dashboardBloc.add(LoadDashboardEvent(
      startDate: _startDate,
      endDate: _endDate,
      locationId: _selectedLocationId,
    ));
  }

  String get _startLabel => _startDate != null
      ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
      : 'Start';

  String get _endLabel => _endDate != null
      ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
      : 'End';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            if (_selectedRange != 'month')
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Reset to this month',
                onPressed: () {
                  _applyRange('month');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filter reset to this month')),
                  );
                },
              ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.data == null) {
              return const LoadingWidget(fullScreen: true);
            }
            if (state.error != null && state.data == null) {
              return AppErrorWidget(message: state.error!, onRetry: _load);
            }

            final d = state.data;
            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateFilter(),
                      const SizedBox(height: 16),
                      if (d != null) ...[
                        _buildQuickActions(),
                        const SizedBox(height: 16),
                        _buildSummaryGrid(d),
                        const SizedBox(height: 24),
                        _buildLowStockSection(d),
                        const SizedBox(height: 24),
                        _buildRecentSales(d['recent_sales'] as List?),
                        const SizedBox(height: 24),
                        _buildTopProducts(d['top_products'] as List?),
                      ],
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    final locations = sl<AuthBloc>().state.locations;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.date_range, size: 18),
          const SizedBox(width: 8),
          Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _buildDateChip('Today', 'today'),
          const SizedBox(width: 8),
          _buildDateChip('This Week', 'week'),
          const SizedBox(width: 8),
          _buildDateChip('This Month', 'month'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(isStart: true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'From',
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                child: Text(_startLabel,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(isStart: false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'To',
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                child: Text(_endLabel,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
        ]),
        if (locations.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _selectedLocationId,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.store, size: 18),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All locations'),
              ),
              ...locations.map((location) => DropdownMenuItem<int?>(
                    value: _asInt(location['id']),
                    child: Text(location['name']?.toString() ?? ''),
                  )),
            ],
            onChanged: (value) {
              setState(() => _selectedLocationId = value);
              _load();
            },
          ),
        ],
      ]),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.go('/pos'),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Sell'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/transfers'),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Transfer'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(String label, String value) {
    final isActive = _selectedRange == value;
    return FilterChip(
      label: Text(label,
          style:
              TextStyle(fontSize: 12, color: isActive ? Colors.white : null)),
      selected: isActive,
      onSelected: (_) => _applyRange(value),
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> d) {
    final lowStockCount = d['low_stock_count'] as int? ?? 0;
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Total Sale',
          value: MoneyFormatter.instance.format(d['total_sale']),
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        _StatCard(
          label: 'Actual Income',
          value: MoneyFormatter.instance.format(d['actual_income']),
          icon: Icons.account_balance_wallet,
          color: Colors.green,
        ),
        _StatCard(
          label: 'Customer Payment',
          value: MoneyFormatter.instance.format(d['customer_payment']),
          icon: Icons.payments,
          color: Colors.teal,
        ),
        _StatCard(
          label: 'Collection Payment',
          value: MoneyFormatter.instance.format(d['collection_payment']),
          icon: Icons.account_balance,
          color: Colors.indigo,
        ),
        _StatCard(
          label: 'Expenses',
          value: MoneyFormatter.instance.format(d['expenses']),
          icon: Icons.money_off,
          color: Colors.red,
        ),
        _StatCard(
          label: 'Due',
          value: MoneyFormatter.instance.format(d['due']),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        _StatCard(
          label: 'Low Stock',
          value: '$lowStockCount',
          icon: Icons.inventory,
          color: lowStockCount > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildLowStockSection(Map<String, dynamic> d) {
    final count = d['low_stock_count'] as int? ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return AppCard(
      color: Colors.red.shade50,
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$count product${count > 1 ? 's' : ''} ${count > 1 ? 'are' : 'is'} low on stock',
            style: TextStyle(
                color: Colors.red.shade800, fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/stock'),
          child: const Text('View'),
        ),
      ]),
    );
  }

  Widget _buildRecentSales(List? sales) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recent Sales', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (sales == null || sales.isEmpty)
        const AppEmptyWidget(message: 'No recent sales')
      else
        ...sales.map((s) {
          final sale = s as Map<String, dynamic>;
          final isPaid = sale['payment_status'] == 'paid';
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    isPaid ? Colors.green[100] : Colors.orange[100],
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.pending,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(
                sale['invoice_no'] ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                '${sale['contact_name'] ?? '-'} \u2022 ${sale['transaction_date'] ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Text(
                MoneyFormatter.instance.format(sale['final_total']),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
    ]);
  }

  Widget _buildTopProducts(List? products) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Top Products', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (products == null || products.isEmpty)
        const AppEmptyWidget(message: 'No product data')
      else
        ...products.asMap().entries.map((entry) {
          final i = entry.key;
          final prod = entry.value as Map<String, dynamic>;
          final rankColors = [
            Colors.amber,
            Colors.grey.shade400,
            Colors.brown.shade300,
          ];
          final rankColor = i < 3 ? rankColors[i] : Colors.grey.shade300;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: i < 3 ? rankColor : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod['name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${prod['total_qty']} sold',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                MoneyFormatter.instance.format(prod['total_amount']),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ]),
          );
        }),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const Spacer(),
          ]),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
