import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/server_presets.dart';
import '../../../../core/di/injection.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    sl<SettingsBloc>().add(LoadSettingsEvent());
  }

  Future<void> _changeServer(BuildContext context) async {
    final shouldChange = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Server'),
        content: const Text(
            'This will disconnect you from the current server. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Change')),
        ],
      ),
    );

    if (shouldChange != true || !mounted) return;

    await AppConfig.clear();
    await sl<ApiClient>().clearToken();
    await sl<ApiClient>().updateBaseUrl('');
    if (!mounted || !context.mounted) return;
    context.read<AuthBloc>().add(LogoutEvent());
    context.go('/connect');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>.value(
      value: sl<SettingsBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body:
            BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.settings == null) {
            return const Center(child: Text('No settings'));
          }

          final business = (state.settings!['data'] as Map?)?['business']
                  as Map<String, dynamic>? ??
              {};
          final locations =
              (state.settings!['data'] as Map?)?['locations'] as List? ?? [];
          final taxRates =
              (state.settings!['data'] as Map?)?['tax_rates'] as List? ?? [];
          final paymentAccounts =
              (state.settings!['data'] as Map?)?['payment_accounts'] as List? ??
                  [];
          final currency = business['currency'] as Map<String, dynamic>? ?? {};

          return ListView(padding: const EdgeInsets.all(16), children: [
            Text('Business', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark theme'),
                  value: false,
                  onChanged: (_) {}),
            ])),
            const SizedBox(height: 16),
            Text('Business Info',
                style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              ListTile(
                  title: const Text('Name'),
                  subtitle: Text(business['name'] ?? '')),
              ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(business['start_date'] ?? '')),
              ListTile(
                  title: const Text('Default Profit %'),
                  subtitle:
                      Text('${business['default_profit_percent'] ?? 25}%')),
            ])),
            const SizedBox(height: 16),
            Text('Currency', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              ListTile(
                  title: const Text('Code'),
                  subtitle: Text(currency['code'] ?? 'USD')),
              ListTile(
                  title: const Text('Symbol'),
                  subtitle: Text(currency['symbol'] ?? '\$')),
              ListTile(
                  title: const Text('Precision'),
                  subtitle:
                      Text('${business['currency_precision'] ?? 2} decimals')),
              ListTile(
                  title: const Text('Format'),
                  subtitle: Text(
                      '${currency['thousand_separator'] ?? ','} separator, ${currency['decimal_separator'] ?? '.'} decimal')),
            ])),
            const SizedBox(height: 16),
            Text('Locations', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              if (locations.isEmpty)
                const ListTile(title: Text('No locations'))
              else
                ...locations.map((l) => ListTile(
                      title: Text(l['name'] ?? ''),
                      subtitle: Text('${l['city'] ?? ''}, ${l['state'] ?? ''}'),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                    )),
            ])),
            const SizedBox(height: 16),
            Text('Tax Rates', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              if (taxRates.isEmpty)
                const ListTile(title: Text('No tax rates'))
              else
                ...taxRates.map((t) => ListTile(
                    title: Text(t['name'] ?? ''),
                    subtitle: Text('${t['amount']}%'),
                    trailing: t['is_tax_group'] == true
                        ? const Chip(
                            label:
                                Text('Group', style: TextStyle(fontSize: 11)))
                        : null)),
            ])),
            const SizedBox(height: 16),
            Text('Payment Accounts',
                style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              if (paymentAccounts.isEmpty)
                const ListTile(title: Text('No accounts'))
              else
                ...paymentAccounts.map((a) => ListTile(
                    title: Text(a['name'] ?? ''),
                    subtitle: Text(a['account_type'] ?? ''))),
            ])),
            const SizedBox(height: 16),
            Text('Server', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              ListTile(
                title: Text(
                    'Current Server: ${ServerPresets.displayName(AppConfig.serverUrl)}'),
                subtitle: Text(AppConfig.serverUrl ??
                    'Disconnect and connect to a different server'),
                leading: const Icon(Icons.dns_outlined),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _changeServer(context),
              ),
            ])),
            const SizedBox(height: 16),
            Text('Account', style: Theme.of(context).textTheme.titleLarge),
            Card(
                child: Column(children: [
              ListTile(
                title: const Text('Logout'),
                leading: const Icon(Icons.logout, color: Colors.red),
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthBloc>().add(LogoutEvent());
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Logout'))
                          ],
                        )),
              ),
            ])),
          ]);
        }),
      ),
    );
  }
}
