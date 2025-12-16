import 'package:hive/hive.dart';
import 'todo_item.dart';

part 'todo_category.g.dart';

@HiveType(typeId: 2)
class TodoCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final List<TodoItem> todos;

  TodoCategory({required this.id, required this.name, List<TodoItem>? todos})
    : todos = todos ?? [];

  int get totalTodos => todos.length;
  int get completedTodos => todos.where((t) => t.isDone).length;
  int get pendingTodos => todos.where((t) => !t.isDone).length;
}
