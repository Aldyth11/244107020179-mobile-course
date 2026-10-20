import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_7_clean_architecture/core/failures.dart';
import 'package:week_7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week_7_clean_architecture/features/notes/domain/repositories/note_repository.dart';
import 'package:week_7_clean_architecture/features/notes/presentation/widgets/notes_body.dart';
import 'package:week_7_clean_architecture/features/notes/presentation/providers/notes_providers.dart';

class EmptyNoteRepository implements NoteRepository {
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    return (notes: const <Note>[], failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('empty state tampil saat hasil search kosong', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(EmptyNoteRepository()),
        ],
        child: const MaterialApp(home: Scaffold(body: NotesBody())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });
}
