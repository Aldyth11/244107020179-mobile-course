import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle', () {
    test('menerima judul yang berisi teks', () {
      expect(isValidTaskTitle('Belajar Flutter'), isTrue);
    });

    test('menolak teks kosong atau hanya spasi', () {
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle('   '), isFalse);
    });

    test('menerima judul yang mengandung simbol dan angka', () {
      expect(isValidTaskTitle('Bab 12: Testing & QA (2026)'), isTrue);
      expect(isValidTaskTitle('12345'), isTrue);
    });

    test('menerima teks yang memiliki spasi di awal dan akhir asalkan ada karakter', () {
      expect(isValidTaskTitle('   Tugas Mandiri   '), isTrue);
    });
  });
}

