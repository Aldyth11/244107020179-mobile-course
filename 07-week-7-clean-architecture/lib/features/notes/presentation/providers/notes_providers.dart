import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';

// 1. Repository Provider (Interface)
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final openDb = ref.watch(openDatabaseProvider);
  return NoteRepositoryImpl(openDb: openDb);
});

// 2. Use Case Provider
final getNotesUseCaseProvider = Provider<GetNotes>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return GetNotes(repo);
});

// 3. Async Notifier Provider (Standar Riverpod 3.x)
final notesListNotifierProvider =
    AsyncNotifierProvider<NotesListNotifier, List<Note>>(() {
  return NotesListNotifier();
});

class NotesListNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    return _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    final getNotes = ref.read(getNotesUseCaseProvider);
    final result = await getNotes();

    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> loadNotes() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchNotes());
  }

  Future<void> addNote(String title, String body) async {
    final repo = ref.read(noteRepositoryProvider);
    final result = await repo.addNote(title: title, body: body);

    if (result.failure == null) {
      await loadNotes();
    }
  }
}