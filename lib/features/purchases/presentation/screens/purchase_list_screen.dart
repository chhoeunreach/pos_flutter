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
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.purchases.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = state.purchases[i];
                  final contact = p['contact'] as Map<String, dynamic>? ?? {};
                  final isDue = p['payment_status'] == 'due';
                  final purchaseId = _asInt(p['id']);
                  return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(p['ref_no'] ?? '',
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${contact['name'] ?? '-'} \u2022 ${p['transaction_date'] ?? ''}'),
                              Row(children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: isDue
                                            ? Colors.orange[50]
                                            : Colors.green[50],
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                        p['payment_status']
                                                ?.toString()
                                                .toUpperCase() ??
                                            '',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isDue
                                                ? Colors.orange[700]
                                                : Colors.green[700]))),
                                const SizedBox(width: 8),
                                Text(p['status'] ?? '',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ]),
                            ]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                MoneyFormatter.instance
                                    .format(p['final_total']),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Edit purchase',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: purchaseId == null
                                  ? null
                                  : () => context.go(
                                      '/purchases/$purchaseId/edit',
                                    ),
                            ),
                            IconButton(
                              tooltip: 'Delete purchase',
                              icon: Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red[600]),
                              onPressed: purchaseId == null
                                  ? null
                                  : () => _confirmDelete(context, purchaseId),
                            ),
                          ],
                        ),
                        onTap: () => context.go('/purchases/${p['id']}'),
                      ));
                },
              ));
        }),
      ),
    );
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

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
