import 'package:flutter/material.dart';
import 'package:testing_lab/controllers/task_controller.dart';
import 'package:testing_lab/repositories/task_repository.dart';
import 'package:testing_lab/theme/app_tokens.dart';
import 'package:testing_lab/widgets/task_app_bar.dart';
import 'package:testing_lab/widgets/task_error_banner.dart';
import 'package:testing_lab/widgets/task_filter_chips.dart';
import 'package:testing_lab/widgets/task_input_bar.dart';
import 'package:testing_lab/widgets/task_list_view.dart';
import 'package:testing_lab/widgets/task_metrics_ribbon.dart';

export 'package:testing_lab/models/task_filter.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({
    super.key,
    required this.repository,
  });

  final TaskRepository repository;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskController _controller;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TaskController(widget.repository);
    _controller.loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final success = await _controller.addTask(_titleController.text);
    if (success) {
      _titleController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTokens.paper,
          appBar: TaskAppBar(
            completedCount: _controller.completedCount,
            totalCount: _controller.totalCount,
          ),
          body: Column(
            children: [
              TaskMetricsRibbon(
                total: _controller.totalCount,
                pending: _controller.pendingCount,
                completed: _controller.completedCount,
              ),
              TaskInputBar(
                controller: _titleController,
                onSubmitted: _handleSubmit,
                errorText: _controller.inputError,
              ),
              TaskFilterChips(
                selectedFilter: _controller.filter,
                totalCount: _controller.totalCount,
                activeCount: _controller.pendingCount,
                completedCount: _controller.completedCount,
                onSelected: _controller.setFilter,
              ),
              if (_controller.errorMessage != null)
                TaskErrorBanner(
                  errorMessage: _controller.errorMessage!,
                  onRetry: _controller.loadTasks,
                ),
              Expanded(
                child: TaskListView(
                  isLoading: _controller.isLoading,
                  tasks: _controller.filteredTasks,
                  onToggle: _controller.toggleTask,
                  onDelete: _controller.deleteTask,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
