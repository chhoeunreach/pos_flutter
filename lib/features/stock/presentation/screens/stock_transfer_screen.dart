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
    if (created == true && mounted) setState(_load);
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

          final rows = _tableRows(snapshot.data ?? []);
          if (rows.isEmpty) {
            return const AppEmptyWidget(
              message: 'No transfers found',
              icon: Icons.swap_horiz,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [_TransferTable(rows: rows)],
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
  final List<_TransferProduct> _products = [];
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
    for (final product in _products) {
      product.dispose();
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
            _showSnack('This product has no variation id');
            return;
          }
          setState(() {
            _products.add(_TransferProduct(
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
    if (_products.isEmpty) {
      setState(() => _error = 'Please add at least one product');
      return;
    }

    final lines = <Map<String, dynamic>>[];
    for (final product in _products) {
      for (final lot in product.lots) {
        final qty = _asDouble(lot.qtyController.text) ?? 0;
        if (qty <= 0) continue;
        lines.add({
          'product_id': product.productId,
          'variation_id': product.variationId,
          'quantity': qty,
          'unit_cost': _asDouble(lot.costController.text) ?? 0,
          'lot_number': lot.lotController.text.trim(),
        });
      }
    }

    if (lines.isEmpty) {
      setState(() => _error = 'Add at least one lot with quantity');
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
        'products': lines,
      };
      final res = await sl<StockRepository>().transfer(payload);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Transfer failed');
      }
      if (!mounted) return;
      _showSnack(res['message']?.toString() ?? 'Transfer saved');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double get _total => _products.fold<double>(
        0,
        (sum, product) => sum + product.total,
      );

  double get _quantity => _products.fold<double>(
        0,
        (sum, product) => sum + product.quantity,
      );

  @override
  Widget build(BuildContext context) {
    final locations = _locations;
    return Scaffold(
      appBar: AppBar(title: const Text('New Transfer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            if (_error != null) _errorBanner(),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
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
                            onChanged: (v) =>
                                setState(() => _sourceLocationId = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Transfer Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_yyyyMmDd(_date)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _shippingController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Shipping Charges',
                              prefixIcon: Icon(Icons.local_shipping),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
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
                const SizedBox(width: 12),
                Text(
                  '${_products.length} products | ${_formatQty(_quantity)} qty',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_products.isEmpty)
              const AppEmptyWidget(
                message: 'Add products to transfer',
                icon: Icons.inventory_2_outlined,
              )
            else
              ..._products.asMap().entries.map(
                    (entry) => _TransferProductCard(
                      index: entry.key,
                      product: entry.value,
                      onChanged: () => setState(() {}),
                      onAddLot: () => setState(entry.value.addLot),
                      onRemove: () => setState(() {
                        entry.value.dispose();
                        _products.removeAt(entry.key);
                      }),
                      onDuplicateLot: (lotIndex) =>
                          setState(() => entry.value.duplicateLot(lotIndex)),
                      onRemoveLot: (lotIndex) =>
                          setState(() => entry.value.removeLot(lotIndex)),
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
                  'Qty ${_formatQty(_quantity)}  |  Total ${MoneyFormatter.instance.format(_total)}',
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

  Widget _errorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_error!, style: TextStyle(color: Colors.red[800])),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TransferTable extends StatelessWidget {
  final List<_TransferTableRow> rows;

  const _TransferTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontWeight: FontWeight.w800);
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 42,
          dataRowMaxHeight: 54,
          columnSpacing: 18,
          headingTextStyle: headerStyle,
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Quantity'), numeric: true),
            DataColumn(label: Text('Location (From)')),
            DataColumn(label: Text('Location (To)')),
            DataColumn(label: Text('Invoice No.')),
            DataColumn(label: Text('Added By')),
            DataColumn(label: Text('Additional Notes')),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(_smallText(row.date, width: 120)),
                    DataCell(_smallText(row.sku, width: 100)),
                    DataCell(_smallText(row.product, width: 180)),
                    DataCell(Text(_formatQty(row.quantity))),
                    DataCell(_smallText(row.fromLocation, width: 150)),
                    DataCell(_smallText(row.toLocation, width: 150)),
                    DataCell(_smallText(row.invoiceNo, width: 120)),
                    DataCell(_smallText(row.addedBy, width: 120)),
                    DataCell(_smallText(row.notes, width: 200)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _smallText(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        value.isEmpty ? '-' : value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _TransferProductCard extends StatelessWidget {
  final int index;
  final _TransferProduct product;
  final VoidCallback onChanged;
  final VoidCallback onAddLot;
  final VoidCallback onRemove;
  final void Function(int lotIndex) onDuplicateLot;
  final void Function(int lotIndex) onRemoveLot;

  const _TransferProductCard({
    required this.index,
    required this.product,
    required this.onChanged,
    required this.onAddLot,
    required this.onRemove,
    required this.onDuplicateLot,
    required this.onRemoveLot,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'SKU: ${product.sku} | ${product.unit} | ${product.lots.length} lot(s)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  MoneyFormatter.instance.format(product.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Remove product',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...product.lots.asMap().entries.map(
                  (entry) => _LotRowWidget(
                    number: entry.key + 1,
                    lot: entry.value,
                    canDelete: product.lots.length > 1,
                    onChanged: onChanged,
                    onDuplicate: () => onDuplicateLot(entry.key),
                    onRemove: () => onRemoveLot(entry.key),
                  ),
                ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onAddLot,
                icon: const Icon(Icons.add),
                label: const Text('Add Lot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotRowWidget extends StatelessWidget {
  final int number;
  final _TransferLot lot;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  const _LotRowWidget({
    required this.number,
    required this.lot,
    required this.canDelete,
    required this.onChanged,
    required this.onDuplicate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final qty = _asDouble(lot.qtyController.text) ?? 0;
    final cost = _asDouble(lot.costController.text) ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('$number',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: lot.lotController,
              decoration: const InputDecoration(labelText: 'Lot'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: lot.qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Qty *'),
              onChanged: (_) => onChanged(),
              validator: (v) => ((_asDouble(v) ?? 0) <= 0) ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: lot.costController,
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
          IconButton(
            tooltip: 'Duplicate lot',
            onPressed: onDuplicate,
            icon: const Icon(Icons.copy, size: 18),
          ),
          IconButton(
            tooltip: 'Remove lot',
            onPressed: canDelete ? onRemove : null,
            icon: const Icon(Icons.delete_outline, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TransferProduct {
  final int productId;
  final int variationId;
  final String name;
  final String sku;
  final String unit;
  final List<_TransferLot> lots;

  _TransferProduct({
    required this.productId,
    required this.variationId,
    required this.name,
    required this.sku,
    required this.unit,
    required double unitCost,
  }) : lots = [_TransferLot(unitCost: unitCost)];

  double get quantity => lots.fold(
      0, (sum, lot) => sum + (_asDouble(lot.qtyController.text) ?? 0));

  double get total => lots.fold<double>(
        0,
        (sum, lot) =>
            sum +
            ((_asDouble(lot.qtyController.text) ?? 0) *
                (_asDouble(lot.costController.text) ?? 0)),
      );

  void addLot() {
    final cost =
        lots.isEmpty ? 0.0 : (_asDouble(lots.last.costController.text) ?? 0.0);
    lots.add(_TransferLot(unitCost: cost));
  }

  void duplicateLot(int index) {
    lots.add(_TransferLot.fromExisting(lots[index]));
  }

  void removeLot(int index) {
    if (lots.length <= 1) return;
    lots[index].dispose();
    lots.removeAt(index);
  }

  void dispose() {
    for (final lot in lots) {
      lot.dispose();
    }
  }
}

class _TransferLot {
  final lotController = TextEditingController();
  final qtyController = TextEditingController(text: '1');
  final costController = TextEditingController();

  _TransferLot({required double unitCost}) {
    costController.text = unitCost.toStringAsFixed(2);
  }

  _TransferLot.fromExisting(_TransferLot other) {
    lotController.text = other.lotController.text;
    qtyController.text = other.qtyController.text;
    costController.text = other.costController.text;
  }

  void dispose() {
    lotController.dispose();
    qtyController.dispose();
    costController.dispose();
  }
}

class _TransferTableRow {
  final String date;
  final String sku;
  final String product;
  final double quantity;
  final String fromLocation;
  final String toLocation;
  final String invoiceNo;
  final String addedBy;
  final String notes;

  const _TransferTableRow({
    required this.date,
    required this.sku,
    required this.product,
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.invoiceNo,
    required this.addedBy,
    required this.notes,
  });
}

List<_TransferTableRow> _tableRows(List<Map<String, dynamic>> transfers) {
  final rows = <_TransferTableRow>[];
  for (final transfer in transfers) {
    final location = transfer['location'] as Map?;
    final destination = transfer['transfer_parent'] as Map?;
    final createdBy = transfer['created_by_user'] as Map?;
    final lines = _lineList(transfer);

    if (lines.isEmpty) {
      rows.add(_TransferTableRow(
        date: transfer['transaction_date']?.toString() ?? '',
        sku: '',
        product: '',
        quantity: 0,
        fromLocation: location?['name']?.toString() ?? '',
        toLocation: (destination?['location'] as Map?)?['name']?.toString() ??
            destination?['location_name']?.toString() ??
            '',
        invoiceNo: transfer['ref_no']?.toString() ?? '',
        addedBy: _userName(createdBy),
        notes: transfer['additional_notes']?.toString() ?? '',
      ));
      continue;
    }

    for (final line in lines) {
      final product = line['product'] as Map?;
      final variation = (line['variations'] ?? line['variation']) as Map?;
      rows.add(_TransferTableRow(
        date: transfer['transaction_date']?.toString() ?? '',
        sku: variation?['sub_sku']?.toString() ??
            line['sub_sku']?.toString() ??
            product?['sku']?.toString() ??
            '',
        product: product?['name']?.toString() ??
            line['product_name']?.toString() ??
            '',
        quantity: _asDouble(line['quantity']) ?? 0,
        fromLocation: location?['name']?.toString() ?? '',
        toLocation: (destination?['location'] as Map?)?['name']?.toString() ??
            destination?['location_name']?.toString() ??
            '',
        invoiceNo: transfer['ref_no']?.toString() ?? '',
        addedBy: _userName(createdBy),
        notes: transfer['additional_notes']?.toString() ?? '',
      ));
    }
  }
  return rows;
}

List<Map<String, dynamic>> _lineList(Map<String, dynamic> transfer) {
  final lines = transfer['lines'] ?? transfer['sell_lines'];
  if (lines is List) {
    return lines
        .whereType<Map>()
        .map((line) => Map<String, dynamic>.from(line))
        .toList();
  }
  return const [];
}

String _userName(Map? user) {
  if (user == null) return '';
  return user['user_full_name']?.toString() ??
      user['full_name']?.toString() ??
      [
        user['surname']?.toString(),
        user['first_name']?.toString(),
        user['last_name']?.toString(),
      ].whereType<String>().where((v) => v.isNotEmpty).join(' ');
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

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _yyyyMmDd(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
