import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../data/accessory_repository.dart';
import '../../application/accessory_bloc.dart';

class AccessoryDetailScreen extends StatefulWidget {
  final int id;
  const AccessoryDetailScreen({super.key, required this.id});

  @override
  State<AccessoryDetailScreen> createState() => _AccessoryDetailScreenState();
}

class _AccessoryDetailScreenState extends State<AccessoryDetailScreen> {
  late final AccessoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = AccessoryBloc(AccessoryRepository(sl<ApiClient>()));
    _bloc.add(LoadAccessoryDetailEvent(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccessoryBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accessory'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/accessories/${widget.id}/edit'),
            ),
          ],
        ),
        body: BlocBuilder<AccessoryBloc, AccessoryState>(
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            if (state.error != null) {
              return AppErrorWidget(
                message: state.error!,
                onRetry: () =>
                    _bloc.add(LoadAccessoryDetailEvent(widget.id)),
              );
            }
            final a = state.accessory;
            if (a == null || a.isEmpty) {
              return const Center(child: Text('Not found'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: a['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    a['image_url'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.build,
                                  size: 60, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        if (a['sku'] != null)
                          Text(a['sku'].toString(),
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (a['name'] != null)
                    _infoRow(context, 'Name', a['name']),
                  if (a['model'] != null)
                    _infoRow(context, 'Model', a['model']),
                  if (a['price'] != null)
                    _infoRow(context, 'Price',
                        MoneyFormatter.instance.format(a['price']),
                        bold: true),
                  if (a['cost'] != null)
                    _infoRow(
                        context, 'Cost', MoneyFormatter.instance.format(a['cost'])),
                  if (a['description'] != null &&
                      a['description'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Description',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(a['description'].toString()),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600])),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
