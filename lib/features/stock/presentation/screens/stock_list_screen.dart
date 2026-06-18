import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/loading_widget.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  bool _showLowStockOnly = false;

  @override
  void initState() { super.initState(); _load(); }

  void _load() { sl<StockBloc>().add(_showLowStockOnly ? LoadLowStockEvent() : LoadStockEvent()); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StockBloc>(create: (_) => sl<StockBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Stock')),
        body: Column(children: [
          SwitchListTile(title: const Text('Show Low Stock Only'), value: _showLowStockOnly, onChanged: (v) => setState(() { _showLowStockOnly = v; _load(); })),
          Expanded(child: BlocBuilder<StockBloc, StockState>(builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            if (state.error != null) return Center(child: Text(state.error!));
            if (state.items.isEmpty) return const Center(child: Text('No stock data'));
            return RefreshIndicator(onRefresh: () async => _load(), child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = state.items[i];
                if (state.showLowStock) {
                  final qty = (item['qty_available'] as num?)?.toDouble() ?? 0;
                  final alert = (item['alert_quantity'] as num?)?.toDouble() ?? 0;
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.red[100], child: Icon(Icons.warning, color: Colors.red)),
                    title: Text(item['product_name'] ?? ''),
                    subtitle: Text('SKU: ${item['sku'] ?? ''} \u2022 ${item['variation_name'] ?? ''}'),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text('Alert: $alert', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  );
                }
                final variation = (item['variations'] as List?)?.isNotEmpty == true ? (item['variations'] as List).first as Map<String, dynamic> : null;
                final stockList = variation?['stock'] as List? ?? [];
                final totalStock = stockList.fold<double>(0, (sum, s) => sum + (((s as Map)['qty_available'] ?? 0) as num).toDouble());
                final alert = (item['alert_quantity'] as num?)?.toDouble() ?? 0;
                final isLow = item['enable_stock'] == true && totalStock <= alert;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: isLow ? Colors.red[100] : Colors.green[100], child: Icon(isLow ? Icons.warning : Icons.check_circle, color: isLow ? Colors.red : Colors.green)),
                  title: Text(item['name'] ?? ''), subtitle: Text('SKU: ${item['sku'] ?? ''}'),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('$totalStock ${(item['unit'] as Map?)?['short_name'] ?? 'pcs'}', style: TextStyle(fontWeight: FontWeight.bold, color: isLow ? Colors.red : null)),
                    Text('Alert: $alert', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                );
              },
            ));
          })),
        ]),
      ),
    );
  }
}
