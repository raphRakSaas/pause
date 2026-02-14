import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause/app/theme.dart';
import 'package:pause/features/dashboard/screens/dashboard_screen.dart';
import 'package:pause/shared/providers/stats_provider.dart';

void main() {
  group('DashboardScreen (Home)', () {
    testWidgets('affiche les stats quand données disponibles', (tester) async {
      const stats = DashboardStats(
        minutesToday: 25,
        opensToday: 4,
        progress: 0.35,
        streak: 2,
        dailyLimitMinutes: 120,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardStatsProvider.overrideWith((ref) => const AsyncValue.data(stats)),
          ],
          child: MaterialApp(
            theme: PauseTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aujourd\'hui'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('2 jours'), findsOneWidget);
      expect(find.text('25 / 120 min'), findsOneWidget);
      expect(find.text('Objectif du jour'), findsOneWidget);
      expect(find.text('Série'), findsOneWidget);
    });

    testWidgets('affiche loading puis données', (tester) async {
      const stats = DashboardStats(
        minutesToday: 0,
        opensToday: 0,
        progress: 0.0,
        streak: 0,
        dailyLimitMinutes: 60,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardStatsProvider.overrideWith((ref) => const AsyncValue.data(stats)),
          ],
          child: MaterialApp(
            theme: PauseTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aujourd\'hui'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text('Série'), findsOneWidget);
      expect(find.text('0 jour'), findsOneWidget);
    });

    testWidgets('affiche erreur quand provider en erreur', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardStatsProvider.overrideWith((ref) => AsyncValue.error(
              Exception('Erreur test'),
              StackTrace.current,
            )),
          ],
          child: MaterialApp(
            theme: PauseTheme.light,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur'), findsOneWidget);
    });
  });
}
