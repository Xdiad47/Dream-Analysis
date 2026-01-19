// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DreamModelAdapter extends TypeAdapter<DreamModel> {
  @override
  final int typeId = 0;

  @override
  DreamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DreamModel(
      id: fields[0] as String,
      dreamText: fields[1] as String,
      dreamDate: fields[2] as DateTime,
      moodBeforeSleep: fields[3] as String,
      tags: (fields[4] as List?)?.cast<String>(),
      isAnalyzed: fields[5] as bool,
      analysis: fields[6] as DreamAnalysisModel?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DreamModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dreamText)
      ..writeByte(2)
      ..write(obj.dreamDate)
      ..writeByte(3)
      ..write(obj.moodBeforeSleep)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.isAnalyzed)
      ..writeByte(6)
      ..write(obj.analysis)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
