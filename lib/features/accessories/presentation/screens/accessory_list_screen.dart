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

class AccessoryListScreen extends StatefulWidget {
  const AccessoryListScreen({super.key});

  @override
  State<AccessoryListScreen> createState() => _AccessoryListScreenState();
}

class _AccessoryListScreenState extends State<AccessoryListScreen> {
  late final AccessoryBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = AccessoryBloc(AccessoryRepository(sl<ApiClient>()));
    _bloc.add(LoadAccessoriesEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccessoryBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accessories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/accessories/create'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search accessories...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _bloc.add(LoadAccessoriesEvent());
                          },
                        )
                      : null,
                ),
                onChanged: (v) =>
                    _bloc.add(LoadAccessoriesEvent(search: v)),
              ),
            ),
            Expanded(
              child: BlocBuilder<AccessoryBloc, AccessoryState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const LoadingWidget();
                  }
                  if (state.error != null) {
                    return AppErrorWidget(
                      message: state.error!,
                      onRetry: () => _bloc.add(LoadAccessoriesEvent()),
                    );
                  }
                  if (state.accessories.isEmpty) {
                    return const Center(child: Text('No accessories found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        _bloc.add(LoadAccessoriesEvent()),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.accessories.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final a = state.accessories[i];
                        return ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.build,
                                color: Colors.grey[400]),
                          ),
                          title: Text(
                            a['name'] ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Row(
                            children: [
                              if (a['sku'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    a['sku'].toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (a['model'] != null)
                                Text(
                                  a['model'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: a['price'] != null
                              ? Text(
                                  MoneyFormatter.instance.format(a['price']),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                )
                              : null,
                          onTap: () =>
                              context.go('/accessories/${a['id']}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
