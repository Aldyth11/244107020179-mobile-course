import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/repositories/fake_task_repository.dart';
import 'package:testing_lab/services/task_service.dart';

void main() {
  group('TaskService & FakeTaskRepository', () {
    late FakeTaskRepository fakeRepository;
    late TaskService taskService;

    setUp(() {
      fakeRepository = FakeTaskRepository(
        initialTasks: [
          Task(id: 't1', title: 'Tugas Pertama', isCompleted: false),
          Task(id: 't2', title: 'Tugas Selesai', isCompleted: true),
        ],
      );
      taskService = TaskService(fakeRepository);
    });

    group('loadTasks', () {
      test('mengambil seluruh tugas dengan sukses dari fake repository', () async {
        // Arrange & Act
        final tasks = await taskService.loadTasks();

        // Assert
        expect(tasks.length, 2);
        expect(tasks.first.title, 'Tugas Pertama');
      });

      test('melempar exception ketika repository mengalami kegagalan/error', () async {
        // Arrange
        fakeRepository.error = Exception('Koneksi database/jaringan terputus');

        // Act & Assert
        expect(
          () => taskService.loadTasks(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createTask', () {
      test('berhasil membuat tugas baru ketika judul valid dan memotong spasi liar', () async {
        // Arrange & Act
        final created = await taskService.createTask('   Menulis Dokumentasi QA   ');

        // Assert
        expect(created.title, 'Menulis Dokumentasi QA');
        expect(created.isCompleted, isFalse);

        final currentTasks = await taskService.loadTasks();
        expect(currentTasks.length, 3);
        expect(currentTasks.any((t) => t.title == 'Menulis Dokumentasi QA'), isTrue);
      });

      test('menolak pembuatan tugas jika judul kosong dan melempar ArgumentError', () async {
        // Arrange, Act & Assert
        expect(
          () => taskService.createTask(''),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => taskService.createTask('     '),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('menolak pembuatan tugas jika judul kurang dari 3 karakter', () async {
        // Arrange, Act & Assert
        expect(
          () => taskService.createTask('ab'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('menolak pembuatan tugas jika judul melebihi 50 karakter', () async {
        final longTitle = 'X' * 55;
        expect(
          () => taskService.createTask(longTitle),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('toggleTaskStatus', () {
      test('mengubah status tugas yang belum selesai menjadi selesai', () async {
        // Act
        final updated = await taskService.toggleTaskStatus('t1');

        // Assert
        expect(updated.isCompleted, isTrue);
      });

      test('mengubah status tugas yang sudah selesai menjadi belum selesai', () async {
        // Act
        final updated = await taskService.toggleTaskStatus('t2');

        // Assert
        expect(updated.isCompleted, isFalse);
      });

      test('melempar ArgumentError jika ID tugas yang diberikan kosong', () async {
        expect(
          () => taskService.toggleTaskStatus(''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('deleteTask', () {
      test('menghapus tugas dari repository jika ID ditemukan', () async {
        // Act
        final result = await taskService.deleteTask('t1');

        // Assert
        expect(result, isTrue);
        final currentTasks = await taskService.loadTasks();
        expect(currentTasks.length, 1);
        expect(currentTasks.any((t) => t.id == 't1'), isFalse);
      });

      test('mengembalikan false jika ID tugas yang akan dihapus tidak ditemukan', () async {
        final result = await taskService.deleteTask('non-existent-id');
        expect(result, isFalse);
      });

      test('melempar ArgumentError jika ID tugas kosong', () async {
        expect(
          () => taskService.deleteTask('  '),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('filterTasks & counters', () {
      test('memfilter tugas aktif (belum selesai)', () async {
        final tasks = await taskService.loadTasks();
        final activeTasks = taskService.filterTasks(tasks, isCompleted: false);

        expect(activeTasks.length, 1);
        expect(activeTasks.first.id, 't1');
      });

      test('memfilter tugas yang sudah selesai', () async {
        final tasks = await taskService.loadTasks();
        final completedTasks = taskService.filterTasks(tasks, isCompleted: true);

        expect(completedTasks.length, 1);
        expect(completedTasks.first.id, 't2');
      });

      test('mengembalikan seluruh tugas jika filter bernilai null', () async {
        final tasks = await taskService.loadTasks();
        final allTasks = taskService.filterTasks(tasks, isCompleted: null);

        expect(allTasks.length, 2);
      });

      test('menghitung jumlah tugas selesai dan pending dengan benar', () async {
        final tasks = await taskService.loadTasks();
        expect(taskService.countCompleted(tasks), 1);
        expect(taskService.countPending(tasks), 1);
      });
    });
  });
}

