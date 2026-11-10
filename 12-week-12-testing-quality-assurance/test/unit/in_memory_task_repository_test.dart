import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/repositories/task_repository.dart';

void main() {
  group('InMemoryTaskRepository', () {
    late InMemoryTaskRepository repository;

    setUp(() {
      repository = InMemoryTaskRepository(
        initialTasks: [
          Task(id: 'init_1', title: 'Tugas Awal', isCompleted: false),
        ],
      );
    });

    test('getTasks mengembalikan seluruh tugas awal', () async {
      final tasks = await repository.getTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Tugas Awal');
    });

    test('addTask menambahkan tugas baru ke dalam memory', () async {
      final task = await repository.addTask('Tugas Baru Diingat');
      expect(task.title, 'Tugas Baru Diingat');
      expect(task.isCompleted, isFalse);

      final current = await repository.getTasks();
      expect(current.length, 2);
    });

    test('toggleTaskStatus mengubah status tugas yang ada', () async {
      final updated = await repository.toggleTaskStatus('init_1');
      expect(updated.isCompleted, isTrue);

      final current = await repository.getTasks();
      expect(current.first.isCompleted, isTrue);
    });

    test('toggleTaskStatus melempar StateError jika ID tidak ditemukan', () async {
      expect(
        () => repository.toggleTaskStatus('id_acak_yang_tidak_ada'),
        throwsA(isA<StateError>()),
      );
    });

    test('deleteTask menghapus tugas jika ID ada dan return true', () async {
      final deleted = await repository.deleteTask('init_1');
      expect(deleted, isTrue);

      final current = await repository.getTasks();
      expect(current.isEmpty, isTrue);
    });

    test('deleteTask mengembalikan false jika ID tidak ditemukan', () async {
      final deleted = await repository.deleteTask('id_palsu');
      expect(deleted, isFalse);
    });
  });
}

