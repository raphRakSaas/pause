import 'package:flutter/services.dart';

/// Canal pour démarrer/arrêter le service de surveillance (T8).
const MethodChannel _channel = MethodChannel('com.pause.pause/permissions');

/// Démarre le foreground service qui poll l'app au premier plan.
Future<void> startMonitorService() async {
  await _channel.invokeMethod<void>('startMonitorService');
}

/// Arrête le service de surveillance.
Future<void> stopMonitorService() async {
  await _channel.invokeMethod<void>('stopMonitorService');
}
