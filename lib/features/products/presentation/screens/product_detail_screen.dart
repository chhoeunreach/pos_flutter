import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/utils/product_variation_utils.dart';

class ProductDetailScreen extends StatelessWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final product = MockData.products.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{});
    if (product.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Product')), body: const Center(child: Text('Not found')));

    final variation = (product['variations'] as List?)?.isNotEmpty == true ? (product['variations'] as List).first as Map<String, dynamic> : null;
    final stockList = productStockList(product, variation);
    final locations = product['product_locations'] as List? ?? [];
    final sellPrice = (variation?['sell_price_inc_tax'] as num?)?.toDouble() ?? (product['default_selling_price'] as num?)?.toDouble() ?? 0;
    final purchasePrice = (variation?['default_purchase_price'] as num?)?.toDouble() ?? (product['default_purchase_price'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(product['name'] ?? ''), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/products/$id/edit'))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: product['image_url'] != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(product['image_url'], fit: BoxFit.cover))
                : Icon(Icons.inventory_2, size: 60, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(product['sku'] ?? '', style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 24),
        _infoRow(context, 'Category', (product['category'] as Map?)?.let((c) => c['name'] as String) ?? '-'),
        _infoRow(context, 'Brand', (product['brand'] as Map?)?.let((b) => b['name'] as String) ?? '-'),
        _infoRow(context, 'Unit', productUnitLabel(product)),
        _infoRow(context, 'Type', product['type'] ?? 'single'),
        const Divider(height: 24),
        _infoRow(context, 'Selling Price', MoneyFormatter.instance.format(sellPrice), bold: true),
        _infoRow(context, 'Purchase Price', MoneyFormatter.instance.format(purchasePrice)),
        _infoRow(context, 'Tax Type', product['tax_type'] ?? 'exclusive'),
        if (product['enable_stock'] == true) ...[
          const Divider(height: 24),
          Text('Stock by Location', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...stockList.map((s) {
            final loc = s as Map<String, dynamic>;
            final locName = locations.cast<Map<String, dynamic>?>().firstWhere(
              (l) => l?['id'] == loc['location_id'], orElse: () => null);
            return _infoRow(context, locName?['name'] as String? ?? 'Location ${loc['location_id']}', '${(loc['qty_available'] as num?)?.toDouble() ?? 0}');
          }),
        ],
      ])),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    ]));
}

extension _MapLet on Map? {
  T? let<T>(T Function(Map) fn) { if (this == null) return null; return fn(this!); }
}
