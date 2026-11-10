import 'package:flutter/material.dart';
import 'package:testing_lab/models/task_filter.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
    required this.onSelected,
  });

  final TaskFilter selectedFilter;
  final int totalCount;
  final int activeCount;
  final int completedCount;
  final ValueChanged<TaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildChip(
              key: const Key('filter-all'),
              label: 'Semua ($totalCount)',
              filter: TaskFilter.all,
            ),
            const SizedBox(width: 8),
            _buildChip(
              key: const Key('filter-active'),
              label: 'Aktif ($activeCount)',
              filter: TaskFilter.active,
            ),
            const SizedBox(width: 8),
            _buildChip(
              key: const Key('filter-completed'),
              label: 'Selesai ($completedCount)',
              filter: TaskFilter.completed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required Key key,
    required String label,
    required TaskFilter filter,
  }) {
    final isSelected = selectedFilter == filter;

    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTokens.accentWash,
      backgroundColor: AppTokens.surface,
      side: BorderSide(
        color: isSelected ? AppTokens.accent : AppTokens.border,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppTokens.accentDeep : AppTokens.inkMuted,
      ),
      onSelected: (selected) {
        if (selected) onSelected(filter);
      },
    );
  }
}
