// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_analysis_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DreamAnalysisModelAdapter extends TypeAdapter<DreamAnalysisModel> {
  @override
  final int typeId = 1;

  @override
  DreamAnalysisModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DreamAnalysisModel(
      emotions: (fields[0] as List).cast<String>(),
      symbols: (fields[1] as List).cast<String>(),
      analysisShort: fields[2] as String,
      analysisFull: fields[3] as String,
      sourcesUsed: fields[4] as int,
      analyzedAt: fields[5] as DateTime,
      summary: fields[6] as String,
      themes: (fields[7] as List?)?.cast<String>(),
      symbolInsights: (fields[8] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      questions: (fields[9] as List?)?.cast<String>(),
      actions: (fields[10] as List?)?.cast<String>(),
      entities: (fields[11] as List?)
          ?.map((dynamic e) => (e as List).cast<String>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, DreamAnalysisModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.emotions)
      ..writeByte(1)
      ..write(obj.symbols)
      ..writeByte(2)
      ..write(obj.analysisShort)
      ..writeByte(3)
      ..write(obj.analysisFull)
      ..writeByte(4)
      ..write(obj.sourcesUsed)
      ..writeByte(5)
      ..write(obj.analyzedAt)
      ..writeByte(6)
      ..write(obj.summary)
      ..writeByte(7)
      ..write(obj.themes)
      ..writeByte(8)
      ..write(obj.symbolInsights)
      ..writeByte(9)
      ..write(obj.questions)
      ..writeByte(10)
      ..write(obj.actions)
      ..writeByte(11)
      ..write(obj.entities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamAnalysisModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
