import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';

class ExpenseFormScreen extends StatefulWidget {
  final int? id;
  const ExpenseFormScreen({super.key, this.id});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(); final _noteController = TextEditingController();
  String _paymentMethod = 'cash';
  bool get isEditing => widget.id != null;

  @override
  void dispose() { _amountController.dispose(); _noteController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'New Expense')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(children: [
      DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Category'), items: MockData.expenseCategories.map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] ?? ''))).toList(), onChanged: (_) {}, validator: (v) => v == null ? 'Required' : null),
      const SizedBox(height: 16), TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16), DropdownButtonFormField<String>(initialValue: _paymentMethod, decoration: const InputDecoration(labelText: 'Payment Method'), items: ['cash', 'card', 'bank_transfer'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v) => _paymentMethod = v ?? 'cash'),
      const SizedBox(height: 16), TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note'), maxLines: 3),
      const SizedBox(height: 32), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: () { if (_formKey.currentState!.validate()) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Expense updated' : 'Expense created'))); context.pop(); } },
        child: Text(isEditing ? 'Update' : 'Create'),
      )),
    ]))),
  );
}
