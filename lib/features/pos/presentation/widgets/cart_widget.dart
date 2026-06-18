import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_widget.dart';
import 'payment_sheet.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(builder: (context, state) {
      if (state.items.isEmpty) {
        return const AppEmptyWidget(message: 'Cart is empty\nAdd products from the list', icon: Icons.shopping_cart_outlined);
      }
      return Column(children: [
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: state.items.length,
          itemBuilder: (context, i) => _itemCard(context, state.items[i]),
        )),
        _summary(context, state),
        _actions(context, state),
      ]);
    });
  }

  Widget _itemCard(BuildContext context, CartItem item) {
    return AppCard(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${MoneyFormatter.instance.format(item.priceIncTax > 0 ? item.priceIncTax : item.price)} / ${item.unit}', style: Theme.of(context).textTheme.bodySmall),
      ])),
      Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => sl<PosBloc>().add(UpdateCartItemQtyEvent(item.productId, item.quantity - 1))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(6)),
          child: Text('${item.quantity.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => sl<PosBloc>().add(UpdateCartItemQtyEvent(item.productId, item.quantity + 1))),
        const SizedBox(width: 8),
        Text(MoneyFormatter.instance.format(item.lineTotal), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20), onPressed: () => sl<PosBloc>().add(RemoveFromCartEvent(item.productId))),
      ]),
    ]));
  }

  Widget _summary(BuildContext context, PosState state) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], border: Border(top: BorderSide(color: Colors.grey[200]!))),
      child: Column(children: [
        _row('Subtotal', MoneyFormatter.instance.format(state.subtotal)),
        if (state.discount > 0) _row('Discount', '-${MoneyFormatter.instance.format(state.discount)}', valueColor: Colors.red),
        _row('Tax', MoneyFormatter.instance.format(state.tax)),
        const Divider(),
        _row('Total', MoneyFormatter.instance.format(state.total), bold: true, valueColor: Theme.of(context).primaryColor),
      ]),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: valueColor)),
    ]));

  Widget _actions(BuildContext context, PosState state) {
    return Container(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: () => sl<PosBloc>().add(ClearCartEvent()), icon: const Icon(Icons.delete_sweep), label: const Text('Clear'))),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: ElevatedButton.icon(
        onPressed: state.items.isEmpty ? null : () => _showPayment(context, state),
        icon: const Icon(Icons.payment), label: const Text('Pay'),
        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
      )),
    ]));
  }

  void _showPayment(BuildContext context, PosState state) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: sl<PosBloc>(), child: PaymentSheet(total: state.total)),
    );
  }
}
