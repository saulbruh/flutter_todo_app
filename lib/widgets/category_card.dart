import 'package:flutter/material.dart';
import '../models/todo_category.dart';

class CategoryCard extends StatelessWidget {
  final TodoCategory category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function() confirmDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.confirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id),
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
      child: ListTile(
        title: Text(category.name),
        subtitle: Text(
          'Total: ${category.totalTodos} · Pendientes: ${category.pendingTodos} · Completadas: ${category.completedTodos}',
        ),
        onTap: onTap,
        onLongPress: onEdit,
      ),
    );
  }
}
