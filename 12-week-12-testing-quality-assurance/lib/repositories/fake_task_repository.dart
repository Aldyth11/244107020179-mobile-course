import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/repositories/task_repository.dart';

/// Fake repository untuk pengujian unit dan widget tanpa dependensi eksternal.
/// Memungkinkan simulasi respons sukses, manipulasi data tiruan, serta inject exception.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    List<Task>? initialTasks,
    this.error,
    this.addError,
  }) : _tasks = initialTasks != null ? List<Task>.from(initialTasks) : [];

  final List<Task> _tasks;
  Exception? error;
  Exception? addError;

  @override
  Future<List<Task>> getTasks() async {
    if (error != null) {
      throw error!;
    }
    return List<Task>.unmodifiable(_tasks);
  }

  @override
  Future<Task> addTask(String title) async {
    if (addError != null) {
      throw addError!;
    }
    if (error != null) {
      throw error!;
    }
    final newTask = Task(
      id: 'fake_${_tasks.length + 1}',
      title: title.trim(),
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<Task> toggleTaskStatus(String id) async {
    if (error != null) {
      throw error!;
    }
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw StateError('Tugas tidak ditemukan: $id');
    }
    final current = _tasks[index];
    final updated = current.copyWith(isCompleted: !current.isCompleted);
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteTask(String id) async {
    if (error != null) {
      throw error!;
    }
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _tasks.removeAt(index);
    return true;
  }

  int get taskCount => _tasks.length;
}

