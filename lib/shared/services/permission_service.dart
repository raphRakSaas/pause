import 'package:flutter/services.dart';

/// Canal de communication avec le côté natif pour les permissions Android.
const MethodChannel _channel = MethodChannel('com.pause.pause/permissions');

/// Ouvre l'écran des réglages "Accès à l'utilisation" (Usage Access).
Future<void> openUsageAccessSettings() async {
  await _channel.invokeMethod<void>('openUsageAccessSettings');
}

/// Ouvre l'écran des réglages "Afficher par-dessus les autres apps" (Overlay).
Future<void> openOverlaySettings() async {
  await _channel.invokeMethod<void>('openOverlaySettings');
}

/// Ouvre la fiche Paramètres de l'app (Applications > Pause).
/// Depuis là, l'utilisateur peut activer « Afficher par-dessus les autres apps »
/// si l'app n'apparaît pas dans la liste « Vue premier plan ».
Future<void> openAppDetailSettings() async {
  await _channel.invokeMethod<void>('openAppDetailSettings');
}

/// Indique si l'app a l'accès aux statistiques d'utilisation (PACKAGE_USAGE_STATS).
Future<bool> hasUsageAccess() async {
  final result = await _channel.invokeMethod<bool>('hasUsageAccess');
  return result ?? false;
}

/// Indique si l'app peut dessiner par-dessus les autres (SYSTEM_ALERT_WINDOW).
Future<bool> canDrawOverlays() async {
  final result = await _channel.invokeMethod<bool>('canDrawOverlays');
  return result ?? false;
}
