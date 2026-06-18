import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  String _statusFilter = 'all';

  @override
  void initState() { super.initState(); _load(); }
  void _load() => sl<TransactionBloc>().add(LoadSalesEvent());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>.value(value: sl<TransactionBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sales')),
        body: Column(children: [
          SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: ['all', 'paid', 'due', 'partial'].map((s) {
              final sel = _statusFilter == s;
              return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                label: Text(s.toUpperCase()), selected: sel,
                onSelected: (_) { setState(() => _statusFilter = s); sl<TransactionBloc>().add(LoadSalesEvent(paymentStatus: s == 'all' ? null : s)); },
              ));
            }).toList()),
          ),
          Expanded(child: BlocBuilder<TransactionBloc, TransactionState>(builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            if (state.sales.isEmpty) return const Center(child: Text('No sales found'));
            return RefreshIndicator(onRefresh: () async => _load(), child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.sales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = state.sales[i];
                final isPaid = s['payment_status'] == 'paid'; final isDue = s['payment_status'] == 'due';
                final contact = s['contact'] as Map<String, dynamic>? ?? {};
                return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                  title: Text(s['invoice_no'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${contact['name'] ?? '-'} \u2022 ${s['transaction_date'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: isPaid ? Colors.green[50] : isDue ? Colors.orange[50] : Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                        child: Text(s['payment_status']?.toString().toUpperCase() ?? '', style: TextStyle(fontSize: 11, color: isPaid ? Colors.green[700] : isDue ? Colors.orange[700] : Colors.grey[700]))),
                      if ((s['location'] as Map?)?['name'] != null) ...[const SizedBox(width: 8), Text((s['location'] as Map)['name'], style: Theme.of(context).textTheme.bodySmall)],
                    ]),
                  ]),
                  trailing: Text(MoneyFormatter.instance.format(s['final_total']), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  onTap: () => context.go('/sales/${s['id']}'),
                ));
              },
            ));
          })),
        ]),
      ),
    );
  }
}
