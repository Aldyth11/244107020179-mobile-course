import 'package:flutter/material.dart';

/// Optimized Quick Prompts Bar with RepaintBoundary and const layout
class QuickPromptsBar extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onSelectPrompt;

  const QuickPromptsBar({
    super.key,
    required this.prompts,
    required this.onSelectPrompt,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 6),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: prompts.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final prompt = prompts[index];
            return ActionChip(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              label: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
              ),
              onPressed: () => onSelectPrompt(prompt),
            );
          },
        ),
      ),
    );
  }
}
