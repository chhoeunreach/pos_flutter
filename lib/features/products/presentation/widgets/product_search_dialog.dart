import 'package:flutter/material.dart';

import '../../../../core/utils/product_variation_utils.dart';
import '../../../../core/widgets/sku_chip.dart';

class ProductSearchDialog extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Future<List<Map<String, dynamic>>> Function(String query)? onSearch;
  final void Function(Map<String, dynamic> product) onSelected;

  const ProductSearchDialog({
    super.key,
    required this.products,
    this.onSearch,
    required this.onSelected,
  });

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _filtered = [];
  bool _isSearching = false;
  int _searchVersion = 0;

  @override
  void initState() {
    super.initState();
    _filtered = _expandProductOptions(widget.products);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _filter(String query) async {
    final version = ++_searchVersion;
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      setState(() {
        _filtered = _expandProductOptions(widget.products);
        _isSearching = false;
      });
      return;
    }

    final localProducts = _expandProductOptions(widget.products);
    final localMatches = localProducts
        .where((product) => _searchText(product).contains(q))
        .toList();
    setState(() {
      _filtered = localMatches;
      _isSearching = widget.onSearch != null;
    });

    if (widget.onSearch == null) return;

    try {
      final remoteProducts = await widget.onSearch!(query.trim());
      if (!mounted || version != _searchVersion) return;
      final combined = <String, Map<String, dynamic>>{};
      for (final product in [
        ...localMatches,
        ..._expandProductOptions(remoteProducts)
      ]) {
        final key = _productKey(product);
        combined[key] = product;
      }
      setState(() {
        _filtered = combined.values
            .where((product) => _searchText(product).contains(q))
            .toList();
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted || version != _searchVersion) return;
      setState(() => _isSearching = false);
    }
  }

  String _productKey(Map<String, dynamic> product) {
    final id = product['id']?.toString();
    final variation = firstProductVariation(product);
    final variationId = variation['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return variationId == null || variationId.isEmpty
          ? 'id:$id'
          : 'id:$id:$variationId';
    }

    final sku = product['sku']?.toString();
    if (sku != null && sku.isNotEmpty) return 'sku:$sku';

    return 'product:${product.hashCode}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              onChanged: _filter,
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No products found'),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = _filtered[i];
                  final variation = firstProductVariation(p);
                  return ListTile(
                    dense: true,
                    title: Text(productDisplayName(p, variation)),
                    subtitle: _ProductSearchMeta(product: p),
                    trailing: Text(_formatPrice(p['default_selling_price'])),
                    onTap: () {
                      widget.onSelected(p);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(dynamic value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  return parsed == null ? '-' : '\$${parsed.toStringAsFixed(2)}';
}

class _ProductSearchMeta extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductSearchMeta({required this.product});

  @override
  Widget build(BuildContext context) {
    final variation = firstProductVariation(product);
    final sku =
        variation['sub_sku']?.toString() ?? product['sku']?.toString() ?? '';
    final lotNumbers = _lotNumbers(product);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SkuChip(sku: sku, dense: true),
          if (lotNumbers.isNotEmpty)
            Text(
              'Lots: ${lotNumbers.join(', ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

String _searchText(dynamic value) {
  final pieces = <String>[];
  void visit(dynamic current) {
    if (current == null) return;
    if (current is Map) {
      for (final entry in current.entries) {
        pieces.add(entry.key.toString());
        visit(entry.value);
      }
      return;
    }
    if (current is Iterable) {
      for (final item in current) {
        visit(item);
      }
      return;
    }
    pieces.add(current.toString());
  }

  visit(value);
  return pieces.join(' ').toLowerCase();
}

List<String> _lotNumbers(Map<String, dynamic> product) {
  final lots = <String>{};
  void visit(dynamic current) {
    if (current is Map) {
      for (final entry in current.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('lot')) {
          final value = entry.value?.toString();
          if (value != null && value.isNotEmpty && value != 'null') {
            lots.add(value);
          }
        }
        visit(entry.value);
      }
    } else if (current is Iterable) {
      for (final item in current) {
        visit(item);
      }
    }
  }

  visit(product);
  return lots.toList();
}

List<Map<String, dynamic>> _expandProductOptions(
    List<Map<String, dynamic>> products) {
  return products.expand(productVariationOptions).toList();
}
