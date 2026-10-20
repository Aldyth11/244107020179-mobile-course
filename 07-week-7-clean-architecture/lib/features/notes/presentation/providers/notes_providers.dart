import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final openDb = ref.watch(openDatabaseProvider);
  return NoteRepositoryImpl(openDb);
});

final getNotesUseCaseProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final searchNotesUseCaseProvider = Provider<SearchNotes>((ref) {
  return SearchNotes(ref.watch(noteRepositoryProvider));
});

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final notesListNotifierProvider =
    AsyncNotifierProvider<NotesListNotifier, List<Note>>(NotesListNotifier.new);

class NotesListNotifier extends AsyncNotifier<List<Note>> {
  int _searchVersion = 0;

  @override
  Future<List<Note>> build() => _search('');

  Future<List<Note>> _search(String query) async {
    final result = await ref.read(searchNotesUseCaseProvider).call(query);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.notes;
  }

  Future<void> loadNotes() async {
    final version = ++_searchVersion;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => _search(ref.read(searchQueryProvider)),
    );
    if (version == _searchVersion) state = nextState;
  }

  Future<void> search(String query) async {
    final version = ++_searchVersion;
    ref.read(searchQueryProvider.notifier).setQuery(query);
    final nextState = await AsyncValue.guard(() => _search(query));
    if (version == _searchVersion) state = nextState;
  }

  Future<void> addNote(String title, String body) async {
    final result = await ref
        .read(noteRepositoryProvider)
        .addNote(title: title, body: body);
    if (result.failure == null) {
      await loadNotes();
    }
  }
}
