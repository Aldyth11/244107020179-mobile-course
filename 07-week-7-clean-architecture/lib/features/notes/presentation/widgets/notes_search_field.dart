import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_providers.dart';

class NotesSearchField extends ConsumerWidget {
  const NotesSearchField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Cari judul...',
          prefixIcon: Icon(Icons.search),
          filled: true,
          isDense: true,
        ),
        onChanged: (value) =>
            ref.read(notesListNotifierProvider.notifier).search(value),
      ),
    );
  }
}
