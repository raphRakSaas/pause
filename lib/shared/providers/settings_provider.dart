import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/friction_level.dart';
import '../models/micro_action.dart';
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

  /// T17 — Active/désactive une micro-action par id.
  Future<void> setMicroActionEnabled(String actionId, bool enabled) async {
    final current = _current.disabledMicroActionIds.toSet();
    if (enabled) {
      current.remove(actionId);
    } else {
      current.add(actionId);
    }
    await update((s) => s.copyWith(disabledMicroActionIds: current.toList()));
  }
}

/// Liste des micro-actions activées (pour T14 run : ne proposer que celles-ci).
/// Si toutes sont désactivées, on renvoie toutes les defs pour éviter un écran vide.
final enabledMicroActionDefsProvider = Provider<List<MicroActionDef>>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull ?? const Settings();
  final disabled = settings.disabledMicroActionIds.toSet();
  final enabled = microActionDefs.where((d) => !disabled.contains(d.id)).toList();
  return enabled.isEmpty ? microActionDefs : enabled;
});
