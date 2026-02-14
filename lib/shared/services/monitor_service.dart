import 'dart:async';
import 'package:flutter/services.dart';

/// Canal pour démarrer/arrêter le service de surveillance (T8) et recevoir appOpened (T9).
const MethodChannel _channel = MethodChannel('com.pause.pause/permissions');
const EventChannel _appOpenedChannel = EventChannel('com.pause.pause/appOpened');

/// Démarre le foreground service qui poll l'app au premier plan.
/// [targetPackages] : liste des packages à surveiller (apps ciblées).
Future<void> startMonitorService(List<String> targetPackages) async {
  await _channel.invokeMethod<void>('startMonitorService', targetPackages);
}

/// Arrête le service de surveillance.
Future<void> stopMonitorService() async {
  await _channel.invokeMethod<void>('stopMonitorService');
}

/// Stream des ouvertures d'apps ciblées. Émet le [packageName] quand une app ciblée passe au premier plan.
Stream<String> get appOpenedStream =>
    _appOpenedChannel.receiveBroadcastStream().map((e) => e as String);
