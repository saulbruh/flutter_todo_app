import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/todo_item.dart';
import 'models/todo_category.dart';
import 'providers/todo_provider.dart';
import 'screens/category_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(TodoCategoryAdapter());

  final categoriesBox = await Hive.openBox<TodoCategory>('categoriesBox');

  runApp(TodoApp(categoriesBox: categoriesBox));
}

class TodoApp extends StatelessWidget {
  final Box<TodoCategory> categoriesBox;

  const TodoApp({super.key, required this.categoriesBox});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(categoriesBox),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo Categories App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const CategoryListScreen(),
      ),
    );
  }
}
