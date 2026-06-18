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
  void dispose() {
    _bloc.close();
    super.dispose();
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
                        trailing: Text(
                            MoneyFormatter.instance.format(p['final_total']),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        onTap: () => context.go('/purchases/${p['id']}'),
                      ));
                },
              ));
        }),
      ),
    );
  }
}
