import 'package:testing_lab/models/task.dart';

/// Kontrak abstrak untuk akses data tugas (Repository Pattern)
abstract interface class TaskRepository {
  Future<List<Task>> getTasks();
  Future<Task> addTask(String title);
  Future<Task> toggleTaskStatus(String id);
  Future<bool> deleteTask(String id);
}

/// Implementasi in-memory untuk menyimpan daftar tugas secara lokal
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<Task>? initialTasks})
      : _tasks = initialTasks != null ? List<Task>.from(initialTasks) : [];

  final List<Task> _tasks;

  @override
  Future<List<Task>> getTasks() async {
    // Memberikan clone dari list untuk mencegah mutasi eksternal
    return List<Task>.unmodifiable(_tasks);
  }

  @override
  Future<Task> addTask(String title) async {
    final newTask = Task(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}_${_tasks.length}',
      title: title.trim(),
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<Task> toggleTaskStatus(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw StateError('Tugas dengan ID $id tidak ditemukan');
    }
    final current = _tasks[index];
    final updated = current.copyWith(isCompleted: !current.isCompleted);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      return false;
    }
    _tasks.removeAt(index);
    return true;
  }
}

