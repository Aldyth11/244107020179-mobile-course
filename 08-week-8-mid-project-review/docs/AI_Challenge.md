# AI Review vs Keputusan Final (AI Challenge Week 8)

## Prompt yang Digunakan
> "Review PR Flutter ini sebagai senior Flutter dev. Konteks: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio. Fokus: kebenaran, arsitektur, dan test. Abaikan style. Berikan 5 temuan teratas + level (blocker/saran) + alasan + usulan potongan kode perbaikan."

---

## Output Awal AI & Evaluasi Temuan

### 1. Temuan 1 (DITERIMA - Blocker)
- **Topik:** Kegagalan Error Handling pada Repository (Missing Catch Block/Left Failure).
- **Hasil Verifikasi:** **Terbukti Benar.** Saat koneksi database/API gagal, method melemparkan exception mentah dan tidak mengembalikan `Failure` ke layer domain.
- **Bukti:** `flutter test` gagal saat mensimulasikan kegagalan database pada `note_repository_impl_test.dart`.
- **Keputusan Final:** Menerapkan perbaikan dari AI dengan membungkus operasi dalam `try-catch` dan mengembalikan `Left(DatabaseFailure())`.

### 2. Temuan 2 (DITERIMA - Saran)
- **Topik:** Penanganan Memory Leak pada StateNotifier / Riverpod Provider.
- **Hasil Verifikasi:** **Terbukti Benar.** Controller/Notifier tidak membersihkan listener atau resource async saat diposisikan pada lifecycle tertentu.
- **Bukti:** Analisis alokasi memori pada Flutter DevTools menunjukkan sisa acuan instance setelah halaman di-pop.
- **Keputusan Final:** Menggunakan `ref.onDispose()` untuk membatalkan subscription secara otomatis.

### 3. Temuan 3 (DITOLAK - Arsitektur / False Positive)
- **Topik:** AI menyarankan untuk mengimpor paket `Dio` atau `sqflite` langsung ke dalam file Usecase pada layer Domain.
- **Hasil Verifikasi:** **Ditolak.** Usulan ini melanggar *Dependency Rule* Clean Architecture (Layer Domain murni Dart/konseptual dan tidak boleh bergantung pada paket eksternal atau framework/data source).
- **Keputusan Final:** Menolak usulan AI dan tetap mempertahankan abstraksi `NoteRepository` di layer Domain tanpa dependency `Dio`/`sqflite`.

### 4. Temuan 4 (DITERIMA - Blocker)
- **Topik:** Unit test untuk `GetNotes` usecase belum menguji kasus skenario error/empty list.
- **Hasil Verifikasi:** **Terbukti Benar.** Test coverage pada folder `test/` hanya mencakup *happy path* (data berhasil ditarik).
- **Bukti:** Menjalankan `flutter test --coverage` menunjukkan baris error handling di domain/usecase belum pernah tersentuh pengujian.
- **Keputusan Final:** Menambahkan unit test baru untuk skenario eksekusi gagal di `test/get_notes_test.dart`.

### 5. Temuan 5 (DITOLAK - Nitpick Style)
- **Topik:** AI menyarankan refactoring penamaan variabel lokal agar menggunakan gaya tertentu.
- **Hasil Verifikasi:** **Ditolak.** Formatting/style sudah ditangani sepenuhnya oleh `dart format` dan linter `flutter analyze`.
- **Keputusan Final:** Menolak saran karena tidak memberikan dampak fungsional maupun arsitektural.

---

## Tabel Ringkasan Keputusan

| No | Temuan AI | Level | Status | Alasan Teknis / Bukti |
|---|---|---|---|---|
| 1 | Error handling failure di Repo | Blocker | Diterima | Test simulasi error gagal tanpa `catch` block |
| 2 | Potential memory leak di Provider | Saran | Diterima | Unhandled subscription terdeteksi di DevTools |
| 3 | Impor Dio/SQLite di Domain layer | Blocker | Ditolak | Melanggar Clean Architecture Dependency Rule |
| 4 | Test coverage skenario Failure kosong | Blocker | Diterima | Edge case failure belum diuji di `flutter test` |
| 5 | Format penamaan variabel lokal | Saran | Ditolak | Sudah dicover oleh `dart format` & `flutter analyze` |

---

## Bukti Pengujian Akhir
- **`flutter analyze`**: Clean / 0 issues.
- **`flutter test`**: All tests passed.