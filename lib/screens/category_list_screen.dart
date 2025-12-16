import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../models/todo_category.dart';
import '../widgets/category_card.dart';
import 'category_detail_screen.dart';

enum CategoryFilter { all, withPending, fullyCompleted, empty }

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final TextEditingController _categoryController = TextEditingController();
  CategoryFilter _currentFilter = CategoryFilter.all;

  @override
  void dispose() {
    _categoryController.dispose();
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

  void _showAddCategoryDialog() {
    _categoryController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la categoría'),
          onSubmitted: (_) => _saveCategory(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _saveCategory(ctx),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(BuildContext dialogContext) async {
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      _snack('Escribe un nombre para la categoría.');
      return;
    }

    final created = await context.read<TodoProvider>().addCategory(name);

    if (!created) {
      _snack('Esa categoría ya existe.');
      return;
    }

    _categoryController.clear();
    Navigator.of(dialogContext).pop();
    _snack('Categoría creada: "$name".');
  }

  void _showEditCategoryDialog(TodoCategory category) {
    _categoryController.text = category.name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar categoría'),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la categoría'),
          onSubmitted: (_) => _updateCategory(ctx, category),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updateCategory(ctx, category),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategory(
    BuildContext dialogContext,
    TodoCategory category,
  ) async {
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      _snack('Escribe un nombre para la categoría.');
      return;
    }

    final updated = await context.read<TodoProvider>().updateCategory(
      category.id,
      name,
    );

    if (!updated) {
      _snack('Ya existe otra categoría con ese nombre.');
      return;
    }

    _categoryController.clear();
    Navigator.of(dialogContext).pop();
    _snack('Categoría actualizada.');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final categories = provider.categories;

    final filtered = categories.where((c) {
      switch (_currentFilter) {
        case CategoryFilter.all:
          return true;
        case CategoryFilter.withPending:
          return c.pendingTodos > 0;
        case CategoryFilter.fullyCompleted:
          return c.totalTodos > 0 && c.pendingTodos == 0;
        case CategoryFilter.empty:
          return c.totalTodos == 0;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis categorías'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryFilter>(
                value: _currentFilter,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _currentFilter = value);
                },
                icon: const Icon(Icons.filter_list),
                items: const [
                  DropdownMenuItem(
                    value: CategoryFilter.all,
                    child: Text('Todas'),
                  ),
                  DropdownMenuItem(
                    value: CategoryFilter.withPending,
                    child: Text('Con pendientes'),
                  ),
                  DropdownMenuItem(
                    value: CategoryFilter.fullyCompleted,
                    child: Text('Completadas'),
                  ),
                  DropdownMenuItem(
                    value: CategoryFilter.empty,
                    child: Text('Vacías'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'Aún no hay categorías.\nToca el botón + para crear la primera.',
                textAlign: TextAlign.center,
              ),
            )
          : filtered.isEmpty
          ? const Center(child: Text('No hay categorías con este filtro.'))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final category = filtered[index];

                return CategoryCard(
                  category: category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategoryDetailScreen(categoryId: category.id),
                      ),
                    );
                  },
                  onEdit: () => _showEditCategoryDialog(category),
                  confirmDelete: () => _confirmDeleteDialog(
                    title: 'Eliminar categoría',
                    content:
                        '¿Seguro que quieres borrar "${category.name}"?\nSe borrarán todos sus to-dos.',
                  ),
                  onDelete: () {
                    context.read<TodoProvider>().deleteCategory(category.id);
                    _snack('Categoría eliminada.');
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
