import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class PauseApp extends ConsumerWidget {
  const PauseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Pause',
      theme: PauseTheme.light,
      darkTheme: PauseTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
