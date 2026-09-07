import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_3_navigation_state_management/Tugas/providers/todo_provider.dart';
import 'package:week_3_navigation_state_management/Tugas/widgets/stats_card.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    
    final uncompletedTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik & Rincian Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          StatsCard(
            title: 'Belum Selesai',
            todos: uncompletedTodos,
            headerColor: Colors.orange.shade100,
            emptyMessage: 'Tidak ada tugas yang tertunda 🎉',
          ),
          StatsCard(
            title: 'Selesai',
            todos: completedTodos,
            headerColor: Colors.green.shade100,
            emptyMessage: 'Belum ada tugas yang diselesaikan.',
          ),
        ],
      ),
    );
  }
}