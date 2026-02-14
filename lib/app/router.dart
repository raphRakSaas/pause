import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/screens/apps_selection_screen.dart';
import '../features/onboarding/screens/friction_level_screen.dart';
import '../features/onboarding/screens/objective_screen.dart';
import '../features/onboarding/screens/permissions_screen.dart';
import '../features/overlay_friction/screens/overlay_friction_screen.dart';
import '../shared/services/monitor_service.dart';
import '../shared/storage/storage_service.dart';

/// Route names (single source of truth).
abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String onboardingApps = '/onboarding/apps';
  static const String onboardingObjectif = '/onboarding/objectif';
  static const String onboardingFriction = '/onboarding/friction';
  static const String onboardingPermissions = '/onboarding/permissions';
  static const String overlayFriction = '/overlay-friction';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            _AppOpenedListener(child: child),
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
          GoRoute(
            path: AppRoutes.overlayFriction,
            builder: (context, state) {
              final pkg = state.uri.queryParameters['package'] ?? '';
              return OverlayFrictionScreen(packageName: pkg);
            },
          ),
        ],
      ),
    ],
  );
});

/// Écoute le stream appOpened (T9), log l'event (T11) et navigue vers l'overlay friction (T10).
class _AppOpenedListener extends ConsumerStatefulWidget {
  const _AppOpenedListener({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppOpenedListener> createState() => _AppOpenedListenerState();
}

class _AppOpenedListenerState extends ConsumerState<_AppOpenedListener> {
  StreamSubscription<String>? _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub == null) {
      final router = ref.read(goRouterProvider);
      _sub = appOpenedStream.listen((pkg) async {
        await addEvent(packageName: pkg);
        if (!mounted) return;
        router.push('${AppRoutes.overlayFriction}?package=${Uri.encodeComponent(pkg)}');
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

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
