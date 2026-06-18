import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/repositories/interfaces.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/product_variation_utils.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/sku_chip.dart';

class SaleDetailScreen extends StatefulWidget {
  final int id;

  const SaleDetailScreen({super.key, required this.id});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = sl<TransactionRepository>().getSaleById(widget.id);
  }

  Future<void> _showAddPaymentDialog(double due) async {
    final amountCtrl = TextEditingController(text: _formatNumberInput(due));
    final noteCtrl = TextEditingController();
    var method = 'cash';
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(
                      value: 'bank_transfer', child: Text('Bank Transfer')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                ],
                onChanged: (v) => method = v ?? 'cash',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final amount = _asDouble(amountCtrl.text);
                      if (amount <= 0) {
                        _showSnack('Enter payment amount');
                        return;
                      }
                      if (amount > due) {
                        _showSnack('Amount cannot be greater than due');
                        return;
                      }
                      setDialogState(() => isSaving = true);
                      try {
                        await sl<TransactionRepository>().addPayment(
                          widget.id,
                          amount,
                          method,
                          note: noteCtrl.text.trim(),
                        );
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        setState(_load);
                        _showSnack('Payment added');
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        _showSnack(e.toString());
                      }
                    },
              child: Text(isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );

    amountCtrl.dispose();
    noteCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Detail'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
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
          final sale = snapshot.data;
          if (sale == null || sale.isEmpty) {
            return const AppEmptyWidget(message: 'Sale not found');
          }

          final items = sale['sell_lines'] as List? ?? [];
          final payments = sale['payment_lines'] as List? ?? [];
          final contact = sale['contact'] as Map?;
          final location = sale['location'] as Map?;
          final cashier = sale['created_by_user'] as Map?;
          final paymentStatus = sale['payment_status']?.toString() ?? 'due';
          final total = _asDouble(sale['final_total']);
          final paid = _asDouble(sale['paid_amount']);
          final due = _asDouble(sale['due_amount']);

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                sale['invoice_no']?.toString() ?? '',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            _StatusChip(status: paymentStatus),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _row('Customer', contact?['name']?.toString() ?? '-'),
                        _row('Cashier',
                            cashier?['full_name']?.toString() ?? '-'),
                        _row('Location', location?['name']?.toString() ?? '-'),
                        _row('Date',
                            sale['transaction_date']?.toString() ?? '-'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Items', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const AppEmptyWidget(message: 'No sale lines found')
                else
                  ...items.map((item) => _SaleLineCard(item: item as Map)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _row(
                            'Total Before Tax',
                            MoneyFormatter.instance
                                .format(sale['total_before_tax'])),
                        if (_asDouble(sale['tax_amount']) > 0)
                          _row(
                              'Tax',
                              MoneyFormatter.instance
                                  .format(sale['tax_amount'])),
                        if (_asDouble(sale['discount_amount']) > 0)
                          _row(
                            'Discount',
                            '-${MoneyFormatter.instance.format(sale['discount_amount'])}',
                            valueColor: Colors.red,
                          ),
                        const Divider(),
                        _row('Total', MoneyFormatter.instance.format(total),
                            bold: true),
                        _row('Paid', MoneyFormatter.instance.format(paid),
                            valueColor: Colors.green),
                        if (due > 0)
                          _row('Due', MoneyFormatter.instance.format(due),
                              valueColor: Colors.red),
                      ],
                    ),
                  ),
                ),
                if (payments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Payments',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...payments
                      .map((payment) => _PaymentCard(payment: payment as Map)),
                ],
                if (due > 0) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddPaymentDialog(due),
                    icon: const Icon(Icons.payment),
                    label: const Text('Add Payment'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SaleLineCard extends StatelessWidget {
  final Map item;

  const _SaleLineCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item['product'] as Map?;
    final variation = item['variations'] as Map?;
    final qty = _asDouble(item['quantity']);
    final price = _asDouble(item['unit_price_inc_tax'] ?? item['unit_price']);
    final sku = variation?['sub_sku']?.toString() ?? '';
    final productMap = product == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(product);
    final variationMap = variation == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(variation);
    final productName = productDisplayName(productMap, variationMap);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName.isEmpty ? '-' : productName,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SkuChip(sku: sku, dense: true),
                      Text('Qty: ${_formatQty(qty)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text('Price: ${MoneyFormatter.instance.format(price)}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              MoneyFormatter.instance.format(qty * price),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Map payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payments_outlined),
        title: Text(MoneyFormatter.instance.format(payment['amount'])),
        subtitle: Text(
          [
            payment['method']?.toString(),
            payment['paid_on']?.toString(),
          ].whereType<String>().where((v) => v.isNotEmpty).join(' | '),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'paid'
        ? Colors.green
        : status == 'partial'
            ? Colors.blue
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
}

String _formatNumberInput(double value) {
  if (value == 0) return '0';
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
