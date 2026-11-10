import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:testing_lab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Alur Integrasi Aplikasi Pengujian Tugas', () {
    testWidgets('pengguna dapat menambahkan tugas, mengubah status, dan memfilter daftar tugas',
        (tester) async {
      // 1. Jalankan aplikasi utama
      app.main();
      await tester.pumpAndSettle();

      // 2. Verifikasi antarmuka awal
      expect(find.text('Daftar tugas'), findsOneWidget);
      expect(find.byKey(const Key('task-title-field')), findsOneWidget);
      expect(find.byKey(const Key('save-task-button')), findsOneWidget);

      // 3. Masukkan teks nama tugas ke field input
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Baca materi',
      );
      await tester.pumpAndSettle();

      // 4. Tekan tombol simpan/tambah tugas
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // 5. Periksa apakah tugas 'Baca materi' berhasil muncul di antarmuka
      expect(find.text('Baca materi'), findsOneWidget);
      expect(find.text('0/1 Selesai'), findsOneWidget);

      // 6. Masukkan tugas kedua untuk skenario multi-item
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Praktikum Testing Week 12',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Praktikum Testing Week 12'), findsOneWidget);
      expect(find.text('0/2 Selesai'), findsOneWidget);

      // 7. Tandai tugas pertama menjadi selesai melalui checkbox
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pumpAndSettle();

      expect(find.text('1/2 Selesai'), findsOneWidget);

      // 8. Uji filter: Selesai
      await tester.tap(find.byKey(const Key('filter-completed')));
      await tester.pumpAndSettle();
      expect(find.text('Baca materi'), findsOneWidget);
      expect(find.text('Praktikum Testing Week 12'), findsNothing);

      // 9. Uji filter: Aktif
      await tester.tap(find.byKey(const Key('filter-active')));
      await tester.pumpAndSettle();
      expect(find.text('Baca materi'), findsNothing);
      expect(find.text('Praktikum Testing Week 12'), findsOneWidget);

      // 10. Kembalikan ke Semua
      await tester.tap(find.byKey(const Key('filter-all')));
      await tester.pumpAndSettle();
      expect(find.text('Baca materi'), findsOneWidget);
      expect(find.text('Praktikum Testing Week 12'), findsOneWidget);
    });
  });
}

