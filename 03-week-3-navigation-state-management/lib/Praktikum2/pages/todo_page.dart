import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodoListProvider);
    final isFilterActive = ref.watch(todoFilterProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas (ToDo)'),
        actions: [
          FilterChip(
            label: const Text('Belum Selesai'),
            selected: isFilterActive,
            onSelected: (val) {
              // Panggil method setFilter yang baru kita buat
              ref.read(todoFilterProvider.notifier).setFilter(val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Tambah Tugas Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      ref.read(todoListProvider.notifier).add(controller.text);
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('Tidak ada tugas.'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return TodoTile(todo: todos[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}