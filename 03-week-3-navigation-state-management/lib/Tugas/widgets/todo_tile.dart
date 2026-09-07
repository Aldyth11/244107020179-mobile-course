import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoTile extends ConsumerWidget {
  final Todo todo;

  const TodoTile({
    super.key,
    required this.todo,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return ListTile(

      // Checkbox
      leading: Checkbox(
        value: todo.isCompleted,

        onChanged: (_) {
          ref
              .read(todoListProvider.notifier)
              .toggle(todo.id);
        },
      ),

      // Judul Todo
      title: Text(
        todo.title,

        style: TextStyle(
          decoration: todo.isCompleted
              ? TextDecoration.lineThrough
              : null,
        ),
      ),

      // Tombol hapus
      trailing: IconButton(
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),

        onPressed: () {
          ref
              .read(todoListProvider.notifier)
              .remove(todo.id);
        },
      ),
    );
  }
}