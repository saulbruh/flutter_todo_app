import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime? dueDate;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
  });
}
