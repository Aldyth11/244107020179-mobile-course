import 'package:flutter/material.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: task.isCompleted ? AppTokens.surfaceMuted : AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
        border: Border.all(
          color: task.isCompleted ? AppTokens.border : AppTokens.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Checkbox(
            key: Key('task-checkbox-${task.id}'),
            value: task.isCompleted,
            onChanged: onToggle,
            activeColor: AppTokens.accent,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            task.title,
            key: Key('task-title-${task.id}'),
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: task.isCompleted ? FontWeight.w400 : FontWeight.w500,
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              decorationColor: AppTokens.inkFaint,
              color: task.isCompleted ? AppTokens.inkFaint : AppTokens.ink,
            ),
          ),
          subtitle: Text(
            task.isCompleted ? 'Selesai dikerjakan' : 'Perlu diselesaikan',
            style: TextStyle(
              fontSize: 11,
              color: task.isCompleted ? AppTokens.accent : AppTokens.inkMuted,
            ),
          ),
          trailing: IconButton(
            key: Key('delete-task-${task.id}'),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppTokens.inkFaint,
            hoverColor: AppTokens.danger.withValues(alpha: 0.1),
            tooltip: 'Hapus Tugas',
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
