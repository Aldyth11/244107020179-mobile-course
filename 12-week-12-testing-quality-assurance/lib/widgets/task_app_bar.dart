import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TaskAppBar({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(
          bottom: BorderSide(color: AppTokens.border, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTokens.accentWash,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMedium),
                  border: Border.all(color: AppTokens.accentBorder),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppTokens.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daftar tugas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppTokens.ink,
                    ),
                  ),
                  Text(
                    'Testing & QA Workspace',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTokens.inkMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                key: const Key('task-counter-chip'),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTokens.accentWash,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  border: Border.all(color: AppTokens.accentBorder),
                ),
                child: Text(
                  '$completedCount/$totalCount Selesai',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppTokens.accentDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

