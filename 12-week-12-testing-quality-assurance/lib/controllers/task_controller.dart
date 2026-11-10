import 'package:flutter/foundation.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/models/task_filter.dart';
import 'package:testing_lab/repositories/task_repository.dart';
import 'package:testing_lab/services/task_service.dart';
import 'package:testing_lab/utils/validators.dart';

class TaskController extends ChangeNotifier {
  TaskController(TaskRepository repository) : _service = TaskService(repository);

  final TaskService _service;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _inputError;
  TaskFilter _filter = TaskFilter.all;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get inputError => _inputError;
  TaskFilter get filter => _filter;

  int get totalCount => _tasks.length;
  int get completedCount => _service.countCompleted(_tasks);
  int get pendingCount => _service.countPending(_tasks);

  List<Task> get filteredTasks {
    switch (_filter) {
      case TaskFilter.active:
        return _service.filterTasks(_tasks, isCompleted: false);
      case TaskFilter.completed:
        return _service.filterTasks(_tasks, isCompleted: true);
      case TaskFilter.all:
        return _tasks;
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _service.loadTasks();
    } catch (e) {
      _errorMessage = 'Gagal memuat tugas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTask(String title) async {
    final validation = validateTaskTitle(title);
    if (validation != null) {
      _inputError = validation;
      notifyListeners();
      return false;
    }

    _inputError = null;
    try {
      await _service.createTask(title);
      await loadTasks();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah tugas: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleTask(Task task) async {
    try {
      await _service.toggleTaskStatus(task.id);
      await loadTasks();
    } catch (e) {
      _errorMessage = 'Gagal mengubah status: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _service.deleteTask(task.id);
      await loadTasks();
    } catch (e) {
      _errorMessage = 'Gagal menghapus tugas: $e';
      notifyListeners();
    }
  }
}

