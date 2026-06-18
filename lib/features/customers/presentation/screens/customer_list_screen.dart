import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    sl<ContactBloc>().add(LoadCustomersEvent());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactBloc>.value(value: sl<ContactBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Customers'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.go('/customers/create'))]),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Search by name, phone, or ID...', prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); sl<ContactBloc>().add(LoadCustomersEvent()); }) : null),
            onChanged: (v) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 400),
                  () => sl<ContactBloc>().add(LoadCustomersEvent(search: v)));
            },
          )),
          Expanded(child: BlocBuilder<ContactBloc, ContactState>(builder: (context, state) {
            if (state.isLoading) return const LoadingWidget();
            if (state.error != null) return AppErrorWidget(message: state.error!, onRetry: () => sl<ContactBloc>().add(LoadCustomersEvent()));
            if (state.customers.isEmpty) return const Center(child: Text('No customers found'));
            return RefreshIndicator(onRefresh: () async => sl<ContactBloc>().add(LoadCustomersEvent()), child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: state.customers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = state.customers[i];
                final balance = (c['balance'] as num?)?.toDouble() ?? 0;
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue[100],
                    child: Text((c['name'] as String? ?? '?')[0].toUpperCase(), style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold))),
                  title: Text(c['name'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('${c['mobile'] ?? '-'} | ${c['contact_id'] ?? ''}', style: Theme.of(context).textTheme.bodySmall),
                  trailing: balance > 0 ? Text('Due: ${MoneyFormatter.instance.format(balance)}', style: TextStyle(color: Colors.red[700], fontSize: 13, fontWeight: FontWeight.w500)) : null,
                  onTap: () => context.go('/customers/${c['id']}'),
                );
              },
            ));
          })),
        ]),
      ),
    );
  }
}
