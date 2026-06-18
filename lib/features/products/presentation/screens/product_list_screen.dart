import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    sl<ProductBloc>().add(LoadProductsEvent());
    sl<ProductBloc>().add(LoadCategoriesEvent());
    sl<ProductBloc>().add(LoadBrandsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (_) => sl<ProductBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Products'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.go('/products/create'))]),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Search products...', prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _load(); }) : null),
            onChanged: (v) => sl<ProductBloc>().add(LoadProductsEvent(search: v)),
          )),
          Expanded(child: BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            if (state.error != null) return Expanded(child: AppErrorWidget(message: state.error!, onRetry: _load));
            if (state.products.isEmpty) return const Center(child: Text('No products found'));
            return RefreshIndicator(onRefresh: () async => _load(), child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: state.products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = state.products[i];
                final variation = (p['variations'] as List?)?.isNotEmpty == true ? (p['variations'] as List).first as Map<String, dynamic> : null;
                final stockList = variation?['stock'] as List? ?? [];
                final totalStock = stockList.fold<double>(0, (sum, s) => sum + (((s as Map)['qty_available'] ?? 0) as num).toDouble());
                final alert = (p['alert_quantity'] as num?)?.toDouble() ?? 0;
                final isLow = p['enable_stock'] == true && totalStock <= alert;
                return ListTile(
                  leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.inventory_2, color: Colors.grey[400])),
                  title: Text(p['name'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Row(children: [
                    Text('SKU: ${p['sku'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 12),
                    if (p['category'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                      child: Text((p['category'] as Map)['name'] ?? '', style: TextStyle(fontSize: 11, color: Colors.blue[700]))),
                    const Spacer(),
                    if (isLow) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)),
                      child: Text('Stock: $totalStock', style: TextStyle(fontSize: 11, color: Colors.red[700]))),
                  ]),
                  trailing: Text(MoneyFormatter.instance.format(p['default_selling_price']), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  onTap: () => context.go('/products/${p['id']}'),
                );
              },
            ));
          })),
        ]),
      ),
    );
  }
}
