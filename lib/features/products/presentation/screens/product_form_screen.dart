import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';

class ProductFormScreen extends StatefulWidget {
  final int? id;
  const ProductFormScreen({super.key, this.id});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _alertQtyController = TextEditingController();

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = MockData.products.firstWhere((pr) => pr['id'] == widget.id);
      _nameController.text = p['name'] ?? '';
      _skuController.text = p['sku'] ?? '';
      _priceController.text = (p['default_selling_price'] as num?)?.toString() ?? '';
      _purchasePriceController.text = (p['default_purchase_price'] as num?)?.toString() ?? '';
      _alertQtyController.text = (p['alert_quantity'] as num?)?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); _skuController.dispose();
    _priceController.dispose(); _purchasePriceController.dispose(); _alertQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'New Product')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(children: [
      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _skuController, decoration: const InputDecoration(labelText: 'SKU'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Selling Price', prefixText: '\$'), keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _purchasePriceController, decoration: const InputDecoration(labelText: 'Purchase Price', prefixText: '\$'), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      TextFormField(controller: _alertQtyController, decoration: const InputDecoration(labelText: 'Alert Quantity'), keyboardType: TextInputType.number),
      const SizedBox(height: 32),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: () { if (_formKey.currentState!.validate()) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Product updated' : 'Product created'))); context.pop(); } },
        child: Text(isEditing ? 'Update Product' : 'Create Product'),
      )),
    ]))),
  );
}
