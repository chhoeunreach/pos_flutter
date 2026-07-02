import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/accessory_repository.dart';
import '../../application/accessory_bloc.dart';

class AccessoryFormScreen extends StatefulWidget {
  final int? id;
  const AccessoryFormScreen({super.key, this.id});

  @override
  State<AccessoryFormScreen> createState() => _AccessoryFormScreenState();
}

class _AccessoryFormScreenState extends State<AccessoryFormScreen> {
  late final AccessoryBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bloc = AccessoryBloc(AccessoryRepository(sl<ApiClient>()));
    if (widget.id != null) {
      _bloc.add(LoadAccessoryDetailEvent(widget.id!));
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _skuController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _populateForm(Map<String, dynamic> a) {
    _nameController.text = a['name']?.toString() ?? '';
    _skuController.text = a['sku']?.toString() ?? '';
    _modelController.text = a['model']?.toString() ?? '';
    _priceController.text = a['price']?.toString() ?? '';
    _costController.text = a['cost']?.toString() ?? '';
    _descriptionController.text = a['description']?.toString() ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'name': _nameController.text,
      'sku': _skuController.text,
      'model': _modelController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'cost': double.tryParse(_costController.text),
      'description': _descriptionController.text,
    };
    if (widget.id != null) {
      _bloc.add(UpdateAccessoryEvent(widget.id!, data));
    } else {
      _bloc.add(CreateAccessoryEvent(data));
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccessoryBloc>.value(
      value: _bloc,
      child: BlocListener<AccessoryBloc, AccessoryState>(
        listener: (context, state) {
          if (widget.id != null &&
              !_isLoading &&
              state.accessory != null &&
              _nameController.text.isEmpty) {
            _populateForm(state.accessory!);
            setState(() => _isLoading = false);
          }
          if (state.error != null && _isSaving) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.id != null ? 'Edit Accessory' : 'New Accessory'),
          ),
          body: _isLoading
              ? const LoadingWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'SKU',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modelController,
                          decoration: const InputDecoration(
                            labelText: 'Model',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price *',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Cost',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(widget.id != null
                                  ? 'Update'
                                  : 'Create'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
