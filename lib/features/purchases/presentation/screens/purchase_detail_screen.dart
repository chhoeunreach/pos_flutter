import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/repositories/interfaces.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final int id;
  const PurchaseDetailScreen({super.key, required this.id});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  late final TransactionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<TransactionBloc>()..add(LoadPurchaseDetailEvent(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Purchase Detail')),
        body: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
          if (state.isLoading) return const LoadingWidget(fullScreen: true);
          if (state.error != null) return Center(child: Text(state.error!));
          if (state.detail == null) {
            return const Center(child: Text('Not found'));
          }

          final p = state.detail!;
          final items = p['purchase_lines'] as List? ?? [];
          final payments = p['payment_lines'] as List? ?? [];
          final contact = p['contact'] as Map<String, dynamic>? ?? {};
          final location = p['location'] as Map<String, dynamic>? ?? {};
          final paymentStatus = p['payment_status']?.toString() ?? 'due';
          final total = _asDouble(p['final_total']);
          final paid = _asDouble(p['paid_amount']);
          final due = _asDouble(p['due_amount']);

          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p['ref_no'] ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                            color:
                                                _statusColor(paymentStatus)[50],
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Text(paymentStatus.toUpperCase(),
                                            style: TextStyle(
                                                color: _statusColor(
                                                    paymentStatus)[700],
                                                fontSize: 12))),
                                  ]),
                              _row('Supplier', contact['name'] ?? '-'),
                              _row('Location', location['name'] ?? '-'),
                              _row('Date', p['transaction_date'] ?? ''),
                              _row('Status', p['status'] ?? '-'),
                            ]))),
                    const SizedBox(height: 16),
                    Text('Items',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No purchase lines found')))
                    else
                      ...items.map((item) => _itemCard(context, item)),
                    const SizedBox(height: 16),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              _row('Total',
                                  MoneyFormatter.instance.format(total),
                                  bold: true),
                              _row('Paid', MoneyFormatter.instance.format(paid),
                                  valueColor: Colors.green),
                              if (due > 0)
                                _row('Due', MoneyFormatter.instance.format(due),
                                    valueColor: Colors.red),
                            ]))),
                    if (payments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Payments',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ...payments.map((payment) => _paymentCard(payment)),
                    ],
                    if (due > 0) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                              onPressed: () => _showAddPaymentDialog(due),
                              icon: const Icon(Icons.payment),
                              label: const Text('Add Payment')))
                    ],
                  ]));
        }),
      ),
    );
  }

  Widget _itemCard(BuildContext context, dynamic rawItem) {
    final item = rawItem as Map;
    final product = item['product'] as Map?;
    final variation = item['variations'] as Map?;
    final qty = _asDouble(item['quantity']);
    final unitPrice = _asDouble(item['unit_cost_inc_tax'] ?? item['unit_cost']);
    final lineTotal = qty * unitPrice;
    final lot = item['lot_number']?.toString();
    final sku = variation?['sub_sku']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(product?['name']?.toString() ?? '-',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(MoneyFormatter.instance.format(lineTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (sku != null && sku.isNotEmpty) Text('SKU: $sku'),
                Text('Lot: ${lot == null || lot.isEmpty ? '-' : lot}'),
                Text('Qty: ${_formatQty(qty)}'),
                Text('Price: ${MoneyFormatter.instance.format(unitPrice)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(dynamic rawPayment) {
    final payment = rawPayment as Map;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payments),
        title: Text(MoneyFormatter.instance.format(payment['amount'])),
        subtitle: Text(
          '${payment['method'] ?? '-'}'
          '${payment['paid_on'] != null ? ' • ${payment['paid_on']}' : ''}',
        ),
      ),
    );
  }

  Future<void> _showAddPaymentDialog(double due) async {
    final amountCtrl = TextEditingController(text: _formatNumberInput(due));
    final noteCtrl = TextEditingController();
    var method = 'cash';
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
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
                onPressed:
                    isSaving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final amount = double.tryParse(amountCtrl.text) ?? 0;
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
                          Navigator.of(dialogContext).pop();
                          _bloc.add(LoadPurchaseDetailEvent(widget.id));
                          _showSnack('Payment added');
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          _showSnack(e.toString());
                        }
                      },
                child: Text(isSaving ? 'Saving...' : 'Save'),
              ),
            ],
          );
        });
      },
    );

    amountCtrl.dispose();
    noteCtrl.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _row(String label, String value,
          {bool bold = false, Color? valueColor}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(color: Colors.grey[600])),
            Text(value,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: valueColor))
          ]));
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
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

MaterialColor _statusColor(String status) {
  if (status == 'paid') return Colors.green;
  if (status == 'partial') return Colors.blue;
  return Colors.orange;
}
