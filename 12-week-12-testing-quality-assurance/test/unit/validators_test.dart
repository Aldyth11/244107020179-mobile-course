import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/utils/validators.dart';

void main() {
  group('validateTaskTitle', () {
    test('mengembalikan error jika teks bernilai null', () {
      final result = validateTaskTitle(null);
      expect(result, equals('Judul tugas tidak boleh kosong'));
    });

    test('mengembalikan error jika teks kosong', () {
      final result = validateTaskTitle('');
      expect(result, equals('Judul tugas tidak boleh kosong'));
    });

    test('mengembalikan error jika teks hanya terdiri dari spasi (whitespace)', () {
      final result = validateTaskTitle('     ');
      expect(result, equals('Judul tugas tidak boleh kosong'));
    });

    test('mengembalikan error jika panjang karakter kurang dari 3', () {
      final result = validateTaskTitle('ab');
      expect(result, equals('Judul tugas minimal 3 karakter'));
    });

    test('mengembalikan error jika panjang karakter melebihi 50', () {
      final longText = 'A' * 51;
      final result = validateTaskTitle(longText);
      expect(result, equals('Judul tugas maksimal 50 karakter'));
    });

    test('mengembalikan null jika judul valid (kasus normal)', () {
      final result = validateTaskTitle('Mengerjakan Laporan Week 12');
      expect(result, isNull);
    });

    test('mengembalikan null jika batas minimal tepat 3 karakter setelah di-trim', () {
      final result = validateTaskTitle('  ABC  ');
      expect(result, isNull);
    });

    test('mengembalikan null jika batas maksimal tepat 50 karakter', () {
      final text50 = 'A' * 50;
      final result = validateTaskTitle(text50);
      expect(result, isNull);
    });
  });
}

