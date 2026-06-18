import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() { super.initState(); sl<ContactBloc>().add(LoadSuppliersEvent()); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactBloc>(create: (_) => sl<ContactBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Suppliers'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => context.go('/suppliers/create'))]),
        body: BlocBuilder<ContactBloc, ContactState>(builder: (context, state) {
          if (state.isLoading) return const LoadingWidget();
          if (state.error != null) return Center(child: Text(state.error!));
          if (state.suppliers.isEmpty) return const Center(child: Text('No suppliers found'));
          return RefreshIndicator(onRefresh: () async => sl<ContactBloc>().add(LoadSuppliersEvent()), child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: state.suppliers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = state.suppliers[i];
              final due = (s['balance'] as num?)?.toDouble() ?? 0;
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.orange[100], child: Text((s['name'] as String? ?? '?')[0].toUpperCase(), style: TextStyle(color: Colors.orange[800]))),
                title: Text(s['name'] ?? ''),
                subtitle: Text('${s['mobile'] ?? '-'} | ${s['supplier_business_name'] ?? ''}'),
                trailing: due > 0 ? Text('Due: ${MoneyFormatter.instance.format(due)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 13)) : null,
                onTap: () => context.go('/suppliers/${s['id']}'),
              );
            },
          ));
        }),
      ),
    );
  }
}
