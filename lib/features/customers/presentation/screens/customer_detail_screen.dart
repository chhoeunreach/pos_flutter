import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/mock/mock_data.dart';

class CustomerDetailScreen extends StatelessWidget {
  final int id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = MockData.customers.firstWhere((c) => c['id'] == id, orElse: () => <String, dynamic>{});
    if (c.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Customer')), body: const Center(child: Text('Not found')));
    final balance = (c['balance'] as num?)?.toDouble() ?? 0;
    final address = [c['address_line_1'], c['address_line_2'], c['city'], c['state'], c['country']].where((x) => x != null && x.toString().isNotEmpty).join(', ');

    return Scaffold(
      appBar: AppBar(title: Text(c['name'] ?? ''), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/customers/$id/edit'))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: Colors.blue[100], child: Text((c['name'] as String? ?? '?')[0].toUpperCase(), style: TextStyle(fontSize: 32, color: Colors.blue[800]))),
          const SizedBox(height: 12),
          Text(c['name'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
          Text(c['contact_id'] ?? '', style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _row(context, 'Email', c['email'] ?? '-'),
          _row(context, 'Phone', c['mobile'] ?? '-'),
          _row(context, 'Address', address.isEmpty ? '-' : address),
          _row(context, 'Tax Number', c['tax_number'] ?? '-'),
          const Divider(),
          _row(context, 'Balance', MoneyFormatter.instance.format(balance), valueColor: balance > 0 ? Colors.red : Colors.green),
          if (c['credit_limit'] != null) _row(context, 'Credit Limit', MoneyFormatter.instance.format(c['credit_limit'])),
        ]))),
        if (balance > 0) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => _PayDueDialog(customerName: c['name'], dueAmount: balance)),
            icon: const Icon(Icons.payment), label: const Text('Pay Due'),
          )),
        ],
      ])),
    );
  }

  Widget _row(BuildContext context, String label, String value, {Color? valueColor}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
      Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor, fontWeight: valueColor != null ? FontWeight.bold : null)),
    ]));
}

class _PayDueDialog extends StatefulWidget {
  final String? customerName; final double dueAmount;
  const _PayDueDialog({this.customerName, required this.dueAmount});
  @override
  State<_PayDueDialog> createState() => _PayDueDialogState();
}
class _PayDueDialogState extends State<_PayDueDialog> {
  final _controller = TextEditingController(); String _method = 'cash';
  @override
  void initState() { super.initState(); _controller.text = widget.dueAmount.toStringAsFixed(2); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Pay Due - ${widget.customerName}'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('Total Due: ${MoneyFormatter.instance.format(widget.dueAmount)}', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(initialValue: _method, decoration: const InputDecoration(labelText: 'Payment Method'),
        items: ['cash', 'card', 'bank_transfer'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => setState(() => _method = v ?? 'cash')),
      const SizedBox(height: 12),
      TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded'))); }, child: const Text('Pay')),
    ],
  );
}
