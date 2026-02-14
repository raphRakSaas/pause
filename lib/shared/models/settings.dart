import 'package:hive/hive.dart';

import 'friction_level.dart';

/// Paramètres utilisateur (onboarding + réglages).
/// noScrollAfterMinutes: minutes depuis minuit (ex: 22h30 = 22*60+30), null = désactivé.
class Settings {
  const Settings({
    this.targetApps = const [],
    this.dailyLimitMinutes = 120,
    this.noScrollAfterMinutes,
    this.frictionLevel = FrictionLevel.medium,
    this.sessionDefaultMinutes = 5,
  });

  final List<String> targetApps;
  final int dailyLimitMinutes;
  final int? noScrollAfterMinutes;
  final FrictionLevel frictionLevel;
  final int sessionDefaultMinutes;

  Settings copyWith({
    List<String>? targetApps,
    int? dailyLimitMinutes,
    int? noScrollAfterMinutes,
    FrictionLevel? frictionLevel,
    int? sessionDefaultMinutes,
  }) {
    return Settings(
      targetApps: targetApps ?? this.targetApps,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      noScrollAfterMinutes: noScrollAfterMinutes ?? this.noScrollAfterMinutes,
      frictionLevel: frictionLevel ?? this.frictionLevel,
      sessionDefaultMinutes:
          sessionDefaultMinutes ?? this.sessionDefaultMinutes,
    );
  }
}

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  int get typeId => 2;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    List<String> targetApps = [];
    var dailyLimitMinutes = 120;
    int? noScrollAfterMinutes;
    var frictionLevel = FrictionLevel.medium;
    var sessionDefaultMinutes = 5;
    for (var i = 0; i < numOfFields; i++) {
      switch (reader.readByte()) {
        case 0:
          targetApps = List<String>.from(reader.readList());
          break;
        case 1:
          dailyLimitMinutes = reader.readInt();
          break;
        case 2:
          final v = reader.readInt();
          noScrollAfterMinutes = v < 0 ? null : v;
          break;
        case 3:
          frictionLevel = FrictionLevel.values[reader.readByte()];
          break;
        case 4:
          sessionDefaultMinutes = reader.readInt();
          break;
        default:
          reader.skip(1);
      }
    }
    return Settings(
      targetApps: targetApps,
      dailyLimitMinutes: dailyLimitMinutes,
      noScrollAfterMinutes: noScrollAfterMinutes,
      frictionLevel: frictionLevel,
      sessionDefaultMinutes: sessionDefaultMinutes,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..writeList(obj.targetApps)
      ..writeByte(1)
      ..writeInt(obj.dailyLimitMinutes)
      ..writeByte(2)
      ..writeInt(obj.noScrollAfterMinutes ?? -1)
      ..writeByte(3)
      ..writeByte(obj.frictionLevel.index)
      ..writeByte(4)
      ..writeInt(obj.sessionDefaultMinutes);
  }
}
