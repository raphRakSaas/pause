// Smoke test Home (Dashboard) — Sprint 5 T19.
// Voir dashboard_screen_test.dart pour les tests détaillés.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause/app/theme.dart';
import 'package:pause/features/dashboard/screens/dashboard_screen.dart';
import 'package:pause/shared/providers/stats_provider.dart';

void main() {
  testWidgets('Home (Dashboard) s\'affiche avec des stats mockées', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWith((ref) => const AsyncValue.data(
            DashboardStats(
              minutesToday: 0,
              opensToday: 0,
              progress: 0.0,
              streak: 0,
              dailyLimitMinutes: 120,
            ),
          )),
        ],
        child: MaterialApp(
          theme: PauseTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.text('Série'), findsOneWidget);
  });
}
