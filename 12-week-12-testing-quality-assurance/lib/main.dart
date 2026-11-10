import 'package:flutter/material.dart';
import 'package:testing_lab/repositories/task_repository.dart';
import 'package:testing_lab/screens/task_screen.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({
    super.key,
    this.repository,
  });

  final TaskRepository? repository;

  @override
  Widget build(BuildContext context) {
    final activeRepo = repository ?? InMemoryTaskRepository();

    return MaterialApp(
      title: 'Testing Lab - Manajemen Tugas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: TaskScreen(repository: activeRepo),
    );
  }
}
