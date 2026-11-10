import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/widgets/task_item.dart';

void main() {
  group('TaskItemWidget', () {
    testWidgets('menampilkan judul tugas dan status checkbox tidak tercentang', (tester) async {
      final task = Task(id: 'item_1', title: 'Belajar Flutter Testing', isCompleted: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Belajar Flutter Testing'), findsOneWidget);
      final checkbox = tester.widget<Checkbox>(find.byKey(const Key('task-checkbox-item_1')));
      expect(checkbox.value, isFalse);
    });

    testWidgets('menampilkan teks tercoret ketika tugas berstatus selesai', (tester) async {
      final task = Task(id: 'item_2', title: 'Tugas Selesai', isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byKey(const Key('task-title-item_2')));
      expect(textWidget.style?.decoration, equals(TextDecoration.lineThrough));
      final checkbox = tester.widget<Checkbox>(find.byKey(const Key('task-checkbox-item_2')));
      expect(checkbox.value, isTrue);
    });

    testWidgets('memanggil callback onToggle ketika checkbox ditekan', (tester) async {
      final task = Task(id: 'item_3', title: 'Toggle Test', isCompleted: false);
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: (val) {
                toggled = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('task-checkbox-item_3')));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('memanggil callback onDelete ketika ikon hapus ditekan', (tester) async {
      final task = Task(id: 'item_4', title: 'Delete Test', isCompleted: false);
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItemWidget(
              task: task,
              onToggle: (_) {},
              onDelete: () {
                deleted = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('delete-task-item_4')));
      await tester.pump();

      expect(deleted, isTrue);
    });
  });
}

