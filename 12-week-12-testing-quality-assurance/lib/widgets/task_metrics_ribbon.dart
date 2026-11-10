import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskMetricsRibbon extends StatelessWidget {
  const TaskMetricsRibbon({
    super.key,
    required this.total,
    required this.pending,
    required this.completed,
  });

  final int total;
  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(
          bottom: BorderSide(color: AppTokens.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildItem('Semua', total.toString(), AppTokens.ink),
          const SizedBox(width: 8),
          _buildItem('Aktif', pending.toString(), AppTokens.accent),
          const SizedBox(width: 8),
          _buildItem('Selesai', completed.toString(), AppTokens.success),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTokens.paper,
          borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
          border: Border.all(color: AppTokens.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTokens.inkMuted,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

