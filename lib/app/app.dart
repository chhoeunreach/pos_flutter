import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router.dart';
import '../core/di/injection.dart';
import '../core/utils/money_formatter.dart';
import 'theme.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    authBloc.add(CheckAuthEvent());
    final router = createAppRouter(authBloc);
    final settingsBloc = sl<SettingsBloc>();
    settingsBloc.add(LoadSettingsEvent());

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<SettingsBloc>(create: (_) => settingsBloc),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState.settings != null) {
            final currency =
                settingsState.settings!['currency'] as Map<String, dynamic>?;
            if (currency != null) {
              MoneyFormatter.instance.configure(
                currencySymbol: currency['symbol'] as String? ?? '\$',
                decimalDigits: currency['precision'] as int? ?? 2,
              );
            }
          }

          return MaterialApp.router(
            title: 'POS App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
