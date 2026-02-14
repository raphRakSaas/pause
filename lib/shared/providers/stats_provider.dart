import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/event.dart';
import '../models/event_decision.dart';
import '../models/event_reason.dart';
import '../models/micro_action_log.dart';
import '../models/settings.dart';
import '../storage/storage_service.dart';
import 'settings_provider.dart';

/// Données agrégées pour le dashboard (T15).
class DashboardStats {
  const DashboardStats({
    required this.minutesToday,
    required this.opensToday,
    required this.progress,
    required this.streak,
    this.dailyLimitMinutes = 120,
  });

  final int minutesToday;
  final int opensToday;
  final double progress;
  final int streak;
  final int dailyLimitMinutes;

  static DashboardStats _compute(
    List<Event> events,
    List<MicroActionLog> logs,
    int dailyLimitMinutes,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final eventsToday =
        events.where((e) => e.timestamp.isAfter(todayStart)).toList();
    final minutesToday = eventsToday
        .where((e) => e.decision == EventDecision.sessionShort)
        .fold<int>(
          0,
          (sum, e) => sum + ((e.sessionDurationSec ?? 0) ~/ 60),
        );
    final opensToday = eventsToday.length;

    final progress = dailyLimitMinutes > 0
        ? (minutesToday / dailyLimitMinutes).clamp(0.0, 1.0)
        : 0.0;

    int streak = 0;
    var day = todayStart;
    while (true) {
      final dayEnd = day.add(const Duration(days: 1));
      final hasActivity = events.any((e) =>
              e.timestamp.isAfter(day) && e.timestamp.isBefore(dayEnd)) ||
          logs.any((l) =>
              l.timestamp.isAfter(day) && l.timestamp.isBefore(dayEnd));
      if (!hasActivity) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return DashboardStats(
      minutesToday: minutesToday,
      opensToday: opensToday,
      progress: progress,
      streak: streak,
      dailyLimitMinutes: dailyLimitMinutes,
    );
  }
}

/// Données pour l'écran Stats 7j (T16).
class Stats7 {
  const Stats7({
    required this.minutesPerDay,
    required this.topReasons,
    required this.peakHours,
  });

  final List<({DateTime day, int minutes})> minutesPerDay;
  final Map<EventReason, int> topReasons;
  final Map<int, int> peakHours;

  static Stats7 _compute(List<Event> events) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final minutesPerDay = days.map((day) {
      final dayEnd = day.add(const Duration(days: 1));
      final dayEvents = events
          .where((e) =>
              e.timestamp.isAfter(day) &&
              e.timestamp.isBefore(dayEnd) &&
              e.decision == EventDecision.sessionShort)
          .toList();
      final minutes = dayEvents.fold<int>(
        0,
        (sum, e) => sum + ((e.sessionDurationSec ?? 0) ~/ 60),
      );
      return (day: day, minutes: minutes);
    }).toList();

    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentEvents =
        events.where((e) => e.timestamp.isAfter(sevenDaysAgo)).toList();

    final topReasons = <EventReason, int>{};
    for (final r in EventReason.values) {
      topReasons[r] = recentEvents.where((e) => e.reason == r).length;
    }

    final peakHours = <int, int>{};
    for (var h = 0; h < 24; h++) {
      peakHours[h] = recentEvents
          .where((e) => e.timestamp.hour == h)
          .length;
    }

    return Stats7(
      minutesPerDay: minutesPerDay,
      topReasons: topReasons,
      peakHours: peakHours,
    );
  }
}

final _eventsBoxProvider = Provider<Box<Event>>((ref) {
  return Hive.box<Event>(BoxNames.events);
});

final _microActionLogsBoxProvider = Provider<Box<MicroActionLog>>((ref) {
  return Hive.box<MicroActionLog>(BoxNames.microActionLogs);
});

/// Stream qui émet à chaque changement des events ou des logs.
final _dataChangeStreamProvider = Provider<Stream<void>>((ref) {
  final eventsBox = ref.watch(_eventsBoxProvider);
  final logsBox = ref.watch(_microActionLogsBoxProvider);
  final c = StreamController<void>.broadcast(sync: true);
  final sub1 = eventsBox.watch().listen((_) => c.add(null));
  final sub2 = logsBox.watch().listen((_) => c.add(null));
  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    c.close();
  });
  return c.stream;
});

/// Liste des events (réactive aux changements Hive).
final eventsListProvider = StreamProvider<List<Event>>((ref) async* {
  final box = ref.watch(_eventsBoxProvider);
  yield box.values.toList();
  await for (final _ in ref.watch(_dataChangeStreamProvider)) {
    yield box.values.toList();
  }
});

/// Liste des logs micro-actions (réactive).
final microActionLogsListProvider = StreamProvider<List<MicroActionLog>>((ref) async* {
  final box = ref.watch(_microActionLogsBoxProvider);
  yield box.values.toList();
  await for (final _ in ref.watch(_dataChangeStreamProvider)) {
    yield box.values.toList();
  }
});

/// Stats dashboard (T15) : minutes aujourd'hui, ouvertures, progression, streak.
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final eventsAsync = ref.watch(eventsListProvider);
  final logsAsync = ref.watch(microActionLogsListProvider);
  final settings = ref.watch(settingsProvider).valueOrNull ?? const Settings();

  return eventsAsync.when(
    data: (events) => logsAsync.when(
      data: (logs) => AsyncValue.data(DashboardStats._compute(
        events,
        logs,
        settings.dailyLimitMinutes,
      )),
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Stats 7 jours (T16) : tendance, top raisons, heures de pic.
final stats7Provider = Provider<AsyncValue<Stats7>>((ref) {
  final eventsAsync = ref.watch(eventsListProvider);
  return eventsAsync.when(
    data: (events) => AsyncValue.data(Stats7._compute(events)),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
