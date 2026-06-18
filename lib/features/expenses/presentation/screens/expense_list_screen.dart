import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    sl<TransactionBloc>().add(LoadExpensesEvent());
    sl<TransactionBloc>().add(LoadExpenseCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>.value(
      value: sl<TransactionBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Expenses'), actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/expenses/create'))
        ]),
        body: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget();
          }
          if (state.expenses.isEmpty) {
            return const Center(child: Text('No expenses found'));
          }
          return RefreshIndicator(
              onRefresh: () async =>
                  sl<TransactionBloc>().add(LoadExpensesEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.expenses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = state.expenses[i];
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: Icon(Icons.money_off, color: Colors.red[700])),
                    title: Text(e['ref_no'] ?? 'Expense'),
                    subtitle: Text(
                        '${e['additional_notes'] ?? '-'} \u2022 ${e['transaction_date'] ?? ''}'),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(MoneyFormatter.instance.format(e['final_total']),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          Text(e['payment_status'] ?? '',
                              style: Theme.of(context).textTheme.bodySmall),
                        ]),
                    onTap: () => context.go('/expenses/${e['id']}/edit'),
                  );
                },
              ));
        }),
      ),
    );
  }
}
