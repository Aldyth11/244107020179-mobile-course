import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';
import 'package:testing_lab/widgets/task_add_button.dart';

class TaskInputBar extends StatelessWidget {
  const TaskInputBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.errorText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
              border: Border.all(
                color: errorText != null ? AppTokens.danger : AppTokens.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTokens.ink.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: AppTokens.inkFaint,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('task-title-field'),
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTokens.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Tulis nama tugas baru...',
                      hintStyle: TextStyle(
                        color: AppTokens.inkFaint,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => onSubmitted(),
                  ),
                ),
                TaskAddButton(onPressed: onSubmitted),
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: AppTokens.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    errorText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTokens.danger,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
