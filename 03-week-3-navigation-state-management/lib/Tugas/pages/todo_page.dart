import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../widgets/async_todo_list.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas (ToDo)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline),
            tooltip: 'Simulasi Error',
            onPressed: () {
              ref
                  .read(asyncErrorProvider.notifier)
                  .setError(true);

              ref.invalidate(todoAsyncProvider);
            },
          ),
        ],
      ),

      body: const AsyncTodoList(),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nama tugas...',
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                final title = controller.text.trim();

                if (title.isNotEmpty) {
                  ref
                      .read(todoListProvider.notifier)
                      .add(title);

                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}