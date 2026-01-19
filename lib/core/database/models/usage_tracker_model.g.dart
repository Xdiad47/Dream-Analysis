// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_tracker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsageTrackerModelAdapter extends TypeAdapter<UsageTrackerModel> {
  @override
  final int typeId = 2;

  @override
  UsageTrackerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UsageTrackerModel(
      deviceId: fields[0] as String,
      currentDate: fields[1] as String,
      analysisCount: fields[2] as int,
      nextResetTime: fields[3] as DateTime,
      timezone: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UsageTrackerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.currentDate)
      ..writeByte(2)
      ..write(obj.analysisCount)
      ..writeByte(3)
      ..write(obj.nextResetTime)
      ..writeByte(4)
      ..write(obj.timezone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageTrackerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
