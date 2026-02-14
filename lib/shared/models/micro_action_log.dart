import 'package:hive/hive.dart';

/// Log d'une micro-action effectuée (respiration, eau, etc.).
class MicroActionLog {
  const MicroActionLog({
    required this.id,
    required this.timestamp,
    required this.actionId,
    required this.durationSec,
  });

  final String id;
  final DateTime timestamp;
  final String actionId;
  final int durationSec;

  MicroActionLog copyWith({
    String? id,
    DateTime? timestamp,
    String? actionId,
    int? durationSec,
  }) {
    return MicroActionLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      actionId: actionId ?? this.actionId,
      durationSec: durationSec ?? this.durationSec,
    );
  }
}

class MicroActionLogAdapter extends TypeAdapter<MicroActionLog> {
  @override
  int get typeId => 1;

  @override
  MicroActionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    var id = '';
    DateTime timestamp = DateTime(0);
    var actionId = '';
    var durationSec = 0;
    for (var i = 0; i < numOfFields; i++) {
      switch (reader.readByte()) {
        case 0:
          id = reader.readString();
          break;
        case 1:
          timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 2:
          actionId = reader.readString();
          break;
        case 3:
          durationSec = reader.readInt();
          break;
        default:
          reader.skip(1);
      }
    }
    return MicroActionLog(
      id: id,
      timestamp: timestamp,
      actionId: actionId,
      durationSec: durationSec,
    );
  }

  @override
  void write(BinaryWriter writer, MicroActionLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..writeString(obj.id)
      ..writeByte(1)
      ..writeInt(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(2)
      ..writeString(obj.actionId)
      ..writeByte(3)
      ..writeInt(obj.durationSec);
  }
}
