import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause/shared/models/event.dart';
import 'package:pause/shared/models/event_decision.dart';
import 'package:pause/shared/models/event_reason.dart';
import 'package:pause/shared/models/micro_action_log.dart';
import 'package:pause/shared/providers/stats_provider.dart';

void main() {
  group('DashboardStats.compute', () {
    test('minutes aujourd\'hui: somme des sessionShort avec sessionDurationSec', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final todayStart = DateTime(2025, 2, 14);
      final events = [
        Event(
          id: '1',
          timestamp: todayStart.add(const Duration(hours: 1)),
          packageName: 'com.example',
          decision: EventDecision.sessionShort,
          reason: EventReason.bored,
          sessionDurationSec: 5 * 60, // 5 min
        ),
        Event(
          id: '2',
          timestamp: todayStart.add(const Duration(hours: 2)),
          packageName: 'com.example',
          decision: EventDecision.sessionShort,
          reason: EventReason.stress,
          sessionDurationSec: 3 * 60, // 3 min
        ),
      ];
      final stats = DashboardStats.compute(events, [], 120, now);
      expect(stats.minutesToday, 8);
      expect(stats.opensToday, 2);
      expect(stats.dailyLimitMinutes, 120);
    });

    test('ouvertures aujourd\'hui: tous les events du jour', () {
      final now = DateTime(2025, 2, 14, 15, 0);
      final todayStart = DateTime(2025, 2, 14);
      final events = [
        Event(
          id: '1',
          timestamp: todayStart,
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: '2',
          timestamp: todayStart.add(const Duration(hours: 1)),
          packageName: 'b',
          decision: EventDecision.microAction,
          reason: EventReason.quick5,
        ),
      ];
      final stats = DashboardStats.compute(events, [], 60, now);
      expect(stats.minutesToday, 0);
      expect(stats.opensToday, 2);
    });

    test('progress plafonné à 1.0', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final todayStart = DateTime(2025, 2, 14);
      final events = [
        Event(
          id: '1',
          timestamp: todayStart,
          packageName: 'x',
          decision: EventDecision.sessionShort,
          reason: EventReason.other,
          sessionDurationSec: 90 * 60, // 90 min
        ),
      ];
      final stats = DashboardStats.compute(events, [], 60, now);
      expect(stats.minutesToday, 90);
      expect(stats.progress, 1.0);
    });

    test('streak: jours consécutifs avec activité (events ou logs)', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final day0 = DateTime(2025, 2, 14);
      final day1 = DateTime(2025, 2, 13);
      final day2 = DateTime(2025, 2, 12);
      final events = [
        Event(
          id: 'today',
          timestamp: day0.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: 'yesterday',
          timestamp: day1.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: '2days',
          timestamp: day2.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
      ];
      final stats = DashboardStats.compute(events, [], 120, now);
      expect(stats.streak, 3);
    });

    test('streak: coupure si un jour sans activité', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final day0 = DateTime(2025, 2, 14);
      final day1 = DateTime(2025, 2, 13);
      final day3 = DateTime(2025, 2, 11); // 12 fév sans event
      final events = [
        Event(
          id: 'today',
          timestamp: day0.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: 'yesterday',
          timestamp: day1.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: '3days',
          timestamp: day3.add(const Duration(hours: 10)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
      ];
      final stats = DashboardStats.compute(events, [], 120, now);
      expect(stats.streak, 2);
    });

    test('streak inclut les micro-action logs', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final day0 = DateTime(2025, 2, 14);
      final logs = [
        MicroActionLog(
          id: 'log1',
          timestamp: day0.add(const Duration(hours: 8)),
          actionId: 'breath',
          durationSec: 30,
        ),
      ];
      final stats = DashboardStats.compute([], logs, 120, now);
      expect(stats.streak, 1);
      expect(stats.opensToday, 0);
      expect(stats.minutesToday, 0);
    });
  });

  group('Stats7.compute', () {
    test('minutesPerDay: 7 jours dont aujourd\'hui', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final events = [
        Event(
          id: '1',
          timestamp: DateTime(2025, 2, 14, 10, 0),
          packageName: 'a',
          decision: EventDecision.sessionShort,
          reason: EventReason.other,
          sessionDurationSec: 10 * 60,
        ),
      ];
      final stats = Stats7.compute(events, now);
      expect(stats.minutesPerDay.length, 7);
      final lastDay = stats.minutesPerDay.last;
      expect(lastDay.day, DateTime(2025, 2, 14));
      expect(lastDay.minutes, 10);
    });

    test('topReasons: décompte par raison sur 7j', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final sevenDaysAgo = now.subtract(const Duration(days: 3));
      final events = [
        Event(
          id: '1',
          timestamp: sevenDaysAgo,
          packageName: 'a',
          decision: EventDecision.sessionShort,
          reason: EventReason.bored,
          sessionDurationSec: 300,
        ),
        Event(
          id: '2',
          timestamp: sevenDaysAgo.add(const Duration(hours: 1)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.bored,
        ),
        Event(
          id: '3',
          timestamp: sevenDaysAgo.add(const Duration(hours: 2)),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.stress,
        ),
      ];
      final stats = Stats7.compute(events, now);
      expect(stats.topReasons[EventReason.bored], 2);
      expect(stats.topReasons[EventReason.stress], 1);
    });

    test('peakHours: décompte par heure sur 7j', () {
      final now = DateTime(2025, 2, 14, 12, 0);
      final t = now.subtract(const Duration(days: 1));
      final events = [
        Event(
          id: '1',
          timestamp: DateTime(t.year, t.month, t.day, 14, 0),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
        Event(
          id: '2',
          timestamp: DateTime(t.year, t.month, t.day, 14, 30),
          packageName: 'a',
          decision: EventDecision.bypass,
          reason: EventReason.other,
        ),
      ];
      final stats = Stats7.compute(events, now);
      expect(stats.peakHours[14], 2);
    });
  });
}
