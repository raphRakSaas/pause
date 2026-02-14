import 'package:hive/hive.dart';

import 'event_decision.dart';
import 'event_reason.dart';

/// Événement enregistré à chaque passage par l'overlay friction.
class Event {
  const Event({
    required this.id,
    required this.timestamp,
    required this.packageName,
    required this.decision,
    required this.reason,
    this.sessionDurationSec,
  });

  final String id;
  final DateTime timestamp;
  final String packageName;
  final EventDecision decision;
  final EventReason reason;
  final int? sessionDurationSec;

  Event copyWith({
    String? id,
    DateTime? timestamp,
    String? packageName,
    EventDecision? decision,
    EventReason? reason,
    int? sessionDurationSec,
  }) {
    return Event(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      packageName: packageName ?? this.packageName,
      decision: decision ?? this.decision,
      reason: reason ?? this.reason,
      sessionDurationSec: sessionDurationSec ?? this.sessionDurationSec,
    );
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  int get typeId => 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    var id = '';
    DateTime timestamp = DateTime(0);
    var packageName = '';
    var decision = EventDecision.bypass;
    var reason = EventReason.other;
    int? sessionDurationSec;
    for (var i = 0; i < numOfFields; i++) {
      switch (reader.readByte()) {
        case 0:
          id = reader.readString();
          break;
        case 1:
          timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 2:
          packageName = reader.readString();
          break;
        case 3:
          decision = EventDecision.values[reader.readByte()];
          break;
        case 4:
          reason = EventReason.values[reader.readByte()];
          break;
        case 5:
          final v = reader.readInt();
          sessionDurationSec = v < 0 ? null : v;
          break;
        default:
          reader.skip(1);
      }
    }
    return Event(
      id: id,
      timestamp: timestamp,
      packageName: packageName,
      decision: decision,
      reason: reason,
      sessionDurationSec: sessionDurationSec,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..writeString(obj.id)
      ..writeByte(1)
      ..writeInt(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(2)
      ..writeString(obj.packageName)
      ..writeByte(3)
      ..writeByte(obj.decision.index)
      ..writeByte(4)
      ..writeByte(obj.reason.index)
      ..writeByte(5)
      ..writeInt(obj.sessionDurationSec ?? -1);
  }
}
