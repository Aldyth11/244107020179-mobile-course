import 'package:flutter/material.dart';
import 'package:testing_lab/theme/app_tokens.dart';

class TaskErrorBanner extends StatelessWidget {
  const TaskErrorBanner({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('task-error-banner'),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTokens.dangerWash,
        borderRadius: BorderRadius.circular(AppTokens.radiusSmall),
        border: Border.all(color: AppTokens.dangerBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTokens.danger,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 13,
                color: AppTokens.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppTokens.danger,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

