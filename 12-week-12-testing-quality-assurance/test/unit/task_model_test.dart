import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/models/task.dart';

void main() {
  group('Task Model', () {
    test('membuat objek Task dengan nilai default yang benar', () {
      final task = Task(id: '1', title: 'Belajar Unit Testing');

      expect(task.id, '1');
      expect(task.title, 'Belajar Unit Testing');
      expect(task.isCompleted, isFalse);
      expect(task.createdAt, isA<DateTime>());
    });

    test('mendukung copyWith untuk memodifikasi properti secara immutable', () {
      final task = Task(id: '1', title: 'Tugas Lama', isCompleted: false);
      final updated = task.copyWith(
        title: 'Tugas Baru',
        isCompleted: true,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Tugas Baru');
      expect(updated.isCompleted, isTrue);
      // Objek awal tidak berubah
      expect(task.title, 'Tugas Lama');
      expect(task.isCompleted, isFalse);
    });

    test('serialisasi toMap dan deserialisasi fromMap bekerja konsisten', () {
      final original = Task(
        id: 'task_100',
        title: 'Simpan ke database lokal',
        isCompleted: true,
        createdAt: DateTime(2026, 11, 9, 10, 0, 0),
      );

      final map = original.toMap();
      expect(map['id'], 'task_100');
      expect(map['title'], 'Simpan ke database lokal');
      expect(map['isCompleted'], isTrue);
      expect(map['createdAt'], '2026-11-09T10:00:00.000');

      final deserialized = Task.fromMap(map);
      expect(deserialized.id, original.id);
      expect(deserialized.title, original.title);
      expect(deserialized.isCompleted, original.isCompleted);
      expect(deserialized.createdAt, original.createdAt);
    });

    test('evaluasi kesetaraan objek (equality dan hashCode)', () {
      final taskA = Task(id: '1', title: 'Sama', isCompleted: false);
      final taskB = Task(id: '1', title: 'Sama', isCompleted: false);
      final taskC = Task(id: '2', title: 'Beda', isCompleted: false);

      expect(taskA, equals(taskB));
      expect(taskA.hashCode, equals(taskB.hashCode));
      expect(taskA, isNot(equals(taskC)));
    });

    test('memformat toString dengan informatif', () {
      final task = Task(id: '42', title: 'Testing', isCompleted: false);
      expect(task.toString(), contains('Task(id: 42, title: Testing, isCompleted: false)'));
    });
  });
}

