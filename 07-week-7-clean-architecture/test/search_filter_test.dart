import 'package:flutter_test/flutter_test.dart';
import 'package:week_7_clean_architecture/features/notes/domain/entities/note.dart';
import 'package:week_7_clean_architecture/features/notes/domain/usecases/search_notes.dart';

void main() {
  final notes = [
    Note(title: 'Belanja Mingguan', updatedAt: DateTime(2026, 9, 27)),
    Note(title: 'Daftar belanja', updatedAt: DateTime(2026, 9, 27)),
    Note(title: 'Rapat Dosen', updatedAt: DateTime(2026, 9, 27)),
  ];

  test('query kosong mengembalikan semua catatan', () {
    expect(SearchNotes.filter(notes, '  '), hasLength(3));
  });

  test('query belanja tidak membedakan huruf besar kecil', () {
    expect(SearchNotes.filter(notes, 'BELANJA'), hasLength(2));
  });

  test('query dengan spasi berlebih tetap menemukan judul', () {
    expect(
      SearchNotes.filter(notes, 'belanja  mingguan').single.title,
      'Belanja Mingguan',
    );
  });

  test('query yang tidak cocok mengembalikan daftar kosong', () {
    expect(SearchNotes.filter(notes, 'ujian'), isEmpty);
  });
}
