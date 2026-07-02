import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import 'core/navigation/router_v2.dart';

class PosAppV2 extends StatelessWidget {
  const PosAppV2({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _AppV2Content(),
    );
  }
}

class _AppV2Content extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'KY Store v2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
