import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week_3_navigation_state_management/Tugas/models/todo.dart';
import 'package:week_3_navigation_state_management/Tugas/widgets/todo_tile.dart';

void main() {
  testWidgets('TodoTile menampilkan judul tugas', (tester) async {
    const todo = Todo(
      id: '1',
      title: 'Belajar Flutter',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TodoTile(todo: todo),
          ),
        ),
      ),
    );

    expect(find.text('Belajar Flutter'), findsOneWidget);
  });
}