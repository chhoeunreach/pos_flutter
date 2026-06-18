import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/product_variation_utils.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/sku_chip.dart';
import '../widgets/cart_widget.dart';
import '../widgets/payment_sheet.dart';

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
  int? _selectedCategoryId;
  int? _selectedBrandId;
  bool _showFeaturedOnly = false;

  @override
  void initState() {
    super.initState();
    sl<PosBloc>().add(LoadPosSettingsEvent());
    sl<ProductBloc>().add(LoadCategoriesEvent());
    sl<ProductBloc>().add(LoadBrandsEvent());
    _loadProducts();
  }

  void _loadProducts() => sl<ProductBloc>().add(LoadProductsEvent(
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        locationId: sl<AuthBloc>().state.selectedLocationId,
      ));

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
    if (wide) {
      return BlocProvider.value(
          value: sl<PosBloc>(), child: _buildDesktopLayout());
    }
    if (_showCart) {
      return BlocProvider.value(
          value: sl<PosBloc>(), child: _buildCartScreen());
    }
    return BlocProvider.value(
        value: sl<PosBloc>(), child: _buildPhoneProductScreen());
  }

  Widget _buildPhoneProductScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('POS'), actions: [
        BlocBuilder<PosBloc, PosState>(
            builder: (context, s) => Badge(
                  label: Text('${s.items.length}'),
                  child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => setState(() => _showCart = true)),
                )),
      ]),
      body: Column(children: [
        _buildSearchBar(),
        Expanded(child: _buildProductGrid()),
      ]),
    );
  }

  Widget _buildCartScreen() => Scaffold(
        appBar: AppBar(
            title: const Text('Cart'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showCart = false))),
        body: const CartWidget(),
      );

  Widget _buildDesktopLayout() => Scaffold(
        backgroundColor: const Color(0xffeef2f7),
        body: Column(
          children: [
            _buildPosToolbar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildOrderPanel()),
                    const SizedBox(width: 6),
                    Expanded(flex: 2, child: _buildProductPanel()),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      );

  Widget _buildPosToolbar() {
    final locations = sl<AuthBloc>().state.locations;
    final selectedLocation = sl<AuthBloc>().state.selectedLocation;
    final locationName =
        selectedLocation?['name']?.toString() ?? 'All locations';
    final now = DateTime.now();
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('Location:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 8),
          SizedBox(
            width: 230,
            child: DropdownButtonFormField<int>(
              initialValue: _asInt(selectedLocation?['id']),
              isDense: true,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                border: OutlineInputBorder(),
              ),
              hint: Text(locationName, overflow: TextOverflow.ellipsis),
              items: locations
                  .map((location) => DropdownMenuItem(
                        value: _asInt(location['id']),
                        child: Text(location['name']?.toString() ?? '',
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                sl<AuthBloc>().add(SelectLocationEvent(value));
                _loadProducts();
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text(
                  '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard, size: 16, color: Colors.white70),
              ],
            ),
          ),
          const Spacer(),
          _toolbarButton(Icons.arrow_back_ios_new, 'Back',
              onTap: () => context.go('/')),
          _toolbarButton(Icons.undo, 'Undo'),
          _toolbarButton(Icons.pause, 'Hold'),
          _toolbarButton(Icons.work_outline, 'Register'),
          _toolbarButton(Icons.cancel_outlined, 'Cancel'),
          _toolbarButton(Icons.calculate_outlined, 'Calculator'),
          _toolbarButton(Icons.fullscreen, 'Fullscreen'),
          _toolbarButton(Icons.monitor_outlined, 'Display'),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: FilledButton.icon(
              onPressed: () => context.go('/expenses/create'),
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              label: const Text('Add Expense'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbarButton(IconData icon, String tooltip, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 42,
          height: 40,
          child: OutlinedButton(
            onPressed: onTap ?? () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Icon(icon, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderPanel() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'walk_in',
                        isDense: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person, size: 18),
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'walk_in',
                              child: Text('Walk-In Customer')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 6),
                    _smallSquareButton(Icons.add_circle, Colors.blue),
                    const SizedBox(width: 6),
                    _smallSquareButton(Icons.payments, Colors.blue),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildSearchBar(compact: true)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: 'service',
                        isDense: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.open_in_new, size: 18),
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'service',
                              child: Text('Select types of service')),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          const Expanded(child: CartWidget(showActions: false)),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        final hasCart = state.items.isNotEmpty;
        return Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: _bottomActionButton(
                  label: 'Cancel',
                  icon: Icons.cancel,
                  color: Colors.red,
                  filled: false,
                  onTap: hasCart ? _confirmClearCart : null,
                ),
              ),
              const SizedBox(width: 20),
              _bottomTextAction('Draft', Icons.edit_square, Colors.blue,
                  onTap: () => _notReady('Draft sale')),
              _bottomTextAction('Quotation', Icons.edit_note, Colors.amber,
                  onTap: () => _notReady('Quotation')),
              _bottomTextAction('Suspend', Icons.pause, Colors.red,
                  onTap: () => _notReady('Suspend sale')),
              _bottomTextAction('Credit Sale', Icons.check, Colors.indigo,
                  onTap: () => _notReady('Credit sale')),
              _bottomTextAction('Card', Icons.credit_card, Colors.pink,
                  onTap: hasCart ? () => _showPayment(method: 'card') : null),
              const SizedBox(width: 14),
              SizedBox(
                width: 150,
                child: _bottomActionButton(
                  label: 'Multiple Pay',
                  icon: Icons.payments,
                  color: const Color(0xff263f58),
                  filled: true,
                  onTap: hasCart ? () => _showPayment(method: 'cash') : null,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 140,
                child: _bottomActionButton(
                  label: 'Cash',
                  icon: Icons.money,
                  color: const Color(0xff43c78c),
                  filled: true,
                  onTap: hasCart ? () => _showPayment(method: 'cash') : null,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 190,
                child: _bottomActionButton(
                  label: 'Recent Transactions',
                  icon: Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  filled: true,
                  onTap: () => context.go('/sales'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomTextAction(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    final enabled = onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: SizedBox(
            width: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return SizedBox(
      height: 42,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label, overflow: TextOverflow.ellipsis),
              style: FilledButton.styleFrom(
                backgroundColor: enabled ? color : Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(label, overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                foregroundColor: enabled ? color : Colors.grey,
                side: BorderSide(color: enabled ? color : Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
    );
  }

  Future<void> _confirmClearCart() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Sale'),
        content: const Text('Clear all products from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear == true) {
      sl<PosBloc>().add(ClearCartEvent());
    }
  }

  void _showPayment({required String method}) {
    final state = sl<PosBloc>().state;
    if (state.items.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(
        value: sl<PosBloc>(),
        child: PaymentSheet(total: state.total, initialMethod: method),
      ),
    );
  }

  void _notReady(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not connected to the API yet')),
    );
  }

  Widget _smallSquareButton(IconData icon, Color color) {
    return SizedBox(
      width: 42,
      height: 38,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildProductPanel() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildProductFilters(),
          Expanded(child: _buildProductGrid(panelMode: true)),
        ],
      ),
    );
  }

  Widget _buildProductFilters() {
    return BlocProvider<ProductBloc>.value(
      value: sl<ProductBloc>(),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                _filterPill(Icons.grid_view, 'Category',
                    count: state.categories.length,
                    active: _selectedCategoryId != null,
                    onTap: () => _showCategoryPicker(state.categories)),
                const SizedBox(width: 8),
                _filterPill(Icons.local_offer_outlined, 'Brands',
                    count: state.brands.length,
                    active: _selectedBrandId != null,
                    onTap: () => _showBrandPicker(state.brands)),
                const SizedBox(width: 8),
                _filterPill(
                  _showFeaturedOnly ? Icons.star : Icons.star_border,
                  'Featured Products',
                  active: _showFeaturedOnly,
                  onTap: () =>
                      setState(() => _showFeaturedOnly = !_showFeaturedOnly),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterPill(IconData icon, String label,
      {int? count, bool active = false, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? Colors.blue.shade50 : Colors.white,
            border: Border.all(
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (count != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCategoryPicker(
      List<Map<String, dynamic>> categories) async {
    final selected = await _showFilterPicker(
      title: 'Category',
      items: categories,
      selectedId: _selectedCategoryId,
    );
    if (selected == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = selected);
    _loadProducts();
  }

  Future<void> _showBrandPicker(List<Map<String, dynamic>> brands) async {
    final selected = await _showFilterPicker(
      title: 'Brands',
      items: brands,
      selectedId: _selectedBrandId,
    );
    if (selected == _selectedBrandId) return;
    setState(() => _selectedBrandId = selected);
    _loadProducts();
  }

  Future<int?> _showFilterPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required int? selectedId,
  }) {
    return showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('All'),
                trailing: selectedId == null
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () => Navigator.pop(context, null),
              ),
              ...items.map((item) {
                final id = _asInt(item['id']);
                return ListTile(
                  title: Text(item['name']?.toString() ?? ''),
                  subtitle: item['short_code'] == null
                      ? null
                      : Text(item['short_code'].toString()),
                  trailing: id == selectedId
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => Navigator.pop(context, id),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, selectedId),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({bool compact = false}) => Padding(
        padding: compact ? EdgeInsets.zero : const EdgeInsets.all(8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            isDense: compact,
            hintText: 'Search by name, SKU, or barcode...',
            prefixIcon: const Icon(Icons.search),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _loadProducts();
                      setState(() {});
                    })
                : null,
          ),
          onChanged: (v) {
            setState(() {});
            _searchDebounce?.cancel();
            _searchDebounce =
                Timer(const Duration(milliseconds: 400), _loadProducts);
          },
        ),
      );

  Widget _buildProductGrid({bool panelMode = false}) {
    return BlocProvider<ProductBloc>.value(
      value: sl<ProductBloc>(),
      child: BlocBuilder<ProductBloc, ProductState>(builder: (context, state) {
        if (state.isLoading) return const LoadingWidget();
        if (state.error != null) {
          return AppErrorWidget(message: state.error!, onRetry: _loadProducts);
        }
        final sourceProducts = _showFeaturedOnly
            ? state.products.where(_isFeaturedProduct).toList()
            : state.products;
        final products =
            sourceProducts.expand(productVariationOptions).toList();
        if (products.isEmpty) {
          return const AppEmptyWidget(
              message: 'No products found', icon: Icons.search_off);
        }
        final width = MediaQuery.of(context).size.width;
        final gridWidth = panelMode ? (width - 232) * 0.4 : width;
        final columns = panelMode
            ? (gridWidth >= 760 ? 4 : 3)
            : gridWidth >= 1050
                ? 4
                : gridWidth >= 720
                    ? 3
                    : 2;
        return GridView.builder(
          controller: _productScrollController,
          padding: EdgeInsets.fromLTRB(10, panelMode ? 0 : 8, 10, 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: panelMode ? 1.28 : 0.82,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              _buildProductCard(products[index], compact: panelMode),
        );
      }),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product,
      {bool compact = false}) {
    final name = product['name']?.toString() ?? '';
    final variation = _firstVariation(product);
    final variationName = variationDisplayName(variation);
    final displayName = productDisplayName(product, variation);
    final productId = _asInt(product['id']) ?? 0;
    final variationId =
        _asInt(variation['id']) ?? _asInt(product['variation_id']) ?? 0;
    final price = _asDouble(variation['sell_price_inc_tax']) ??
        _asDouble(variation['default_sell_price']) ??
        _asDouble(product['default_selling_price']) ??
        _asDouble(product['selling_price']) ??
        0;
    final basePrice = _asDouble(variation['default_sell_price']) ?? price;
    final stockList = (variation['stock'] as List?) ??
        (variation['variation_location_details'] as List?) ??
        (product['stock_details'] as List?) ??
        const [];
    final totalStock = _stockTotal(stockList);
    final alertQty = _asDouble(product['alert_quantity']) ?? 0;
    final enableStock = _asBool(product['enable_stock']);
    final isLowStock = enableStock && totalStock <= alertQty;
    final sku =
        variation['sub_sku']?.toString() ?? product['sku']?.toString() ?? '';
    final unit = ((product['unit'] as Map?)?['short_name'] ??
            product['unit_name'] ??
            product['unit'] ??
            'pcs')
        .toString();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (productId == 0 || variationId == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product variation is missing')),
            );
            return;
          }
          sl<PosBloc>().add(AddToCartEvent(CartItem(
            productId: productId,
            variationId: variationId,
            name: displayName,
            sku: sku,
            price: basePrice,
            priceIncTax: price,
            image: product['image_url']?.toString(),
            unit: unit,
            taxId: _asInt(product['tax']),
            itemTax: 0,
          )));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$name added to cart'),
              duration: const Duration(seconds: 1)));
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8))),
                  child: Center(
                      child: Icon(Icons.image_outlined,
                          size: compact ? 30 : 48, color: Colors.grey[350])))),
          Padding(
              padding: EdgeInsets.all(compact ? 6 : 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700),
                      maxLines: compact ? 2 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (variationName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        variationName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.deepPurple.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (sku.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Center(child: SkuChip(sku: sku, dense: true)),
                    ],
                    if (enableStock)
                      Text('${_formatQty(totalStock)} $unit(s) in stock',
                          style: TextStyle(
                              fontSize: 10,
                              color:
                                  isLowStock ? Colors.red : Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text(
                      MoneyFormatter.instance.format(price),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: price > 0
                              ? Colors.green.shade700
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.bold),
                    ),
                  ])),
        ]),
      ),
    );
  }
}

bool _isFeaturedProduct(Map<String, dynamic> product) {
  for (final key in const [
    'is_featured',
    'featured',
    'is_featured_product',
    'show_in_pos',
  ]) {
    if (_asBool(product[key])) return true;
  }
  return false;
}

Map<String, dynamic> _firstVariation(Map<String, dynamic> product) {
  return firstProductVariation(product);
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '').trim());
  if (value is Map) {
    for (final key in const ['amount', 'value', 'total', 'qty_available']) {
      final parsed = _asDouble(value[key]);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes';
}

double _stockTotal(List stockList) {
  return stockList.fold<double>(0, (sum, item) {
    if (item is! Map) return sum;
    final direct = _asDouble(item['qty_available']);
    if (direct != null) return sum + direct;
    final locations = item['locations'];
    if (locations is List) return sum + _stockTotal(locations);
    return sum;
  });
}

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
