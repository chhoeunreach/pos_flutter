import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/product_variation_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/sku_chip.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    sl<StockBloc>()
        .add(_showLowStockOnly ? LoadLowStockEvent() : LoadStockEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StockBloc>.value(
      value: sl<StockBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Stock')),
        body: Column(children: [
          SwitchListTile(
              title: const Text('Show Low Stock Only'),
              value: _showLowStockOnly,
              onChanged: (v) => setState(() {
                    _showLowStockOnly = v;
                    _load();
                  })),
          Expanded(child:
              BlocBuilder<StockBloc, StockState>(builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget();
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            if (state.items.isEmpty) {
              return const Center(child: Text('No stock data'));
            }
            return RefreshIndicator(
                onRefresh: () async => _load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    if (state.showLowStock) {
                      final qty = _asDouble(item['qty_available']);
                      final alert = _asDouble(item['alert_quantity']);
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Colors.red[100],
                            child: Icon(Icons.warning, color: Colors.red)),
                        title: Text(item['product_name'] ?? ''),
                        subtitle: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SkuChip(
                                sku: item['sku']?.toString() ?? '',
                                dense: true),
                            Text(item['variation_name']?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$qty',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              Text('Alert: $alert',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ]),
                      );
                    }
                    final variation = firstProductVariation(item);
                    final totalStock = productStockTotal(item, variation);
                    final alert = _asDouble(item['alert_quantity']);
                    final isLow =
                        _asBool(item['enable_stock']) && totalStock <= alert;
                    final variationName = variationDisplayName(variation);
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundColor:
                              isLow ? Colors.red[100] : Colors.green[100],
                          child: Icon(
                              isLow ? Icons.warning : Icons.check_circle,
                              color: isLow ? Colors.red : Colors.green)),
                      title: Text(item['name'] ?? ''),
                      subtitle: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SkuChip(
                              sku: item['sku']?.toString() ?? '', dense: true),
                          if (variationName.isNotEmpty)
                            Text(variationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.deepPurple.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                        ],
                      ),
                      trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                '$totalStock ${productUnitLabel(item)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLow ? Colors.red : null)),
                            Text('Alert: $alert',
                                style: Theme.of(context).textTheme.bodySmall),
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

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}
