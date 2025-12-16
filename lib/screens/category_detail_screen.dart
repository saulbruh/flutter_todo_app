import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
import '../widgets/todo_list_tile.dart';

enum TodoFilter { all, pending, completed, overdue }

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  TodoFilter _currentFilter = TodoFilter.all;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirmDeleteDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showAddTodoDialog() {
    _textController.clear();
    _selectedDate = null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Descripción de la tarea',
              ),
              onSubmitted: (_) => _saveTodo(ctx),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Sin fecha límite'
                        : 'Fecha límite: ${_formatDate(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Elegir fecha'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              _selectedDate = null;
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _saveTodo(ctx),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTodo(BuildContext dialogContext) async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _snack('Escribe un nombre para el to-do.');
      return;
    }

    final ok = await context.read<TodoProvider>().addTodo(
      widget.categoryId,
      text,
      _selectedDate,
    );

    if (!ok) {
      _snack('No se pudo crear el to-do (categoría no encontrada).');
      return;
    }

    _textController.clear();
    _selectedDate = null;
    Navigator.of(dialogContext).pop();
    _snack('To-do creado: "$text".');
  }

  void _showEditTodoDialog(TodoItem todo) {
    _textController.text = todo.title;
    _selectedDate = todo.dueDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Descripción de la tarea',
              ),
              onSubmitted: (_) => _updateTodo(ctx, todo.id),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Sin fecha límite'
                        : 'Fecha límite: ${_formatDate(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Cambiar fecha'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textController.clear();
              _selectedDate = null;
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updateTodo(ctx, todo.id),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTodo(BuildContext dialogContext, String todoId) async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _snack('Escribe un nombre para el to-do.');
      return;
    }

    await context.read<TodoProvider>().updateTodo(
      widget.categoryId,
      todoId,
      title: text,
      dueDate: _selectedDate,
    );

    _textController.clear();
    _selectedDate = null;
    Navigator.of(dialogContext).pop();
    _snack('To-do actualizado.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final category = provider.getCategoryById(widget.categoryId);

    if (category == null) {
      return const Scaffold(
        body: Center(child: Text('Categoría no encontrada.')),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredTodos = category.todos.where((todo) {
      switch (_currentFilter) {
        case TodoFilter.all:
          return true;
        case TodoFilter.pending:
          return !todo.isDone;
        case TodoFilter.completed:
          return todo.isDone;
        case TodoFilter.overdue:
          return !todo.isDone &&
              todo.dueDate != null &&
              DateTime(
                todo.dueDate!.year,
                todo.dueDate!.month,
                todo.dueDate!.day,
              ).isBefore(today);
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TodoFilter>(
                value: _currentFilter,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _currentFilter = value);
                },
                icon: const Icon(Icons.filter_list),
                items: const [
                  DropdownMenuItem(value: TodoFilter.all, child: Text('Todas')),
                  DropdownMenuItem(
                    value: TodoFilter.pending,
                    child: Text('Pendientes'),
                  ),
                  DropdownMenuItem(
                    value: TodoFilter.completed,
                    child: Text('Completadas'),
                  ),
                  DropdownMenuItem(
                    value: TodoFilter.overdue,
                    child: Text('Vencidas'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: filteredTodos.isEmpty
          ? const Center(
              child: Text(
                'No hay tareas con este filtro.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];

                return TodoListTile(
                  todo: todo,
                  formatDate: _formatDate,
                  onChanged: (value) {
                    context.read<TodoProvider>().updateTodo(
                      widget.categoryId,
                      todo.id,
                      isDone: value ?? false,
                    );
                  },
                  onEdit: () => _showEditTodoDialog(todo),
                  confirmDelete: () => _confirmDeleteDialog(
                    title: 'Eliminar to-do',
                    content: '¿Seguro que quieres borrar "${todo.title}"?',
                  ),
                  onDelete: () {
                    context.read<TodoProvider>().deleteTodo(
                      widget.categoryId,
                      todo.id,
                    );
                    _snack('To-do eliminado.');
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
