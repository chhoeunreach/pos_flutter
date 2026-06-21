import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  late final TransactionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<TransactionBloc>()..add(LoadPurchasesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Purchases'), actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/purchases/create'))
        ]),
        body: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
          if (state.isLoading) return const LoadingWidget();
          if (state.error != null) return Center(child: Text(state.error!));
          if (state.purchases.isEmpty) {
            return const Center(child: Text('No purchases found'));
          }
          return RefreshIndicator(
              onRefresh: () async => _bloc.add(LoadPurchasesEvent()),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surfaceContainerHighest),
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Reference No')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('Purchase Status')),
                    DataColumn(label: Text('Payment Status')),
                    DataColumn(label: Text('Grand Total')),
                    DataColumn(label: Text('Total Qty')),
                    DataColumn(label: Text('Payment Due')),
                    DataColumn(label: Text('Added By')),
                  ],
                  rows: [
                    for (final p in state.purchases)
                      DataRow(
                        onSelectChanged: (_) =>
                            context.go('/purchases/${p['id']}'),
                        cells: [
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit purchase',
                                icon:
                                    const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => context.go(
                                    '/purchases/${_asInt(p['id'])}/edit'),
                              ),
                              IconButton(
                                tooltip: 'Delete purchase',
                                icon: Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red[600]),
                                onPressed: () =>
                                    _confirmDelete(context, _asInt(p['id'])!),
                              ),
                            ],
                          )),
                          DataCell(Text(p['transaction_date'] ?? '-',
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(p['ref_no'] ?? '-',
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(
                              (p['location']
                                      as Map<String, dynamic>?)?['name']
                                  ?.toString() ??
                                  '-',
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(
                              (p['contact']
                                      as Map<String, dynamic>?)?['name']
                                  ?.toString() ??
                                  '-',
                              style: const TextStyle(fontSize: 13))),
                          DataCell(_statusChip(
                              p['status']?.toString() ?? '', context)),
                          DataCell(_paymentStatusChip(
                              p['payment_status']?.toString() ?? '', context)),
                          DataCell(Text(
                              MoneyFormatter.instance.format(p['final_total']),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))),
                          DataCell(Text(
                              _totalQty(p),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(
                              MoneyFormatter.instance.format(p['due_amount']),
                              style: const TextStyle(fontSize: 13))),
                          DataCell(Text(
                              (p['created_by_user']
                                      as Map<String, dynamic>?)?['full_name']
                                  ?.toString() ??
                                  '-',
                              style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                  ],
                ),
              ));
        }),
      ),
    );
  }

  String _totalQty(Map<String, dynamic> purchase) {
    final topQty = _toDouble(purchase['total_qty']);
    if (topQty != null) {
      return topQty == topQty.roundToDouble()
          ? topQty.toStringAsFixed(0)
          : topQty.toStringAsFixed(2);
    }
    final lines = purchase['purchase_lines'];
    if (lines is! List) return '-';
    double total = 0;
    for (final line in lines) {
      if (line is Map<String, dynamic>) {
        total += _toDouble(line['quantity']) ?? 0;
      }
    }
    return total == total.roundToDouble()
        ? total.toStringAsFixed(0)
        : total.toStringAsFixed(2);
  }

  Widget _paymentStatusChip(String status, BuildContext context) {
    final isDue = status == 'due';
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: isDue ? Colors.orange[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(12)),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                color: isDue ? Colors.orange[700] : Colors.green[700])));
  }

  Widget _statusChip(String status, BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12)),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant)));
  }

  Future<void> _confirmDelete(BuildContext context, int purchaseId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: const Text('Are you sure you want to delete this purchase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted || !context.mounted) return;
    _bloc.add(DeletePurchaseEvent(purchaseId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting purchase...')),
    );
  }
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
