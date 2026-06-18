import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/mock/mock_data.dart';

class SupplierDetailScreen extends StatelessWidget {
  final int id;
  const SupplierDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final s = MockData.suppliers.firstWhere((s) => s['id'] == id, orElse: () => <String, dynamic>{});
    if (s.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Supplier')), body: const Center(child: Text('Not found')));
    final due = (s['balance'] as num?)?.toDouble() ?? 0;
    final address = [s['address_line_1'], s['city'], s['state'], s['country']].where((x) => x != null && x.toString().isNotEmpty).join(', ');

    return Scaffold(
      appBar: AppBar(title: Text(s['name'] ?? ''), actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => context.go('/suppliers/$id/edit'))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: Colors.orange[100], child: Text((s['name'] as String? ?? '?')[0].toUpperCase(), style: TextStyle(fontSize: 32, color: Colors.orange[800]))),
          const SizedBox(height: 12),
          Text(s['name'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
          if (s['supplier_business_name'] != null) Text(s['supplier_business_name'], style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _row(context, 'Email', s['email'] ?? '-'), _row(context, 'Phone', s['mobile'] ?? '-'),
          _row(context, 'Business', s['supplier_business_name'] ?? '-'), _row(context, 'Address', address.isEmpty ? '-' : address),
          _row(context, 'Tax Number', s['tax_number'] ?? '-'), _row(context, 'Contact ID', s['contact_id'] ?? '-'),
          const Divider(),
          _row(context, 'Balance', MoneyFormatter.instance.format(due), valueColor: due > 0 ? Colors.red : Colors.green),
        ]))),
        if (due > 0) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Pay Supplier Due'),
              content: Text('Record payment of ${MoneyFormatter.instance.format(due)}?'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded'))); }, child: const Text('Pay'))])),
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
