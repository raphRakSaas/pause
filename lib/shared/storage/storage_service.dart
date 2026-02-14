import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/event_decision.dart';
import '../models/event_reason.dart';
import '../models/micro_action_log.dart';
import '../models/settings.dart';

/// Noms des boxes Hive.
abstract final class BoxNames {
  static const String events = 'events';
  static const String microActionLogs = 'micro_action_logs';
  static const String settings = 'settings';
}

/// Clé du singleton Settings dans la box settings.
const String settingsKey = 'singleton';

const _uuid = Uuid();

/// Initialise Hive (Flutter), enregistre les adapters et ouvre les boxes.
/// À appeler une fois au démarrage (main() avant runApp).
Future<void> initStorage() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(EventAdapter())
    ..registerAdapter(MicroActionLogAdapter())
    ..registerAdapter(SettingsAdapter());
  await Future.wait([
    Hive.openBox<Event>(BoxNames.events),
    Hive.openBox<MicroActionLog>(BoxNames.microActionLogs),
    Hive.openBox<Settings>(BoxNames.settings),
  ]);
  final settingsBox = Hive.box<Settings>(BoxNames.settings);
  if (settingsBox.get(settingsKey) == null) {
    await settingsBox.put(settingsKey, const Settings());
  }
}

/// Enregistre un événement d'ouverture d'app (T11). Utilise reason/decision par défaut tant que l'utilisateur n'a pas choisi.
Future<void> addEvent({
  required String packageName,
  EventReason reason = EventReason.other,
  EventDecision decision = EventDecision.bypass,
  int? sessionDurationSec,
}) async {
  final box = Hive.box<Event>(BoxNames.events);
  final event = Event(
    id: _uuid.v4(),
    timestamp: DateTime.now(),
    packageName: packageName,
    decision: decision,
    reason: reason,
    sessionDurationSec: sessionDurationSec,
  );
  await box.put(event.id, event);
}
