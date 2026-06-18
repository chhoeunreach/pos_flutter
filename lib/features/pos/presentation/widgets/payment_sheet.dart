import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';

class PaymentSheet extends StatefulWidget {
  final double total;
  const PaymentSheet({super.key, required this.total});

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'cash';
  bool _isFullPayment = true;

  final List<Map<String, String>> _methods = [
    {'key': 'cash', 'label': 'Cash'},
    {'key': 'card', 'label': 'Card'},
    {'key': 'cheque', 'label': 'Cheque'},
    {'key': 'bank_transfer', 'label': 'Bank Transfer'},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Total: ${MoneyFormatter.instance.format(widget.total)}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Text('Payment Method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedMethod,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.payment)),
          items: _methods.map((m) => DropdownMenuItem(value: m['key'], child: Text(m['label']!))).toList(),
          onChanged: (v) => setState(() => _selectedMethod = v ?? 'cash'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.monetization_on)),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Checkbox(value: _isFullPayment, onChanged: (v) { setState(() => _isFullPayment = v ?? true); if (v == true) _amountController.text = widget.total.toStringAsFixed(2); }),
          const Text('Full Payment'),
        ]),
        if (!_isFullPayment)
          Text('Due: ${MoneyFormatter.instance.format(widget.total - (double.tryParse(_amountController.text) ?? 0))}', style: TextStyle(color: Colors.orange[700])),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
          onPressed: _submit, icon: const Icon(Icons.check_circle),
          label: Text(_isFullPayment ? 'Complete Payment' : 'Submit Partial Payment'),
        )),
      ]),
    );
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount'), backgroundColor: Colors.red)); return; }
    sl<PosBloc>().add(SubmitSaleEvent(
      paidAmount: amount, paymentMethod: _selectedMethod,
      paymentStatus: amount >= widget.total ? 'paid' : 'due', accountId: 1,
    ));
    Navigator.of(context).pop();
  }
}
