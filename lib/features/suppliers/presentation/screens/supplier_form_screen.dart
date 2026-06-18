import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';

class SupplierFormScreen extends StatefulWidget {
  final int? id;
  const SupplierFormScreen({super.key, this.id});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); final _emailController = TextEditingController();
  final _mobileController = TextEditingController(); final _businessNameController = TextEditingController();
  final _addressController = TextEditingController(); final _contactIdController = TextEditingController();

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final s = MockData.suppliers.firstWhere((c) => c['id'] == widget.id);
      _nameController.text = s['name'] ?? ''; _emailController.text = s['email'] ?? '';
      _mobileController.text = s['mobile'] ?? ''; _businessNameController.text = s['supplier_business_name'] ?? '';
      _addressController.text = s['address_line_1'] ?? ''; _contactIdController.text = s['contact_id'] ?? '';
    }
  }

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _mobileController.dispose(); _businessNameController.dispose(); _addressController.dispose(); _contactIdController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEditing ? 'Edit Supplier' : 'New Supplier')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(children: [
      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16), TextFormField(controller: _businessNameController, decoration: const InputDecoration(labelText: 'Business Name')),
      const SizedBox(height: 16), TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 16), TextFormField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone),
      const SizedBox(height: 16), TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3),
      const SizedBox(height: 16), TextFormField(controller: _contactIdController, decoration: const InputDecoration(labelText: 'Contact ID')),
      const SizedBox(height: 32), SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: () { if (_formKey.currentState!.validate()) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Supplier updated' : 'Supplier created'))); context.pop(); } },
        child: Text(isEditing ? 'Update' : 'Create'),
      )),
    ]))),
  );
}
