import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/onboarding/screens/apps_selection_screen.dart';
import '../features/onboarding/screens/friction_level_screen.dart';
import '../features/onboarding/screens/objective_screen.dart';
import '../features/onboarding/screens/permissions_screen.dart';
import '../features/micro_actions/screens/micro_action_run_screen.dart';
import '../features/overlay_friction/screens/overlay_friction_screen.dart';
import '../features/overlay_friction/screens/session_timer_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/stats/screens/stats_screen.dart';
import '../shared/services/monitor_service.dart';

/// Route names (single source of truth).
abstract final class AppRoutes {
  static const String home = '/';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String onboardingApps = '/onboarding/apps';
  static const String onboardingObjectif = '/onboarding/objectif';
  static const String onboardingFriction = '/onboarding/friction';
  static const String onboardingPermissions = '/onboarding/permissions';
  static const String overlayFriction = '/overlay-friction';
  static const String sessionTimer = '/session-timer';
  static const String microAction = '/micro-action';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => _AppOpenedListener(
          child: _MainShell(path: state.uri.path, child: child),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.stats,
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            redirect: (context, state) => AppRoutes.onboardingApps,
          ),
          GoRoute(
            path: AppRoutes.onboardingApps,
            builder: (context, state) {
              final fromSettings =
                  state.uri.queryParameters['fromSettings'] == '1';
              return AppsSelectionScreen(fromSettings: fromSettings);
            },
          ),
          GoRoute(
            path: AppRoutes.onboardingObjectif,
            builder: (context, state) {
              final fromSettings =
                  state.uri.queryParameters['fromSettings'] == '1';
              return ObjectiveScreen(fromSettings: fromSettings);
            },
          ),
          GoRoute(
            path: AppRoutes.onboardingFriction,
            builder: (context, state) {
              final fromSettings =
                  state.uri.queryParameters['fromSettings'] == '1';
              return FrictionLevelScreen(fromSettings: fromSettings);
            },
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
          GoRoute(
            path: AppRoutes.sessionTimer,
            builder: (context, state) {
              final eventId =
                  state.uri.queryParameters['eventId'] ?? '';
              return SessionTimerScreen(eventId: eventId);
            },
          ),
          GoRoute(
            path: AppRoutes.microAction,
            builder: (context, state) => const MicroActionRunScreen(),
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
      _sub = appOpenedStream.listen(
        (pkg) async {
          if (!mounted) return;
          router.push('${AppRoutes.overlayFriction}?package=${Uri.encodeComponent(pkg)}');
        },
        onError: (Object e, StackTrace st) {
          // Permission retirée ou erreur plateforme : ne pas crasher (TESTPLAN cas limites).
          assert(() {
            // ignore: avoid_print
            debugPrint('appOpenedStream error: $e\n$st');
            return true;
          }());
        },
      );
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

/// Affiche la barre d'onglets (Home | Stats | Profil) uniquement sur les routes principales.
class _MainShell extends StatelessWidget {
  const _MainShell({required this.path, required this.child});

  final String path;
  final Widget child;

  static const _mainPaths = [AppRoutes.home, AppRoutes.stats, AppRoutes.settings];

  int get _selectedIndex {
    final i = _mainPaths.indexOf(path);
    return i >= 0 ? i : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_mainPaths.contains(path)) {
      return child;
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          final loc = _mainPaths[index];
          if (loc != path) {
            context.go(loc);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
