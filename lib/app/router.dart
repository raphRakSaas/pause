import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route names (single source of truth).
abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const _PlaceholderHome(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const _PlaceholderOnboarding(),
      ),
    ],
  );
});

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pause',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.onboarding),
              child: const Text('Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderOnboarding extends StatelessWidget {
  const _PlaceholderOnboarding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Retour'),
        ),
      ),
    );
  }
}
