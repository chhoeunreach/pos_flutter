import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';

class PaymentSheet extends StatefulWidget {
  final double total;
  final String initialMethod;
  final int? locationId;

  const PaymentSheet({
    super.key,
    required this.total,
    this.initialMethod = 'cash',
    this.locationId,
  });

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final _sellNoteController = TextEditingController();
  final _staffNoteController = TextEditingController();
  final _paymentNoteController = TextEditingController();
  final List<_PaymentRowData> _rows = [];

  final List<Map<String, String>> _methods = const [
    {'key': 'cash', 'label': 'Cash'},
    {'key': 'card', 'label': 'Card'},
    {'key': 'cheque', 'label': 'Cheque'},
    {'key': 'bank_transfer', 'label': 'Bank Transfer'},
    {'key': 'advance', 'label': 'Advance'},
  ];

  @override
  void initState() {
    super.initState();
    _rows.add(_PaymentRowData(
      amount: widget.total,
      method: widget.initialMethod,
    ));
  }

  @override
  void dispose() {
    _sellNoteController.dispose();
    _staffNoteController.dispose();
    _paymentNoteController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  double get _totalPaying => _rows.fold<double>(
        0,
        (sum, row) => sum + (double.tryParse(row.amountController.text) ?? 0),
      );

  double get _balance =>
      (widget.total - _totalPaying).clamp(0, double.infinity);
  double get _changeReturn =>
      (_totalPaying - widget.total).clamp(0, double.infinity);
  double get _totalItems => sl<PosBloc>().state.items.fold<double>(
        0,
        (sum, item) => sum + item.quantity,
      );

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Column(
            children: [
              _header(context),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _paymentForm(context)),
                      const SizedBox(width: 24),
                      SizedBox(width: 240, child: _totalsPanel(context)),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              _footer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        children: [
          Text('Payment', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _paymentForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Advance Balance: ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: '\$ 0.00'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xfff3f1f1),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ..._rows.asMap().entries.map((entry) {
                return _paymentRow(entry.key, entry.value);
              }),
              const Divider(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Cash Denominations',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add denominations in Settings -> Business Settings -> POS -> Cash Denominations',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String>(
                      initialValue: 'none',
                      decoration: const InputDecoration(
                        labelText: 'Payment Account',
                        prefixIcon: Icon(Icons.money, size: 18),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('None')),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _paymentNoteController,
                decoration: const InputDecoration(labelText: 'Payment note'),
                minLines: 3,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            onPressed: _addPaymentRow,
            child: const Text('Add Payment Row'),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _sellNoteController,
                decoration: const InputDecoration(labelText: 'Sell note'),
                minLines: 3,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextField(
                controller: _staffNoteController,
                decoration: const InputDecoration(labelText: 'Staff note'),
                minLines: 3,
                maxLines: 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentRow(int index, _PaymentRowData row) {
    return Padding(
      padding: EdgeInsets.only(bottom: index == _rows.length - 1 ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              controller: row.amountController,
              autofocus: index == 0,
              decoration: const InputDecoration(
                labelText: 'Amount:*',
                prefixIcon: Icon(Icons.money, size: 18),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 28),
          SizedBox(
            width: 250,
            child: DropdownButtonFormField<String>(
              initialValue: row.method,
              decoration: const InputDecoration(
                labelText: 'Payment Method:*',
                prefixIcon: Icon(Icons.money, size: 18),
              ),
              items: _methods
                  .map((method) => DropdownMenuItem(
                        value: method['key'],
                        child: Text(method['label']!),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => row.method = value ?? 'cash'),
            ),
          ),
          if (_rows.length > 1) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Remove row',
              onPressed: () => _removePaymentRow(index),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _totalsPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _totalBlock('Total Items:', _formatQty(_totalItems)),
            _panelDivider(),
            _totalBlock(
                'Total Payable:', MoneyFormatter.instance.format(widget.total)),
            _panelDivider(),
            _totalBlock(
                'Total Paying:', MoneyFormatter.instance.format(_totalPaying)),
            _panelDivider(),
            _totalBlock('Change Return:',
                MoneyFormatter.instance.format(_changeReturn)),
            _panelDivider(),
            _totalBlock('Balance:', MoneyFormatter.instance.format(_balance)),
          ],
        ),
      ),
    );
  }

  Widget _totalBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 26)),
        ],
      ),
    );
  }

  Widget _panelDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.deepOrange.shade700,
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff26313f),
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _finalize,
              child: const Text('Finalize Payment'),
            ),
          ),
        ],
      ),
    );
  }

  void _addPaymentRow() {
    setState(() {
      _rows.add(_PaymentRowData(amount: _balance, method: 'cash'));
    });
  }

  void _removePaymentRow(int index) {
    setState(() {
      final row = _rows.removeAt(index);
      row.dispose();
    });
  }

  void _finalize() {
    final payments = <Map<String, dynamic>>[];
    for (final row in _rows) {
      final amount = double.tryParse(row.amountController.text) ?? 0;
      if (amount <= 0) continue;
      payments.add({
        'method': row.method,
        'amount': amount,
        'paid_on': DateTime.now().toIso8601String(),
        if (_paymentNoteController.text.trim().isNotEmpty)
          'note': _paymentNoteController.text.trim(),
      });
    }

    if (payments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter payment amount')),
      );
      return;
    }

    sl<PosBloc>().add(SubmitSaleEvent(
      paidAmount: _totalPaying,
      paymentMethod: payments.first['method'] as String,
      payments: payments,
      paymentStatus: _totalPaying >= widget.total ? 'paid' : 'due',
      locationId: widget.locationId,
      saleNote: _sellNoteController.text.trim(),
      staffNote: _staffNoteController.text.trim(),
    ));
    Navigator.of(context).pop();
  }
}

class _PaymentRowData {
  final TextEditingController amountController;
  String method;

  _PaymentRowData({required double amount, required this.method})
      : amountController =
            TextEditingController(text: amount.toStringAsFixed(2));

  void dispose() => amountController.dispose();
}

String _formatQty(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
