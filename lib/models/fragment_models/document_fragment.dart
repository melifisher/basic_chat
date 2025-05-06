import 'package:hive/hive.dart';
part 'document_fragment.g.dart';

@HiveType(typeId: 0)
class DocumentFragment extends HiveObject {
  @HiveField(0)
  final String documentId;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final List<double> embedding;
  
  @HiveField(3)
  final Map<String, dynamic> metadata;
  
  DocumentFragment({
    required this.documentId,
    required this.text,
    required this.embedding,
    required this.metadata,
  });
}

class DocumentFragmentAdapter extends TypeAdapter<DocumentFragment> {
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
      metadata: Map<String, dynamic>.from(fields[3] as Map),
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
