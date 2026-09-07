import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import 'todo_tile.dart';

class AsyncTodoList extends ConsumerWidget {
  const AsyncTodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodos = ref.watch(todoAsyncProvider);

    return asyncTodos.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(error.toString()),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(asyncErrorProvider.notifier)
                    .setError(false);

                ref.invalidate(todoAsyncProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),

      data: (todos) {
        final uncompleted = todos
            .where((todo) => !todo.isCompleted)
            .toList();

        if (uncompleted.isEmpty) {
          return const Center(
            child: Text(
              'Semua tugas sudah selesai 🎉',
            ),
          );
        }

        return ListView.builder(
          itemCount: uncompleted.length,
          itemBuilder: (context, index) {
            return TodoTile(
              todo: uncompleted[index],
            );
          },
        );
      },
    );
  }
}