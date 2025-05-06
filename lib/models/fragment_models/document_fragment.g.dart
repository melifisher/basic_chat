// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_fragment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeneratedDocumentFragmentAdapter extends TypeAdapter<DocumentFragment> {
  @override
  final int typeId = 0;

  @override
  DocumentFragment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentFragment(
      documentId: fields[0] as String,
      text: fields[1] as String,
      embedding: (fields[2] as List).cast<double>(),
      metadata: (fields[3] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DocumentFragment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.documentId)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.embedding)
      ..writeByte(3)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentFragmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
