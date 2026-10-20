import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SearchNotes {
  const SearchNotes(this._repository);
  final NoteRepository _repository;

  static final _spaces = RegExp(r'\s+');

  static String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(_spaces, ' ');
  }

  static List<Note> filter(List<Note> notes, String query) {
    final q = normalize(query);
    if (q.isEmpty) return notes;
    return notes.where((n) => normalize(n.title).contains(q)).toList();
  }

  static String emptyMessage(String query) {
    return normalize(query).isEmpty
        ? 'Belum ada catatan.'
        : 'Tidak ada catatan dengan judul tersebut.';
  }

  Future<({List<Note> notes, Failure? failure})> call([
    String query = '',
  ]) async {
    final result = await _repository.fetchNotes();
    if (result.failure != null) return result;
    return (notes: filter(result.notes, query), failure: null);
  }
}
