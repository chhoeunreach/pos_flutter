import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/mock/mock_data.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? id;
  const CustomerFormScreen({super.key, this.id});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); final _emailController = TextEditingController();
  final _mobileController = TextEditingController(); final _addressController = TextEditingController();
  final _contactIdController = TextEditingController(); final _cityController = TextEditingController();

  bool get isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final c = MockData.customers.firstWhere((ct) => ct['id'] == widget.id);
      _nameController.text = c['name'] ?? ''; _emailController.text = c['email'] ?? '';
      _mobileController.text = c['mobile'] ?? ''; _contactIdController.text = c['contact_id'] ?? '';
      _cityController.text = c['city'] ?? '';
      _addressController.text = [c['address_line_1'], c['address_line_2']].where((x) => x != null).join('\n');
    }
  }

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _mobileController.dispose(); _addressController.dispose(); _contactIdController.dispose(); _cityController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(isEditing ? 'Edit Customer' : 'New Customer')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(children: [
      TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v?.isEmpty == true ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 16),
      TextFormField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3),
      const SizedBox(height: 16),
      TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
      const SizedBox(height: 16),
      TextFormField(controller: _contactIdController, decoration: const InputDecoration(labelText: 'Contact ID')),
      const SizedBox(height: 32),
      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
        onPressed: () { if (_formKey.currentState!.validate()) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'Customer updated' : 'Customer created'))); context.pop(); } },
        child: Text(isEditing ? 'Update Customer' : 'Create Customer'),
      )),
    ]))),
  );
}
