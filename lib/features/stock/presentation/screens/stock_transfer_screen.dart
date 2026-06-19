import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/repositories/interfaces.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/product_variation_utils.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/sku_chip.dart';
import '../../../products/presentation/widgets/product_search_dialog.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  late Future<List<Map<String, dynamic>>> _transfersFuture;
  int? _fromLocationId;
  int? _toLocationId;
  int? _productId;
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _productName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _transfersFuture = sl<StockRepository>().getTransfers(
      locationId: _fromLocationId,
      locationToId: _toLocationId,
      productId: _productId,
      status: _status,
      startDate: _startDate,
      endDate: _endDate,
    );
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
          final summary = _TransferSummary.fromRows(rows);

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                _buildFilterPanel(),
                const SizedBox(height: 12),
                _TransferSummaryCards(summary: summary),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  const AppEmptyWidget(
                    message: 'No transfers found',
                    icon: Icons.swap_horiz,
                  )
                else
                  _TransferTable(rows: rows),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel() {
    final locations = sl<AuthBloc>().state.locations;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final fields = [
                _locationFilter(
                  label: 'Location From',
                  value: _fromLocationId,
                  locations: locations,
                  onChanged: (value) {
                    setState(() {
                      _fromLocationId = value;
                      _load();
                    });
                  },
                ),
                _locationFilter(
                  label: 'Location To',
                  value: _toLocationId,
                  locations: locations,
                  onChanged: (value) {
                    setState(() {
                      _toLocationId = value;
                      _load();
                    });
                  },
                ),
                _statusFilter(),
                _dateRangeFilter(),
              ];
              if (compact) {
                return Column(
                  children: fields
                      .map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: field,
                          ))
                      .toList(),
                );
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: fields
                    .map((field) => SizedBox(width: 260, child: field))
                    .toList(),
              );
            }),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickProductFilter,
                  icon: const Icon(Icons.search),
                  label: Text(_productName ?? 'Product'),
                ),
                if (_productId != null)
                  IconButton.outlined(
                    tooltip: 'Clear product',
                    onPressed: () {
                      setState(() {
                        _productId = null;
                        _productName = null;
                        _load();
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationFilter({
    required String label,
    required int? value,
    required List<Map<String, dynamic>> locations,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      key: ValueKey('$label-$value-${locations.length}'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.store, size: 18),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('All')),
        ...locations.map((location) => DropdownMenuItem<int?>(
              value: _asInt(location['id']),
              child: Text(location['name']?.toString() ?? ''),
            )),
      ],
      onChanged: onChanged,
    );
  }

  Widget _statusFilter() {
    return DropdownButtonFormField<String?>(
      key: ValueKey('status-$_status'),
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.flag_outlined, size: 18),
      ),
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('All')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'in_transit', child: Text('In Transit')),
        DropdownMenuItem(value: 'completed', child: Text('Completed')),
      ],
      onChanged: (value) {
        setState(() {
          _status = value;
          _load();
        });
      },
    );
  }

  Widget _dateRangeFilter() {
    final label = _startDate == null || _endDate == null
        ? 'Date Range'
        : '${_yyyyMmDd(_startDate!)} - ${_yyyyMmDd(_endDate!)}';
    return OutlinedButton.icon(
      onPressed: _pickDateRange,
      icon: const Icon(Icons.date_range),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked.start;
      _endDate = picked.end;
      _load();
    });
  }

  Future<void> _pickProductFilter() async {
    final products = await sl<ProductRepository>().getAll();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => ProductSearchDialog(
        products: products,
        onSearch: (query) => sl<ProductRepository>().getAll(search: query),
        onSelected: (product) {
          setState(() {
            _productId = _asInt(product['id']);
            _productName = product['name']?.toString() ??
                productDisplayName(product, _firstVariation(product));
            _load();
          });
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _fromLocationId = null;
      _toLocationId = null;
      _productId = null;
      _productName = null;
      _status = null;
      _startDate = null;
      _endDate = null;
      _load();
    });
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
  final _refNoController = TextEditingController();
  final _notesController = TextEditingController();
  final _shippingController = TextEditingController(text: '0');
  final List<_TransferProduct> _products = [];
  DateTime _date = DateTime.now();
  int? _sourceLocationId;
  int? _destinationLocationId;
  String _status = 'completed';
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
    _refNoController.dispose();
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
              name: productDisplayName(product, variation),
              sku: variation['sub_sku']?.toString() ??
                  product['sku']?.toString() ??
                  '',
              unit: productUnitLabel(product),
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
        'ref_no': _refNoController.text.trim(),
        'status': _status,
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
                          child: InkWell(
                            onTap: _pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date *',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_yyyyMmDd(_date)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _refNoController,
                            decoration: const InputDecoration(
                              labelText: 'Reference No.',
                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _status,
                            decoration: const InputDecoration(
                              labelText: 'Status *',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(
                                  value: 'in_transit',
                                  child: Text('In Transit')),
                              DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Completed')),
                            ],
                            onChanged: (value) => setState(
                                () => _status = value ?? 'completed'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
            DataColumn(label: Text('Ref No.')),
            DataColumn(label: Text('Location From')),
            DataColumn(label: Text('Location To')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Total Qty'), numeric: true),
            DataColumn(label: Text('Shipping'), numeric: true),
            DataColumn(label: Text('Total Amount'), numeric: true),
            DataColumn(label: Text('Additional Notes')),
            DataColumn(label: Text('Action')),
          ],
          rows: rows
              .map(
                (row) => DataRow(
                  cells: [
                    DataCell(_smallText(row.date, width: 120)),
                    DataCell(_smallText(row.refNo, width: 130)),
                    DataCell(_smallText(row.fromLocation, width: 150)),
                    DataCell(_smallText(row.toLocation, width: 150)),
                    DataCell(_TransferStatusChip(status: row.status)),
                    DataCell(Text(_formatQty(row.totalQty))),
                    DataCell(Text(MoneyFormatter.instance.format(row.shipping))),
                    DataCell(Text(MoneyFormatter.instance.format(row.total))),
                    DataCell(_smallText(row.notes, width: 200)),
                    DataCell(_TransferActions(row: row)),
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

class _TransferSummaryCards extends StatelessWidget {
  final _TransferSummary summary;

  const _TransferSummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth < 720
          ? constraints.maxWidth
          : (constraints.maxWidth - 24) / 3;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _summaryCard(context, 'Transfers', summary.count.toString(),
              Icons.swap_horiz, Colors.indigo, width),
          _summaryCard(context, 'Total Qty', _formatQty(summary.totalQty),
              Icons.inventory_2_outlined, Colors.orange, width),
          _summaryCard(context, 'Total Amount',
              MoneyFormatter.instance.format(summary.totalAmount),
              Icons.payments_outlined, Colors.green, width),
        ],
      );
    });
  }

  Widget _summaryCard(BuildContext context, String label, String value,
      IconData icon, Color color, double width) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferStatusChip extends StatelessWidget {
  final String status;

  const _TransferStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status == 'final' ? 'completed' : status;
    final color = switch (normalized) {
      'completed' => Colors.green,
      'in_transit' => Colors.amber,
      'pending' => Colors.red,
      _ => Colors.grey,
    };
    final label = switch (normalized) {
      'completed' => 'Completed',
      'in_transit' => 'In Transit',
      'pending' => 'Pending',
      _ => normalized.isEmpty ? '-' : normalized,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransferActions extends StatelessWidget {
  final _TransferTableRow row;

  const _TransferActions({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'View',
          onPressed: () => _showTransferDetails(context, row),
          icon: const Icon(Icons.visibility_outlined, size: 18),
        ),
        IconButton(
          tooltip: 'Print',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print is available on web only')),
          ),
          icon: const Icon(Icons.print_outlined, size: 18),
        ),
      ],
    );
  }

  void _showTransferDetails(BuildContext context, _TransferTableRow row) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(row.refNo.isEmpty ? 'Transfer' : row.refNo),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Date', row.date),
              _detail('From', row.fromLocation),
              _detail('To', row.toLocation),
              _detail('Status', _statusLabel(row.status)),
              _detail('Total Qty', _formatQty(row.totalQty)),
              _detail('Shipping', MoneyFormatter.instance.format(row.shipping)),
              _detail('Total', MoneyFormatter.instance.format(row.total)),
              _detail('Added By', row.addedBy),
              _detail('Notes', row.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
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
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SkuChip(sku: product.sku, dense: true),
                          Text(product.unit,
                              style: Theme.of(context).textTheme.bodySmall),
                          Text('${product.lots.length} lot(s)',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
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
  final String refNo;
  final String fromLocation;
  final String toLocation;
  final String status;
  final double totalQty;
  final double shipping;
  final double total;
  final String addedBy;
  final String notes;

  const _TransferTableRow({
    required this.date,
    required this.refNo,
    required this.fromLocation,
    required this.toLocation,
    required this.status,
    required this.totalQty,
    required this.shipping,
    required this.total,
    required this.addedBy,
    required this.notes,
  });
}

class _TransferSummary {
  final int count;
  final double totalQty;
  final double totalAmount;

  const _TransferSummary({
    required this.count,
    required this.totalQty,
    required this.totalAmount,
  });

  factory _TransferSummary.fromRows(List<_TransferTableRow> rows) {
    return _TransferSummary(
      count: rows.length,
      totalQty: rows.fold(0, (sum, row) => sum + row.totalQty),
      totalAmount: rows.fold(0, (sum, row) => sum + row.total),
    );
  }
}

List<_TransferTableRow> _tableRows(List<Map<String, dynamic>> transfers) {
  final rows = <_TransferTableRow>[];
  for (final transfer in transfers) {
    final location = transfer['location'] as Map?;
    final destination = transfer['transfer_parent'] as Map?;
    final createdBy = transfer['created_by_user'] as Map?;
    final lines = _lineList(transfer);
    final toLocation =
        transfer['location_to']?.toString().trim().isNotEmpty == true
            ? transfer['location_to'].toString()
            : (destination?['location'] as Map?)?['name']?.toString() ??
                destination?['location_name']?.toString() ??
                '';
    final totalQty = _asDouble(transfer['total_qty']) ??
        lines.fold<double>(
            0, (sum, line) => sum + (_asDouble(line['quantity']) ?? 0));
    rows.add(_TransferTableRow(
      date: transfer['transaction_date']?.toString() ?? '',
      refNo: transfer['ref_no']?.toString() ?? '',
      fromLocation: transfer['location_from']?.toString() ??
          location?['name']?.toString() ??
          '',
      toLocation: toLocation,
      status: transfer['status']?.toString() ?? '',
      totalQty: totalQty,
      shipping: _asDouble(transfer['shipping_charges']) ?? 0,
      total: _asDouble(transfer['final_total']) ?? 0,
      addedBy: transfer['created_by_name']?.toString() ?? _userName(createdBy),
      notes: transfer['additional_notes']?.toString() ?? '',
    ));
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

String _statusLabel(String status) {
  final normalized = status == 'final' ? 'completed' : status;
  return switch (normalized) {
    'completed' => 'Completed',
    'in_transit' => 'In Transit',
    'pending' => 'Pending',
    _ => normalized,
  };
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
  return double.tryParse(value?.toString().replaceAll(',', '') ?? '');
}

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _yyyyMmDd(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
