import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/repositories/interfaces.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../products/presentation/widgets/product_search_dialog.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  late Future<List<Map<String, dynamic>>> _transfersFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _transfersFuture = sl<StockRepository>().getTransfers();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const StockTransferFormScreen()),
    );
    if (created == true && mounted) {
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_load),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('New Transfer'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transfersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(fullScreen: true);
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(_load),
            );
          }
          final transfers = snapshot.data ?? [];
          if (transfers.isEmpty) {
            return const AppEmptyWidget(
              message: 'No transfers found',
              icon: Icons.swap_horiz,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: transfers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _TransferCard(transfer: transfers[index]),
            ),
          );
        },
      ),
    );
  }
}

class StockTransferFormScreen extends StatefulWidget {
  const StockTransferFormScreen({super.key});

  @override
  State<StockTransferFormScreen> createState() =>
      _StockTransferFormScreenState();
}

class _StockTransferFormScreenState extends State<StockTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _shippingController = TextEditingController(text: '0');
  final List<_TransferLine> _lines = [];
  DateTime _date = DateTime.now();
  int? _sourceLocationId;
  int? _destinationLocationId;
  bool _isSaving = false;
  String? _error;

  List<Map<String, dynamic>> get _locations => sl<AuthBloc>().state.locations;

  @override
  void initState() {
    super.initState();
    final locations = _locations;
    if (locations.isNotEmpty) {
      _sourceLocationId = _asInt(locations.first['id']);
      if (locations.length > 1) {
        _destinationLocationId = _asInt(locations[1]['id']);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _shippingController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _addProduct() async {
    final products = await sl<ProductRepository>().getAll();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => ProductSearchDialog(
        products: products,
        onSearch: (query) => sl<ProductRepository>().getAll(search: query),
        onSelected: (product) {
          final variation = _firstVariation(product);
          final variationId =
              _asInt(variation['id']) ?? _asInt(product['variation_id']);
          if (variationId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This product has no variation id')),
            );
            return;
          }
          setState(() {
            _lines.add(_TransferLine(
              productId: _asInt(product['id']) ?? 0,
              variationId: variationId,
              name: product['name']?.toString() ?? '',
              sku: variation['sub_sku']?.toString() ??
                  product['sku']?.toString() ??
                  '',
              unit: ((product['unit'] as Map?)?['short_name'] ??
                      product['unit_name'] ??
                      'pcs')
                  .toString(),
              unitCost: _asDouble(variation['default_purchase_price']) ??
                  _asDouble(product['default_purchase_price']) ??
                  _asDouble(variation['default_sell_price']) ??
                  0,
            ));
          });
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceLocationId == null || _destinationLocationId == null) {
      setState(() => _error = 'Please select source and destination locations');
      return;
    }
    if (_sourceLocationId == _destinationLocationId) {
      setState(() => _error = 'Destination must be different from source');
      return;
    }
    if (_lines.isEmpty) {
      setState(() => _error = 'Please add at least one product');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final payload = {
        'location_id': _sourceLocationId,
        'transfer_location_id': _destinationLocationId,
        'transaction_date': _yyyyMmDd(_date),
        'shipping_charges': _asDouble(_shippingController.text) ?? 0,
        'additional_notes': _notesController.text.trim(),
        'products': _lines
            .map((line) => {
                  'product_id': line.productId,
                  'variation_id': line.variationId,
                  'quantity': _asDouble(line.qtyController.text) ?? 0,
                  'unit_cost': _asDouble(line.costController.text) ?? 0,
                })
            .toList(),
      };
      final res = await sl<StockRepository>().transfer(payload);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Transfer failed');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Transfer saved')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double get _total => _lines.fold<double>(
        0,
        (sum, line) =>
            sum +
            ((_asDouble(line.qtyController.text) ?? 0) *
                (_asDouble(line.costController.text) ?? 0)),
      );

  @override
  Widget build(BuildContext context) {
    final locations = _locations;
    return Scaffold(
      appBar: AppBar(title: const Text('New Transfer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red[800])),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _sourceLocationId,
                      decoration: const InputDecoration(
                        labelText: 'From Location *',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: locations
                          .map((l) => DropdownMenuItem(
                                value: _asInt(l['id']),
                                child: Text(l['name']?.toString() ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _sourceLocationId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _destinationLocationId,
                      decoration: const InputDecoration(
                        labelText: 'To Location *',
                        prefixIcon: Icon(Icons.storefront),
                      ),
                      items: locations
                          .map((l) => DropdownMenuItem(
                                value: _asInt(l['id']),
                                child: Text(l['name']?.toString() ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _destinationLocationId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transfer Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_yyyyMmDd(_date)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _shippingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Shipping Charges',
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Products', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_lines.isEmpty)
              const AppEmptyWidget(
                message: 'Add products to transfer',
                icon: Icons.inventory_2_outlined,
              )
            else
              ..._lines.asMap().entries.map(
                    (entry) => _TransferLineCard(
                      index: entry.key,
                      line: entry.value,
                      onChanged: () => setState(() {}),
                      onRemove: () => setState(() {
                        entry.value.dispose();
                        _lines.removeAt(entry.key);
                      }),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Total ${MoneyFormatter.instance.format(_total)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Save Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final Map<String, dynamic> transfer;

  const _TransferCard({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final parent = transfer['transfer_parent'] as Map?;
    final location = transfer['location'] as Map?;
    final type = transfer['type']?.toString() ?? '';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type == 'sell_transfer'
              ? Colors.blue.shade50
              : Colors.green.shade50,
          child: Icon(
            type == 'sell_transfer' ? Icons.north_east : Icons.south_west,
            color: type == 'sell_transfer' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(transfer['ref_no']?.toString() ?? 'Transfer'),
        subtitle: Text([
          location?['name']?.toString(),
          parent?['ref_no']?.toString(),
          transfer['transaction_date']?.toString(),
        ].whereType<String>().where((v) => v.isNotEmpty).join(' | ')),
        trailing: Text(
          type.replaceAll('_', ' ').toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _TransferLineCard extends StatelessWidget {
  final int index;
  final _TransferLine line;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _TransferLineCard({
    required this.index,
    required this.line,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final qty = _asDouble(line.qtyController.text) ?? 0;
    final cost = _asDouble(line.costController.text) ?? 0;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade50,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('SKU: ${line.sku} | ${line.unit}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty *'),
                    onChanged: (_) => onChanged(),
                    validator: (v) =>
                        ((_asDouble(v) ?? 0) <= 0) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: line.costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Unit Cost'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 92,
                  child: Text(
                    MoneyFormatter.instance.format(qty * cost),
                    textAlign: TextAlign.end,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferLine {
  final int productId;
  final int variationId;
  final String name;
  final String sku;
  final String unit;
  final TextEditingController qtyController;
  final TextEditingController costController;

  _TransferLine({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.sku,
    required this.unit,
    required double unitCost,
  })  : qtyController = TextEditingController(text: '1'),
        costController =
            TextEditingController(text: unitCost.toStringAsFixed(2));

  void dispose() {
    qtyController.dispose();
    costController.dispose();
  }
}

Map<String, dynamic> _firstVariation(Map<String, dynamic> product) {
  final variations = product['variations'] as List? ?? [];
  if (variations.isNotEmpty && variations.first is Map) {
    return Map<String, dynamic>.from(variations.first as Map);
  }
  return {};
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().replaceAll(',', '') ?? '');
}

String _yyyyMmDd(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
