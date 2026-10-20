import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/search_notes.dart';
import '../providers/notes_providers.dart';

class NotesBody extends ConsumerWidget {
  const NotesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesState = ref.watch(notesListNotifierProvider);
    final query = ref.watch(searchQueryProvider);

    return notesState.when(
      data: (notes) => _NotesDataView(notes: notes, query: query),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _NotesErrorView(message: '$error'),
    );
  }
}

class _NotesDataView extends StatelessWidget {
  const _NotesDataView({required this.notes, required this.query});

  final List<Note> notes;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(child: Text(SearchNotes.emptyMessage(query)));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(title: Text(note.title), subtitle: Text(note.body));
      },
    );
  }
}

class _NotesErrorView extends ConsumerWidget {
  const _NotesErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Terjadi kesalahan: $message'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                ref.read(notesListNotifierProvider.notifier).loadNotes(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
