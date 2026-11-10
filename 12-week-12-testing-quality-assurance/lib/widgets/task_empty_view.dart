import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskEmptyView extends StatelessWidget {
  const TaskEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('empty-tasks-view'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTokens.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTokens.border),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.ink.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assignment_turned_in_outlined,
                size: 34,
                color: AppTokens.inkFaint,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tugas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: AppTokens.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Semua rencana telah tuntas atau daftar belum diisi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTokens.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

