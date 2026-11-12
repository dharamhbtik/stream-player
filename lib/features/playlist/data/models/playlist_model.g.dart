// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistModelAdapter extends TypeAdapter<PlaylistModel> {
  @override
  final int typeId = 1;

  @override
  PlaylistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistModel(
      id: fields[0] as String,
      name: fields[1] as String,
      sourceUrl: fields[2] as String,
      isLocal: fields[3] as bool? ?? false,
      addedAt: fields[4] as DateTime,
      lastUpdated: fields[5] as DateTime?,
      channelCount: fields[6] as int? ?? 0,
      categories: (fields[7] as List?)?.cast<String>() ?? const [],
      languages: (fields[8] as List?)?.cast<String>() ?? const [],
      countries: (fields[9] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.sourceUrl)
      ..writeByte(3)
      ..write(obj.isLocal)
      ..writeByte(4)
      ..write(obj.addedAt)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.channelCount)
      ..writeByte(7)
      ..write(obj.categories)
      ..writeByte(8)
      ..write(obj.languages)
      ..writeByte(9)
      ..write(obj.countries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
