import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/screens/apps_selection_screen.dart';
import '../features/onboarding/screens/friction_level_screen.dart';
import '../features/onboarding/screens/objective_screen.dart';
import '../features/onboarding/screens/permissions_screen.dart';

/// Route names (single source of truth).
abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingApps = '/onboarding/apps';
  static const String onboardingObjectif = '/onboarding/objectif';
  static const String onboardingFriction = '/onboarding/friction';
  static const String onboardingPermissions = '/onboarding/permissions';
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
        redirect: (context, state) => AppRoutes.onboardingApps,
      ),
      GoRoute(
        path: AppRoutes.onboardingApps,
        builder: (context, state) => const AppsSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingObjectif,
        builder: (context, state) => const ObjectiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingFriction,
        builder: (context, state) => const FrictionLevelScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPermissions,
        builder: (context, state) => const PermissionsScreen(),
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
