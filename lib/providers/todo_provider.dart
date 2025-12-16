import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/todo_category.dart';
import '../models/todo_item.dart';

class TodoProvider with ChangeNotifier {
  final Box<TodoCategory> _box;

  TodoProvider(this._box);

  List<TodoCategory> get categories => _box.values.toList();

  TodoCategory? getCategoryById(String id) => _box.get(id);

  bool _categoryNameExists(String name, {String? excludeId}) {
    final normalized = name.trim().toLowerCase();
    return _box.values.any((c) {
      if (excludeId != null && c.id == excludeId) return false;
      return c.name.trim().toLowerCase() == normalized;
    });
  }

  // ---------- CRUD Categorías ----------
  // true = se creó, false = duplicada
  Future<bool> addCategory(String name) async {
    if (_categoryNameExists(name)) return false;

    final category = TodoCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );

    await _box.put(category.id, category);
    notifyListeners();
    return true;
  }

  // true = actualizó, false = duplicada
  Future<bool> updateCategory(String id, String newName) async {
    final category = _box.get(id);
    if (category == null) return false;

    if (_categoryNameExists(newName, excludeId: id)) return false;

    category.name = newName.trim();
    await _box.put(id, category);
    notifyListeners();
    return true;
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  // ---------- CRUD Todos ----------
  // true = se creó, false = categoría no encontrada
  Future<bool> addTodo(
    String categoryId,
    String title,
    DateTime? dueDate,
  ) async {
    final category = _box.get(categoryId);
    if (category == null) return false;

    final todo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      dueDate: dueDate,
    );

    category.todos.add(todo);
    await _box.put(categoryId, category);
    notifyListeners();
    return true;
  }

  Future<void> updateTodo(
    String categoryId,
    String todoId, {
    String? title,
    DateTime? dueDate,
    bool? isDone,
  }) async {
    final category = _box.get(categoryId);
    if (category == null) return;

    final index = category.todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final todo = category.todos[index];

    if (title != null) todo.title = title.trim();
    if (dueDate != null) todo.dueDate = dueDate;
    if (isDone != null) todo.isDone = isDone;

    await _box.put(categoryId, category);
    notifyListeners();
  }

  Future<void> deleteTodo(String categoryId, String todoId) async {
    final category = _box.get(categoryId);
    if (category == null) return;

    category.todos.removeWhere((t) => t.id == todoId);
    await _box.put(categoryId, category);
    notifyListeners();
  }
}
