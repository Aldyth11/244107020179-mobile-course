import 'package:flutter/material.dart';
import '../models/todo.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final List<Todo> todos;
  final Color headerColor;
  final String emptyMessage;

  const StatsCard({
    super.key,
    required this.title,
    required this.todos,
    required this.headerColor,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Chip(
                    label: Text('${todos.length}'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Daftar Item Tugas
            todos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];

                      return ListTile(
                        leading: Icon(
                          todo.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: todo.isCompleted ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}