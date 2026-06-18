import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import '../core/di/injection.dart';
import '../core/utils/money_formatter.dart';
import 'theme.dart';

class PosApp extends StatefulWidget {
  const PosApp({super.key});

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  late final AuthBloc _authBloc;
  late final SettingsBloc _settingsBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(CheckAuthEvent());
    _settingsBloc = sl<SettingsBloc>()..add(LoadSettingsEvent());
    _router = createAppRouter(_authBloc);
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<SettingsBloc>.value(value: _settingsBloc),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          if (settingsState.settings != null) {
            final data = settingsState.settings!['data']
                as Map<String, dynamic>? ??
                {};
            final business =
                data['business'] as Map<String, dynamic>? ?? {};
            final currency =
                business['currency'] as Map<String, dynamic>?;
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
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
