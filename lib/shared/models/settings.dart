import 'package:hive/hive.dart';

import 'friction_level.dart';

/// Paramètres utilisateur (onboarding + réglages).
/// noScrollAfterMinutes: minutes depuis minuit (ex: 22h30 = 22*60+30), null = désactivé.
/// disabledMicroActionIds: ids des micro-actions désactivées (T17).
class Settings {
  const Settings({
    this.targetApps = const [],
    this.dailyLimitMinutes = 120,
    this.noScrollAfterMinutes,
    this.frictionLevel = FrictionLevel.medium,
    this.sessionDefaultMinutes = 5,
    this.disabledMicroActionIds = const [],
  });

  final List<String> targetApps;
  final int dailyLimitMinutes;
  final int? noScrollAfterMinutes;
  final FrictionLevel frictionLevel;
  final int sessionDefaultMinutes;
  final List<String> disabledMicroActionIds;

  Settings copyWith({
    List<String>? targetApps,
    int? dailyLimitMinutes,
    int? noScrollAfterMinutes,
    FrictionLevel? frictionLevel,
    int? sessionDefaultMinutes,
    List<String>? disabledMicroActionIds,
  }) {
    return Settings(
      targetApps: targetApps ?? this.targetApps,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      noScrollAfterMinutes: noScrollAfterMinutes ?? this.noScrollAfterMinutes,
      frictionLevel: frictionLevel ?? this.frictionLevel,
      sessionDefaultMinutes:
          sessionDefaultMinutes ?? this.sessionDefaultMinutes,
      disabledMicroActionIds:
          disabledMicroActionIds ?? this.disabledMicroActionIds,
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
    List<String> disabledMicroActionIds = [];
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
        case 5:
          disabledMicroActionIds = List<String>.from(reader.readList());
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
      disabledMicroActionIds: disabledMicroActionIds,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..writeList(obj.targetApps)
      ..writeByte(1)
      ..writeInt(obj.dailyLimitMinutes)
      ..writeByte(2)
      ..writeInt(obj.noScrollAfterMinutes ?? -1)
      ..writeByte(3)
      ..writeByte(obj.frictionLevel.index)
      ..writeByte(4)
      ..writeInt(obj.sessionDefaultMinutes)
      ..writeByte(5)
      ..writeList(obj.disabledMicroActionIds);
  }
}
