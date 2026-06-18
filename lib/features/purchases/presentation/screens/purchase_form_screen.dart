import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/repositories/interfaces.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../products/presentation/widgets/product_search_dialog.dart';

int _nextProductRowId = 1;

int _generateProductRowId() => _nextProductRowId++;

class PurchaseFormScreen extends StatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _shippingController = TextEditingController(text: '0');
  final _paymentAmountController = TextEditingController(text: '0');
  final _paymentNoteController = TextEditingController();

  int? _supplierId;
  int? _locationId;
  String _status = 'received';
  String _paymentMethod = 'cash';
  bool _isLoadingSuppliers = true;
  bool _isLoadingLocations = true;
  bool _isLoadingProducts = true;
  bool _isSaving = false;
  bool _invoiceDetailsExpanded = true;
  String? _error;

  DateTime _transactionDate = DateTime.now();

  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _availableProducts = [];

  final List<_ProductRow> _productRows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _refController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _shippingController.dispose();
    _paymentAmountController.dispose();
    _paymentNoteController.dispose();
    for (final row in _productRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadSuppliers(), _loadLocations(), _loadProducts()]);
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await sl<ContactRepository>().getSuppliers();
      final uniqueSuppliers = _uniqueById(suppliers);
      if (!mounted) return;
      setState(() {
        _suppliers = uniqueSuppliers;
        _isLoadingSuppliers = false;
        final hasSelectedSupplier =
            _suppliers.any((supplier) => _asInt(supplier['id']) == _supplierId);
        if (_suppliers.isNotEmpty &&
            (_supplierId == null || !hasSelectedSupplier)) {
          _supplierId = _asInt(_suppliers.first['id']);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSuppliers = false);
    }
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await sl<AuthRepository>().getLocations();
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _isLoadingLocations = false;
        if (_locations.isNotEmpty && _locationId == null) {
          _locationId = _locations.first['id'] as int?;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await sl<ProductRepository>().getAll();
      if (!mounted) return;
      setState(() {
        _availableProducts = products;
        _isLoadingProducts = false;
        if (products.isEmpty) {
          _error = 'No products found. Check the /products API response.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
        _error = 'Could not load products: $e';
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _transactionDate = picked);
    }
  }

  void _addProduct(Map<String, dynamic> product) {
    final variation = _firstVariation(product);
    setState(() {
      _productRows.add(_ProductRow(
        product: product,
        variation: variation,
        localProductRowId: _generateProductRowId(),
      ));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _productRows[index].dispose();
      _productRows.removeAt(index);
    });
  }

  void _addLot(int productIndex) {
    setState(() {
      _productRows[productIndex].addLot();
    });
  }

  void _addScannedLot(int productIndex, String lotNumber) {
    final cleanLotNumber = lotNumber.trim();
    if (cleanLotNumber.isEmpty) return;

    setState(() {
      final row = _productRows[productIndex];
      row.addScannedLot(cleanLotNumber);
      row.scannedLotCount += 1;
    });
  }

  void _toggleLotScanner(int productIndex) {
    setState(() {
      final row = _productRows[productIndex];
      final shouldOpen = !row.isScanningLot;
      for (final productRow in _productRows) {
        productRow.isScanningLot = false;
      }
      row.isScanningLot = shouldOpen;
    });
  }

  void _handleLotScan(int productIndex, String? rawCode) {
    final code = rawCode?.trim();
    if (code == null || code.isEmpty) return;
    if (productIndex < 0 || productIndex >= _productRows.length) return;

    final row = _productRows[productIndex];
    final now = DateTime.now();
    final isFastDuplicate = row.lastScannedLot == code &&
        row.lastScannedAt != null &&
        now.difference(row.lastScannedAt!) < const Duration(seconds: 2);
    if (isFastDuplicate) return;

    row.lastScannedLot = code;
    row.lastScannedAt = now;
    _addScannedLot(productIndex, code);
    _showSnack('Lot scanned: $code');
  }

  void _removeLot(int productIndex, int lotIndex) {
    setState(() {
      _productRows[productIndex].removeLot(lotIndex);
    });
  }

  double get _subtotal => _productRows.fold(0, (s, r) => s + r.lotsTotal);

  double get _discountAmount => double.tryParse(_discountController.text) ?? 0;

  double get _shipping => double.tryParse(_shippingController.text) ?? 0;

  double get _total => _subtotal - _discountAmount + _shipping;

  double get _paymentAmount =>
      double.tryParse(_paymentAmountController.text) ?? 0;

  double get _balanceDue => (_total - _paymentAmount).clamp(0, double.infinity);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productRows.isEmpty) {
      _showError('Add at least one product');
      return;
    }
    if (_supplierId == null) {
      _showError('Select a supplier');
      return;
    }
    if (_locationId == null) {
      _showError('Select a location');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final products = <Map<String, dynamic>>[];
    for (final row in _productRows) {
      final productId = _asInt(row.product['id']);
      final variationId = _asInt(row.variation['id']) ?? 0;
      if (productId == null) {
        _showError('Invalid product selected: ${row.productName}');
        return;
      }
      for (final lot in row.lots) {
        if (lot.quantity > 0) {
          products.add(lot.toPayload(productId, variationId));
        }
      }
    }

    if (products.isEmpty) {
      _showError('Add at least one lot with quantity');
      return;
    }
    if (_paymentAmount > _total) {
      _showError('Payment amount cannot be greater than total');
      return;
    }

    final payments = _buildPaymentLines();
    final payload = <String, dynamic>{
      'supplier_id': _supplierId,
      'location_id': _locationId,
      'transaction_date':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_transactionDate),
      'status': _status,
      'ref_no': _refController.text.trim().isEmpty
          ? null
          : _refController.text.trim(),
      'discount_type': 'fixed',
      'discount_amount': _discountAmount,
      'tax_id': null,
      'shipping_charges': _shipping,
      'additional_notes': _notesController.text.trim(),
      'products': products,
      if (payments.isNotEmpty) 'payments': payments,
    };

    try {
      final res = await sl<TransactionRepository>().createPurchase(payload);
      if (res['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Purchase created'), backgroundColor: Colors.green),
        );
        context.go('/purchases');
      } else {
        _showError(res['message'] as String? ?? 'Failed to create purchase');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _error = msg;
    });
  }

  List<Map<String, dynamic>> _buildPaymentLines() {
    if (_paymentAmount <= 0 || _total <= 0) {
      return [];
    }

    return [
      {
        'amount': _paymentAmount,
        'method': _paymentMethod,
        'paid_on': DateFormat('yyyy-MM-dd HH:mm:ss').format(_transactionDate),
        'note': _paymentNoteController.text.trim(),
      }
    ];
  }

  Future<void> _showAddSupplierDialog() async {
    final nameCtrl = TextEditingController();
    final businessCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Supplier'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Name *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: businessCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: mobileCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobile',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSaving = true);
                        try {
                          final res = await sl<ContactRepository>().create(
                            {
                              'name': nameCtrl.text.trim(),
                              'supplier_business_name':
                                  businessCtrl.text.trim(),
                              'mobile': mobileCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                            },
                            type: 'supplier',
                          );
                          if (res['success'] != true) {
                            throw Exception(
                                res['message'] ?? 'Failed to create supplier');
                          }
                          final data = Map<String, dynamic>.from(
                              res['data'] as Map? ?? {});
                          final id = _asInt(data['id']);
                          if (id == null) {
                            throw Exception('Supplier created but id missing');
                          }
                          if (!mounted || !dialogContext.mounted) return;
                          setState(() {
                            _suppliers = [
                              data,
                              ..._suppliers.where((s) => _asInt(s['id']) != id),
                            ];
                            _supplierId = id;
                          });
                          Navigator.of(dialogContext).pop();
                          _showSnack('Supplier created');
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (mounted) _showSnack(e.toString());
                        }
                      },
                child: Text(isSaving ? 'Saving...' : 'Save'),
              ),
            ],
          );
        });
      },
    );

    nameCtrl.dispose();
    businessCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _printLotBarcode(_LotRow lot) async {
    final lotNumber = lot.lotNumberCtrl.text.trim();
    if (lotNumber.isEmpty) {
      _showSnack('Enter or scan lot before printing');
      return;
    }

    final pdf = pw.Document();
    final labelFormat = PdfPageFormat(
      40 * PdfPageFormat.mm,
      10 * PdfPageFormat.mm,
      marginAll: 1 * PdfPageFormat.mm,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: labelFormat,
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              lotNumber,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(
                fontSize: 5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Expanded(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: lotNumber,
                drawText: false,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Text(
              lotNumber,
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 4),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      name: 'lot-$lotNumber-40x10',
      format: labelFormat,
      onLayout: (_) => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSuppliers || _isLoadingLocations || _isLoadingProducts) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Purchase')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New Purchase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: TextStyle(color: Colors.red[700]))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildProductsSection(),
              const SizedBox(height: 24),
              _buildTotalsSection(),
              const SizedBox(height: 24),
              _buildPaymentSection(),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Create Purchase'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    Map<String, dynamic>? selectedSupplier;
    for (final supplier in _suppliers) {
      if (_asInt(supplier['id']) == _supplierId) {
        selectedSupplier = supplier;
        break;
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(
                  () => _invoiceDetailsExpanded = !_invoiceDetailsExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Invoice Details',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    if (!_invoiceDetailsExpanded)
                      Expanded(
                        flex: 2,
                        child: Text(
                          selectedSupplier == null
                              ? 'Tap to show'
                              : _supplierLabel(selectedSupplier),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    Icon(_invoiceDetailsExpanded
                        ? Icons.expand_less
                        : Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (_invoiceDetailsExpanded) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      key: ValueKey(
                          'supplier-$_supplierId-${_suppliers.length}'),
                      initialValue: _supplierId,
                      isExpanded: true,
                      menuMaxHeight: 360,
                      decoration: const InputDecoration(
                          labelText: 'Supplier *',
                          prefixIcon: Icon(Icons.person)),
                      items: _suppliers
                          .map((s) => DropdownMenuItem(
                                value: _asInt(s['id']),
                                child: Text(_supplierLabel(s)),
                              ))
                          .where((item) => item.value != null)
                          .toList(),
                      onChanged: (v) => setState(() => _supplierId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _showAddSupplierDialog,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _locationId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(
                    labelText: 'Location *', prefixIcon: Icon(Icons.store)),
                items: _locations
                    .map((l) => DropdownMenuItem(
                          value: l['id'] as int,
                          child: Text(l['name'] as String? ?? ''),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _locationId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                      labelText: 'Purchase Date',
                      prefixIcon: Icon(Icons.calendar_today)),
                  child:
                      Text(DateFormat('yyyy-MM-dd').format(_transactionDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _refController,
                decoration: const InputDecoration(
                    labelText: 'Reference No', prefixIcon: Icon(Icons.tag)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'received', child: Text('Received')),
                  DropdownMenuItem(value: 'ordered', child: Text('Ordered')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'received'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    prefixIcon: Icon(Icons.notes)),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Products',
                    style: Theme.of(context).textTheme.titleLarge)),
            FilledButton.icon(
              onPressed: _showProductSearch,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_productRows.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('No products added yet',
                  style: TextStyle(color: Colors.grey[500])),
            ),
          ),
        ..._productRows
            .asMap()
            .entries
            .map((entry) => _buildProductCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildProductCard(int index, _ProductRow row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.productName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('SKU: ${row.sku}  |  ${row.unit}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _toggleLotScanner(index),
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: Text(row.isScanningLot ? 'Hide Scan' : 'Scan Lot'),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'change') _showProductSearch(initialIndex: index);
                    if (v == 'remove') _removeProduct(index);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'change', child: Text('Change Product')),
                    const PopupMenuItem(
                        value: 'remove', child: Text('Remove Product')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (row.isScanningLot) ...[
              _buildInlineLotScanner(index, row),
              const SizedBox(height: 12),
            ],
            if (row.lots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No lots added',
                    style: TextStyle(
                        color: Colors.grey[500], fontStyle: FontStyle.italic)),
              ),
            ...row.lots.asMap().entries.map((lotEntry) =>
                _buildLotCard(index, lotEntry.key, lotEntry.value)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _addLot(index),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Lot'),
            ),
            if (row.lotsTotal > 0) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    Text('Qty: ${_formatQty(row.totalQuantity)} ${row.unit}',
                        style: TextStyle(color: Colors.grey[700])),
                    Text(
                        'Product total: ${MoneyFormatter.instance.format(row.lotsTotal)}',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLotCard(int productIndex, int lotIndex, _LotRow lot) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(constraints.maxWidth - 24, 650),
              child: _buildWideLotRow(productIndex, lotIndex, lot),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLotRow(int productIndex, int lotIndex, _LotRow lot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lotIndexBadge(lotIndex),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: _lotNumberField(productIndex, lotIndex, lot)),
        const SizedBox(width: 8),
        Expanded(child: _qtyField(lot)),
        const SizedBox(width: 8),
        Expanded(child: _priceField(lot)),
        const SizedBox(width: 8),
        SizedBox(width: 128, height: 48, child: _lotTotal(lot)),
        const SizedBox(width: 4),
        _lotActions(productIndex, lotIndex, lot),
      ],
    );
  }

  Widget _lotIndexBadge(int lotIndex) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('${lotIndex + 1}',
          style:
              TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
    );
  }

  Widget _lotNumberField(int productIndex, int lotIndex, _LotRow lot) {
    return TextFormField(
      controller: lot.lotNumberCtrl,
      decoration: const InputDecoration(
        labelText: 'Lot',
        hintText: 'Scan or type lot',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() {}),
      onFieldSubmitted: (value) {
        if (value.trim().isNotEmpty &&
            lotIndex == _productRows[productIndex].lots.length - 1) {
          _addLot(productIndex);
        }
      },
    );
  }

  Widget _qtyField(_LotRow lot) {
    return TextFormField(
      controller: lot.qtyCtrl,
      decoration: const InputDecoration(
        labelText: 'Qty *',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      validator: (v) {
        final n = double.tryParse(v ?? '');
        if (n == null || n <= 0) return 'Required';
        return null;
      },
    );
  }

  Widget _priceField(_LotRow lot) {
    return TextFormField(
      controller: lot.purchasePriceCtrl,
      decoration: const InputDecoration(
        labelText: 'Price *',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      validator: (v) {
        final n = double.tryParse(v ?? '');
        if (n == null || n < 0) return 'Required';
        return null;
      },
    );
  }

  Widget _lotTotal(_LotRow lot) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Total',
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          Text(MoneyFormatter.instance.format(lot.subtotal),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.grey[850])),
        ],
      ),
    );
  }

  Widget _lotActions(int productIndex, int lotIndex, _LotRow lot,
      {bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.print, size: 18),
          tooltip: 'Print barcode label',
          onPressed: () => _printLotBarcode(lot),
          visualDensity: compact
              ? const VisualDensity(horizontal: -4, vertical: -4)
              : VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          tooltip: 'Remove lot',
          onPressed: () => _removeLot(productIndex, lotIndex),
          visualDensity: compact
              ? const VisualDensity(horizontal: -4, vertical: -4)
              : VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildInlineLotScanner(int productIndex, _ProductRow row) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 156,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final windowWidth = math.min(constraints.maxWidth - 28, 420.0);
            const windowHeight = 64.0;
            final scanWindow = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2,
              ),
              width: windowWidth,
              height: windowHeight,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  fit: BoxFit.cover,
                  scanWindow: scanWindow,
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      _handleLotScan(productIndex, barcode.rawValue);
                    }
                  },
                ),
                Positioned.fromRect(
                  rect: scanWindow,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.amberAccent, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 10),
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_scanner,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              row.scannedLotCount == 0
                                  ? 'Place the barcode sticker inside the frame.'
                                  : '${row.scannedLotCount} lot(s) scanned. Keep scanning.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showProductSearch({int? initialIndex}) {
    showDialog(
      context: context,
      builder: (context) => ProductSearchDialog(
        products: _availableProducts,
        onSearch: (query) => sl<ProductRepository>().getAll(search: query),
        onSelected: (product) {
          if (initialIndex != null) {
            _productRows[initialIndex].replaceProduct(product);
            setState(() {});
          } else {
            _addProduct(product);
          }
        },
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _totalRow('Subtotal', _subtotal, bold: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _discountController,
              decoration: const InputDecoration(
                  labelText: 'Discount', prefixText: '\$ ', isDense: true),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _shippingController,
              decoration: const InputDecoration(
                  labelText: 'Shipping', prefixText: '\$ ', isDense: true),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            _totalRow('Total', _total, bold: true, large: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Payment', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _paymentAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Payment Amount',
                      prefixText: '\$ ',
                      prefixIcon: Icon(Icons.payments),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final amount = double.tryParse(v ?? '') ?? 0;
                      if (amount < 0) return 'Invalid amount';
                      if (amount > _total) return 'Too much';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(
                          value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    ],
                    onChanged: (v) =>
                        setState(() => _paymentMethod = v ?? 'cash'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _total <= 0
                      ? null
                      : () => setState(() {
                            _paymentAmountController.text =
                                _formatNumberInput(_total);
                          }),
                  icon: const Icon(Icons.done_all),
                  label: const Text('Pay Full'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _paymentAmountController.text = '0';
                  }),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paymentNoteController,
              decoration: const InputDecoration(
                labelText: 'Payment Note',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 12),
            _totalRow('Paid', _paymentAmount),
            const SizedBox(height: 4),
            _totalRow('Balance Due', _balanceDue, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount,
      {bool bold = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                fontSize: large ? 18 : 14)),
        Text(MoneyFormatter.instance.format(amount),
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: large ? 18 : 14)),
      ],
    );
  }
}

class _ProductRow {
  Map<String, dynamic> product;
  Map<String, dynamic> variation;
  final int localProductRowId;
  final List<_LotRow> lots = [];
  bool isScanningLot = false;
  String? lastScannedLot;
  DateTime? lastScannedAt;
  int scannedLotCount = 0;

  _ProductRow({
    required this.product,
    required this.variation,
    required this.localProductRowId,
  }) {
    lots.add(_LotRow.fromProduct(product, variation));
  }

  String get productName => product['name'] as String? ?? '';
  String get sku =>
      variation['sub_sku']?.toString() ?? product['sku']?.toString() ?? '';
  String get unit {
    final unit = product['unit'];
    if (unit is Map) {
      return unit['short_name']?.toString() ??
          unit['name']?.toString() ??
          'pcs';
    }
    return unit?.toString() ?? 'pcs';
  }

  double get lotsTotal => lots.fold(0, (s, l) => s + l.subtotal);
  double get totalQuantity => lots.fold(0, (s, l) => s + l.quantity);

  void replaceProduct(Map<String, dynamic> newProduct) {
    product = newProduct;
    variation = _firstVariation(newProduct);
    if (lots.length == 1 && lots.first.isEmpty) {
      lots.first.applyProductDefaults(product, variation);
    }
  }

  void addLot() => lots.add(_LotRow.fromProduct(product, variation));

  void addScannedLot(String lotNumber) {
    for (final lot in lots) {
      if (lot.lotNumberCtrl.text.trim().isEmpty) {
        lot.lotNumberCtrl.text = lotNumber;
        return;
      }
    }

    final lot = _LotRow.fromProduct(product, variation);
    lot.lotNumberCtrl.text = lotNumber;
    lots.add(lot);
  }

  void duplicateLot(int index) {
    final original = lots[index];
    lots.add(_LotRow.fromExisting(original));
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

class _LotRow {
  final lotNumberCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final purchasePriceCtrl = TextEditingController();
  final purchasePriceIncTaxCtrl = TextEditingController();
  final sellPriceCtrl = TextEditingController();
  final profitPercentCtrl = TextEditingController();
  final itemTaxCtrl = TextEditingController(text: '0');

  DateTime? mfgDate;
  DateTime? expDate;

  _LotRow() {
    _setupListeners();
  }

  _LotRow.fromProduct(
      Map<String, dynamic> product, Map<String, dynamic> variation) {
    applyProductDefaults(product, variation);
    _setupListeners();
  }

  _LotRow.fromExisting(_LotRow original) {
    lotNumberCtrl.text = original.lotNumberCtrl.text;
    qtyCtrl.text = original.qtyCtrl.text;
    purchasePriceCtrl.text = original.purchasePriceCtrl.text;
    purchasePriceIncTaxCtrl.text = original.purchasePriceIncTaxCtrl.text;
    sellPriceCtrl.text = original.sellPriceCtrl.text;
    profitPercentCtrl.text = original.profitPercentCtrl.text;
    itemTaxCtrl.text = original.itemTaxCtrl.text;
    mfgDate = original.mfgDate;
    expDate = original.expDate;
    _setupListeners();
  }

  bool get isEmpty =>
      lotNumberCtrl.text.isEmpty &&
      (double.tryParse(qtyCtrl.text) ?? 0) == 1 &&
      purchasePriceCtrl.text.isEmpty &&
      purchasePriceIncTaxCtrl.text.isEmpty &&
      sellPriceCtrl.text.isEmpty;

  void applyProductDefaults(
      Map<String, dynamic> product, Map<String, dynamic> variation) {
    final purchasePrice = _asDouble(
      variation['default_purchase_price'] ?? product['default_purchase_price'],
    );
    final rawPurchasePriceIncTax = _asDouble(variation['dpp_inc_tax']);
    final purchasePriceIncTax =
        rawPurchasePriceIncTax > 0 ? rawPurchasePriceIncTax : purchasePrice;
    final sellPrice = _asDouble(
      variation['sell_price_inc_tax'] ??
          variation['default_sell_price'] ??
          product['default_selling_price'],
    );

    purchasePriceCtrl.text = _formatNumberInput(purchasePrice);
    purchasePriceIncTaxCtrl.text = _formatNumberInput(purchasePriceIncTax);
    sellPriceCtrl.text = _formatNumberInput(sellPrice);
    if (profitPercentCtrl.text.isEmpty) {
      profitPercentCtrl.text = '0';
    }
  }

  void _setupListeners() {
    purchasePriceCtrl.addListener(_onPriceChanged);
    sellPriceCtrl.addListener(_onSellPriceChanged);
  }

  void _onPriceChanged() {
    final purchasePrice = double.tryParse(purchasePriceCtrl.text) ?? 0;
    purchasePriceIncTaxCtrl.text =
        purchasePrice > 0 ? purchasePrice.toStringAsFixed(2) : '';
    if (profitPercentCtrl.text.isEmpty) {
      profitPercentCtrl.text = '0';
    }
  }

  void _onSellPriceChanged() {
    final purchasePrice = double.tryParse(purchasePriceCtrl.text) ?? 0;
    final sellPrice = double.tryParse(sellPriceCtrl.text) ?? 0;
    if (purchasePrice > 0 &&
        sellPrice > 0 &&
        (profitPercentCtrl.text.isEmpty || profitPercentCtrl.text == '0')) {
      final profitPercent = ((sellPrice - purchasePrice) / purchasePrice * 100);
      profitPercentCtrl.text = profitPercent.toStringAsFixed(1);
    }
  }

  double get quantity => double.tryParse(qtyCtrl.text) ?? 0;
  double get purchasePrice => double.tryParse(purchasePriceCtrl.text) ?? 0;
  double get purchasePriceIncTax =>
      double.tryParse(purchasePriceIncTaxCtrl.text) ?? purchasePrice;
  double get defaultSellPrice => double.tryParse(sellPriceCtrl.text) ?? 0;
  double get profitPercent => double.tryParse(profitPercentCtrl.text) ?? 0;
  double get itemTax => double.tryParse(itemTaxCtrl.text) ?? 0;
  double get subtotal => quantity * purchasePriceIncTax;
  String get expDateText =>
      expDate != null ? DateFormat('yyyy-MM-dd').format(expDate!) : '-';
  String get mfgDateText =>
      mfgDate != null ? DateFormat('yyyy-MM-dd').format(mfgDate!) : '-';

  Map<String, dynamic> toPayload(int productId, int variationId) => {
        'product_id': productId,
        'variation_id': variationId,
        'quantity': quantity,
        'purchase_price': purchasePrice,
        'purchase_price_inc_tax': purchasePriceIncTax,
        'item_tax': itemTax,
        'tax_id': null,
        'lot_number': lotNumberCtrl.text.trim(),
        'mfg_date':
            mfgDate != null ? DateFormat('yyyy-MM-dd').format(mfgDate!) : null,
        'exp_date':
            expDate != null ? DateFormat('yyyy-MM-dd').format(expDate!) : null,
        'profit_percent': profitPercent,
        'default_sell_price': defaultSellPrice,
      };

  void dispose() {
    lotNumberCtrl.dispose();
    qtyCtrl.dispose();
    purchasePriceCtrl.dispose();
    purchasePriceIncTaxCtrl.dispose();
    sellPriceCtrl.dispose();
    profitPercentCtrl.dispose();
    itemTaxCtrl.dispose();
  }
}

Map<String, dynamic> _firstVariation(Map<String, dynamic> product) {
  final variations = product['variations'] as List? ?? [];
  if (variations.isEmpty) return {};
  return Map<String, dynamic>.from(variations.first as Map);
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<Map<String, dynamic>> _uniqueById(List<Map<String, dynamic>> items) {
  final seen = <int>{};
  final result = <Map<String, dynamic>>[];
  for (final item in items) {
    final id = _asInt(item['id']);
    if (id == null || seen.contains(id)) continue;
    seen.add(id);
    result.add(item);
  }
  return result;
}

String _formatNumberInput(double value) {
  if (value == 0) return '';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _supplierLabel(Map<String, dynamic> supplier) {
  final contactId = supplier['contact_id']?.toString();
  final name = supplier['name']?.toString() ?? '';
  final businessName = supplier['supplier_business_name']?.toString();
  final label = businessName != null && businessName.isNotEmpty
      ? '$name - $businessName'
      : name;

  if (contactId == null || contactId.isEmpty) return label;
  return '$contactId $label';
}
