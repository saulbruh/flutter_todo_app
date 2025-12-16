import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoListTile extends StatelessWidget {
  final TodoItem todo;
  final String Function(DateTime date) formatDate;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function() confirmDelete;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.formatDate,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.confirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDelete(),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onLongPress: onEdit,
        child: CheckboxListTile(
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: todo.dueDate == null
              ? null
              : Text('Fecha límite: ${formatDate(todo.dueDate!)}'),
          value: todo.isDone,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
