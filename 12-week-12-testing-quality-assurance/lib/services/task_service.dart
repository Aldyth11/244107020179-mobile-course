import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/repositories/task_repository.dart';
import 'package:testing_lab/utils/validators.dart';

/// Layanan logika bisnis fitur manajemen tugas
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  /// Mengambil daftar seluruh tugas dari repository
  Future<List<Task>> loadTasks() async {
    return _repository.getTasks();
  }

  /// Menambahkan tugas baru setelah melalui validasi judul
  Future<Task> createTask(String title) async {
    final validationError = validateTaskTitle(title);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }
    return _repository.addTask(title.trim());
  }

  /// Mengubah status penyelesaian tugas berdasarkan ID
  Future<Task> toggleTaskStatus(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID tugas tidak boleh kosong');
    }
    return _repository.toggleTaskStatus(id);
  }

  /// Menghapus tugas berdasarkan ID
  Future<bool> deleteTask(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID tugas tidak boleh kosong');
    }
    return _repository.deleteTask(id);
  }

  /// Memfilter daftar tugas berdasarkan status selesai / belum selesai
  List<Task> filterTasks(List<Task> tasks, {bool? isCompleted}) {
    if (isCompleted == null) {
      return tasks;
    }
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  /// Menghitung jumlah tugas yang telah selesai
  int countCompleted(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  /// Menghitung jumlah tugas yang masih aktif / belum selesai
  int countPending(List<Task> tasks) {
    return tasks.where((task) => !task.isCompleted).length;
  }
}

