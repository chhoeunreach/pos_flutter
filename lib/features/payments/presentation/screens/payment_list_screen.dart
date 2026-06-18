import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  @override
  void initState() {
    super.initState();
    sl<PaymentBloc>().add(LoadPaymentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentBloc>.value(
      value: sl<PaymentBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Payments')),
        body: BlocBuilder<PaymentBloc, PaymentState>(builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget();
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.payments.isEmpty) {
            return const Center(child: Text('No payments found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.payments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = state.payments[i];
              final txn = p['transaction'] as Map<String, dynamic>?;
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.payment, color: Colors.green[700])),
                title: Text(p['payment_ref_no'] ?? ''),
                subtitle: Text('${p['method']} \u2022 ${p['paid_on'] ?? ''}'),
                trailing: Text(MoneyFormatter.instance.format(p['amount']),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text(p['payment_ref_no'] ?? 'Payment'),
                            content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Amount: ${MoneyFormatter.instance.format(p['amount'])}'),
                                  Text('Method: ${p['method']}'),
                                  Text('Date: ${p['paid_on'] ?? ''}'),
                                  if (txn != null)
                                    Text('Invoice: ${txn['invoice_no'] ?? ''}'),
                                  if (p['note'] != null)
                                    Text('Note: ${p['note']}'),
                                ]),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'))
                            ],
                          ));
                },
              );
            },
          );
        }),
      ),
    );
  }
}
