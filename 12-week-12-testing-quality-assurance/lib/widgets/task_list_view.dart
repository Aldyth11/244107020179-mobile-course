import 'package:flutter/material.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/theme/app_tokens.dart';
import 'package:testing_lab/widgets/task_empty_view.dart';
import 'package:testing_lab/widgets/task_item.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.isLoading,
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
  });

  final bool isLoading;
  final List<Task> tasks;
  final ValueChanged<Task> onToggle;
  final ValueChanged<Task> onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('task-loading-indicator'),
          color: AppTokens.accent,
        ),
      );
    }

    if (tasks.isEmpty) {
      return const TaskEmptyView();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItemWidget(
          task: task,
          onToggle: (_) => onToggle(task),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}

