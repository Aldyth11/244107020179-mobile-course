import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_lab/models/task.dart';
import 'package:testing_lab/repositories/fake_task_repository.dart';
import 'package:testing_lab/screens/task_screen.dart';

void main() {
  group('TaskScreen Widget Test', () {
    late FakeTaskRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeTaskRepository(initialTasks: []);
    });

    testWidgets('menampilkan judul halaman tugas dan state awal kosong', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Memeriksa keberadaan judul AppBar
      expect(find.text('Daftar tugas'), findsOneWidget);

      // Memeriksa keberadaan input text field dan tombol aksi
      expect(find.byKey(const Key('task-title-field')), findsOneWidget);
      expect(find.byKey(const Key('save-task-button')), findsOneWidget);

      // Memeriksa state daftar kosong
      expect(find.byKey(const Key('empty-tasks-view')), findsOneWidget);
      expect(find.text('Belum ada tugas'), findsOneWidget);

      // Memeriksa chip counter
      expect(find.text('0/0 Selesai'), findsOneWidget);
    });

    testWidgets('menampilkan pesan error saat input kosong ditekan simpan', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Pengguna langsung menekan tombol tambah tanpa mengisi teks
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // Memeriksa pesan validasi muncul
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
      expect(fakeRepository.taskCount, 0);
    });

    testWidgets('menampilkan pesan error jika judul kurang dari 3 karakter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'ab',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Judul tugas minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('pengguna berhasil menambahkan tugas baru dan tampil di daftar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Input teks tugas baru
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Baca materi',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // Memeriksa item tugas baru muncul di layar
      expect(find.text('Baca materi'), findsOneWidget);
      expect(find.text('0/1 Selesai'), findsOneWidget);

      // Memeriksa teks input telah dibersihkan
      final textField = tester.widget<TextField>(find.byKey(const Key('task-title-field')));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('pengguna dapat mencentang status tugas menjadi selesai', (tester) async {
      fakeRepository = FakeTaskRepository(
        initialTasks: [
          Task(id: 't_toggle', title: 'Tugas Praktikum', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0/1 Selesai'), findsOneWidget);

      // Tap checkbox tugas
      await tester.tap(find.byKey(const Key('task-checkbox-t_toggle')));
      await tester.pumpAndSettle();

      // Status counter terbarui
      expect(find.text('1/1 Selesai'), findsOneWidget);
    });

    testWidgets('pengguna dapat menghapus tugas dari daftar', (tester) async {
      fakeRepository = FakeTaskRepository(
        initialTasks: [
          Task(id: 't_del', title: 'Tugas yang akan dihapus', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tugas yang akan dihapus'), findsOneWidget);

      // Tap tombol hapus
      await tester.tap(find.byKey(const Key('delete-task-t_del')));
      await tester.pumpAndSettle();

      // Memeriksa tugas sudah terhapus dan kembali ke state kosong
      expect(find.text('Tugas yang akan dihapus'), findsNothing);
      expect(find.byKey(const Key('empty-tasks-view')), findsOneWidget);
    });

    testWidgets('filter dapat menyaring tugas aktif dan selesai', (tester) async {
      fakeRepository = FakeTaskRepository(
        initialTasks: [
          Task(id: '1', title: 'Tugas Belum Selesai', isCompleted: false),
          Task(id: '2', title: 'Tugas Sudah Selesai', isCompleted: true),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      // Awalnya menampilkan keduanya
      expect(find.text('Tugas Belum Selesai'), findsOneWidget);
      expect(find.text('Tugas Sudah Selesai'), findsOneWidget);

      // Filter: Aktif saja
      await tester.tap(find.byKey(const Key('filter-active')));
      await tester.pumpAndSettle();
      expect(find.text('Tugas Belum Selesai'), findsOneWidget);
      expect(find.text('Tugas Sudah Selesai'), findsNothing);

      // Filter: Selesai saja
      await tester.tap(find.byKey(const Key('filter-completed')));
      await tester.pumpAndSettle();
      expect(find.text('Tugas Belum Selesai'), findsNothing);
      expect(find.text('Tugas Sudah Selesai'), findsOneWidget);
    });

    testWidgets('menampilkan banner error ketika repository melempar exception saat memuat data', (tester) async {
      fakeRepository.error = Exception('Koneksi database lokal terputus');

      await tester.pumpWidget(
        MaterialApp(
          home: TaskScreen(repository: fakeRepository),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-error-banner')), findsOneWidget);
      expect(find.textContaining('Gagal memuat tugas'), findsOneWidget);
    });
  });
}

