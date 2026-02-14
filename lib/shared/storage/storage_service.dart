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

/// Enregistre un événement d'ouverture d'app (T11). Retourne l'id de l'event pour mise à jour session (T13).
Future<String> addEvent({
  required String packageName,
  required EventReason reason,
  required EventDecision decision,
  int? sessionDurationSec,
}) async {
  final box = Hive.box<Event>(BoxNames.events);
  final id = _uuid.v4();
  final event = Event(
    id: id,
    timestamp: DateTime.now(),
    packageName: packageName,
    decision: decision,
    reason: reason,
    sessionDurationSec: sessionDurationSec,
  );
  await box.put(event.id, event);
  return id;
}

/// Met à jour la durée effective d'une session (T13).
Future<void> updateEventSessionDuration(String eventId, int durationSec) async {
  final box = Hive.box<Event>(BoxNames.events);
  final event = box.get(eventId);
  if (event == null) return;
  await box.put(eventId, event.copyWith(sessionDurationSec: durationSec));
}

/// Enregistre une micro-action effectuée (T14).
Future<void> addMicroActionLog({
  required String actionId,
  required int durationSec,
}) async {
  final box = Hive.box<MicroActionLog>(BoxNames.microActionLogs);
  final log = MicroActionLog(
    id: _uuid.v4(),
    timestamp: DateTime.now(),
    actionId: actionId,
    durationSec: durationSec,
  );
  await box.put(log.id, log);
}

/// Retourne tous les événements (pour dashboard/stats). Les clés sont des id, pas des dates.
List<Event> getAllEvents() {
  final box = Hive.box<Event>(BoxNames.events);
  return box.values.toList();
}

/// Retourne tous les logs de micro-actions (pour stats).
List<MicroActionLog> getAllMicroActionLogs() {
  final box = Hive.box<MicroActionLog>(BoxNames.microActionLogs);
  return box.values.toList();
}
