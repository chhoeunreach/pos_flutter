import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../widgets/cart_widget.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _productScrollController = ScrollController();
  Timer? _searchDebounce;
  bool _showCart = false;

  @override
  void initState() {
    super.initState();
    sl<PosBloc>().add(LoadPosSettingsEvent());
    _loadProducts();
  }

  void _loadProducts() => sl<ProductBloc>().add(LoadProductsEvent());

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _productScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    if (wide) return BlocProvider.value(value: sl<PosBloc>(), child: _buildTabletLayout());
    if (_showCart) return BlocProvider.value(value: sl<PosBloc>(), child: _buildCartScreen());
    return BlocProvider.value(value: sl<PosBloc>(), child: _buildPhoneProductScreen());
  }

  Widget _buildPhoneProductScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('POS'), actions: [
        BlocBuilder<PosBloc, PosState>(builder: (context, s) => Badge(
          label: Text('${s.items.length}'),
          child: IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => setState(() => _showCart = true)),
        )),
      ]),
      body: Column(children: [
        _buildSearchBar(),
        Expanded(child: _buildProductGrid()),
      ]),
    );
  }

  Widget _buildCartScreen() => Scaffold(
    appBar: AppBar(title: const Text('Cart'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _showCart = false))),
    body: const CartWidget(),
  );

  Widget _buildTabletLayout() => Scaffold(
    appBar: AppBar(title: const Text('POS')),
    body: Row(children: [
      Expanded(flex: 3, child: Column(children: [_buildSearchBar(), Expanded(child: _buildProductGrid())])),
      const VerticalDivider(width: 1),
      BlocProvider.value(value: sl<PosBloc>(), child: const Expanded(flex: 2, child: CartWidget())),
    ]),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(8),
    child: TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name, SKU, or barcode...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _loadProducts(); })
            : null,
      ),
      onChanged: (v) {
        _searchDebounce?.cancel();
        _searchDebounce =
            Timer(const Duration(milliseconds: 400), () => sl<ProductBloc>().add(LoadProductsEvent(search: v)));
      },
    ),
  );

  Widget _buildProductGrid() {
    return BlocProvider<ProductBloc>.value(
      value: sl<ProductBloc>(),
      child: BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
        if (state.isLoading) return const LoadingWidget();
        if (state.error != null) return AppErrorWidget(message: state.error!, onRetry: _loadProducts);
        if (state.products.isEmpty) return const AppEmptyWidget(message: 'No products found', icon: Icons.search_off);
        return GridView.builder(
          controller: _productScrollController,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
            childAspectRatio: 0.85, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: state.products.length,
          itemBuilder: (context, index) => _buildProductCard(state.products[index]),
        );
      }),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? '';
    final variation = (product['variations'] as List?)?.isNotEmpty == true
        ? (product['variations'] as List).first as Map<String, dynamic>
        : null;
    final price = (variation?['sell_price_inc_tax'] as num?)?.toDouble() ?? (product['default_selling_price'] as num?)?.toDouble() ?? 0;
    final stockList = variation?['stock'] as List? ?? [];
    final totalStock = stockList.fold<double>(0, (sum, s) => sum + (((s as Map)['qty_available'] ?? 0) as num).toDouble());
    final alertQty = (product['alert_quantity'] as num?)?.toDouble() ?? 0;
    final isLowStock = product['enable_stock'] == true && totalStock <= alertQty;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          sl<PosBloc>().add(AddToCartEvent(CartItem(
            productId: product['id'] as int,
            variationId: variation?['id'] as int? ?? 0,
            name: name,
            sku: variation?['sub_sku'] as String? ?? product['sku'] ?? '',
            price: (variation?['default_sell_price'] as num?)?.toDouble() ?? price,
            priceIncTax: price,
            image: product['image_url'] as String?,
            unit: ((product['unit'] as Map?)?['short_name'] as String?) ?? 'pcs',
            taxId: product['tax'] as int?,
            itemTax: 0,
          )));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name added to cart'), duration: const Duration(seconds: 1)));
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Center(child: Icon(Icons.inventory_2, size: 48, color: Colors.grey[400])))),
          Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(MoneyFormatter.instance.format(price), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            if (product['enable_stock'] == true)
              Text(isLowStock ? 'Stock: $totalStock' : 'Stock: $totalStock', style: TextStyle(fontSize: 11, color: isLowStock ? Colors.red : Colors.grey[600])),
          ])),
        ]),
      ),
    );
  }
}

