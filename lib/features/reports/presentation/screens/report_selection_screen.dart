import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportSelectionScreen extends StatelessWidget {
  const ReportSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      _ReportItem('Cashier Report', Icons.receipt, Colors.blue, '/reports/cashier'),
      _ReportItem('Sales Report', Icons.bar_chart, Colors.green, '/reports/sales'),
      _ReportItem('Product Sales', Icons.inventory, Colors.purple, null),
      _ReportItem('Customer Due', Icons.people, Colors.orange, null),
      _ReportItem('Supplier Due', Icons.person, Colors.teal, null),
      _ReportItem('Stock Report', Icons.inventory_2, Colors.indigo, null),
      _ReportItem('Payment Report', Icons.payment, Colors.pink, null),
      _ReportItem('Expense Report', Icons.money_off, Colors.red, null),
      _ReportItem('Profit & Loss', Icons.trending_up, Colors.amber, null),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: reports.map((r) => Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: r.route != null ? () => context.go(r.route!) : () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${r.title} coming soon')));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(r.icon, size: 48, color: r.color),
                const SizedBox(height: 12),
                Text(r.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;
  const _ReportItem(this.title, this.icon, this.color, this.route);
}
