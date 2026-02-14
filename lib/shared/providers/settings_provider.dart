import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/friction_level.dart';
import '../models/settings.dart';
import '../storage/storage_service.dart';

/// Accès à la box Settings (doit être initialisé après initStorage).
final settingsBoxProvider = Provider<Box<Settings>>((ref) {
  return Hive.box<Settings>(BoxNames.settings);
});

/// Settings actuels (lecture/écriture). Persistés dans Hive.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Settings>>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return SettingsNotifier(box);
});

class SettingsNotifier extends StateNotifier<AsyncValue<Settings>> {
  SettingsNotifier(this._box) : super(AsyncValue.data(_box.get(settingsKey) ?? const Settings())) {
    _subscription = _box.watch().listen((_) {
      state = AsyncValue.data(_box.get(settingsKey) ?? const Settings());
    });
  }

  final Box<Settings> _box;
  late final StreamSubscription<BoxEvent> _subscription;

  Settings get _current => _box.get(settingsKey) ?? const Settings();

  Future<void> update(Settings Function(Settings current) fn) async {
    final next = fn(_current);
    await _box.put(settingsKey, next);
    state = AsyncValue.data(next);
  }

  Future<void> setTargetApps(List<String> apps) async {
    await update((s) => s.copyWith(targetApps: apps));
  }

  Future<void> setDailyLimitMinutes(int minutes) async {
    await update((s) => s.copyWith(dailyLimitMinutes: minutes));
  }

  Future<void> setNoScrollAfterMinutes(int? minutesSinceMidnight) async {
    await update((s) => s.copyWith(noScrollAfterMinutes: minutesSinceMidnight));
  }

  Future<void> setFrictionLevel(FrictionLevel level) async {
    await update((s) => s.copyWith(frictionLevel: level));
  }
}
