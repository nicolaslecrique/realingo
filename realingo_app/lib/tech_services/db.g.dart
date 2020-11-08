// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbItemToLearnAdapter extends TypeAdapter<DbItemToLearn> {
  @override
  final int typeId = 0;

  @override
  DbItemToLearn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbItemToLearn(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DbItemToLearn obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.uri)
      ..writeByte(1)
      ..write(obj.itemLabel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbItemToLearnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbLearningProgramAdapter extends TypeAdapter<DbLearningProgram> {
  @override
  final int typeId = 1;

  @override
  DbLearningProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbLearningProgram(
      fields[0] as String,
      (fields[1] as List)?.cast<DbItemToLearn>(),
    );
  }

  @override
  void write(BinaryWriter writer, DbLearningProgram obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.uri)
      ..writeByte(1)
      ..write(obj.itemsToLearn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbLearningProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DbUserProgramAdapter extends TypeAdapter<DbUserProgram> {
  @override
  final int typeId = 2;

  @override
  DbUserProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbUserProgram(
      fields[0] as String,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DbUserProgram obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.uri)
      ..writeByte(1)
      ..write(obj.learningProgramUri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbUserProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
