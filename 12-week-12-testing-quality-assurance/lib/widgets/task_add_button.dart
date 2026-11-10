import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskAddButton extends StatelessWidget {
  const TaskAddButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        key: const Key('save-task-button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 18),
            SizedBox(width: 4),
            Text(
              'Tambah',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

