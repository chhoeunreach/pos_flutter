import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class SaleDetailScreen extends StatefulWidget {
  final int id;
  const SaleDetailScreen({super.key, required this.id});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  void initState() { super.initState(); sl<TransactionBloc>().add(LoadSaleDetailEvent(widget.id)); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(create: (_) => sl<TransactionBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sale Detail'), actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}), IconButton(icon: const Icon(Icons.print), onPressed: () {}),
        ]),
        body: BlocBuilder<TransactionBloc, TransactionState>(builder: (context, state) {
          if (state.isLoading) return const LoadingWidget(fullScreen: true);
          if (state.error != null) return AppErrorWidget(message: state.error!);
          if (state.detail == null) return const AppEmptyWidget(message: 'Sale not found');

          final s = state.detail!;
          final items = s['sell_lines'] as List? ?? [];
          final contact = s['contact'] as Map<String, dynamic>? ?? {};
          final location = s['location'] as Map<String, dynamic>? ?? {};
          final cashier = s['created_by_user'] as Map<String, dynamic>? ?? {};
          final isPaid = s['payment_status'] == 'paid';
          final total = (s['final_total'] as num?)?.toDouble() ?? 0;
          final paid = (s['paid_amount'] as num?)?.toDouble() ?? 0;
          final due = (s['due_amount'] as num?)?.toDouble() ?? 0;

          return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(s['invoice_no'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: isPaid ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(16)),
                  child: Text(s['payment_status']?.toString().toUpperCase() ?? '', style: TextStyle(color: isPaid ? Colors.green[700] : Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 12))),
              ]),
              const SizedBox(height: 8),
              _row('Customer', contact['name'] ?? '-'), _row('Cashier', cashier['full_name'] ?? '-'),
              _row('Location', location['name'] ?? '-'), _row('Date', s['transaction_date'] ?? '-'),
            ]))),
            const SizedBox(height: 16),
            Text('Items', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
            ...items.map((item) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((item['product'] as Map?)?['name'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                Text('x${item['quantity']} @ ${MoneyFormatter.instance.format(item['unit_price_inc_tax'])}', style: Theme.of(context).textTheme.bodySmall),
              ])),
              Text(MoneyFormatter.instance.format((item['unit_price_inc_tax'] as num?)?.toDouble() ?? 0 * ((item['quantity'] as num?)?.toDouble() ?? 0)),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ])))),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              _row('Total Before Tax', MoneyFormatter.instance.format(s['total_before_tax'])),
              if (((s['tax_amount'] as num?)?.toDouble() ?? 0) > 0) _row('Tax', MoneyFormatter.instance.format(s['tax_amount'])),
              if (((s['discount_amount'] as num?)?.toDouble() ?? 0) > 0) _row('Discount', '-${MoneyFormatter.instance.format(s['discount_amount'])}', valueColor: Colors.red),
              const Divider(),
              _row('Total', MoneyFormatter.instance.format(total), bold: true),
              _row('Paid', MoneyFormatter.instance.format(paid), valueColor: Colors.green),
              if (due > 0) _row('Due', MoneyFormatter.instance.format(due), valueColor: Colors.red),
            ]))),
            if (due > 0) ...[
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Add Payment'),
                  content: TextField(decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment added'))); }, child: const Text('Add Payment'))])),
                icon: const Icon(Icons.payment), label: const Text('Add Payment'),
              )),
            ],
          ]));
        }),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.grey[600])),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: valueColor)),
    ]));
}
