// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoCategoryAdapter extends TypeAdapter<TodoCategory> {
  @override
  final int typeId = 2;

  @override
  TodoCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      todos: (fields[2] as List?)?.cast<TodoItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, TodoCategory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.todos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
