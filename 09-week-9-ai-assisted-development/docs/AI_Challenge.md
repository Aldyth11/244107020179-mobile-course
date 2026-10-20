# AI Challenge Review

Dokumen ini berisi hasil review dan keputusan teknis yang dibuat setelah membaca `AI_Challenge.md` awal. File `AI_Challenge.md` sengaja dipertahankan sebagai dokumen challenge asli.

## Prompt Review

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

## Output Review AI

1. **Saran - race condition pada `NotesListNotifier.search`.** Request lama dapat selesai setelah request baru dan menimpa state query terbaru.
2. **Saran - test belum menguji request yang selesai tidak berurutan.** Test filter biasa belum membuktikan konsistensi state saat dua operasi async berjalan bersamaan.
3. **Saran - pertimbangkan filtering di SQLite/API.** Filtering lokal mengambil semua catatan terlebih dahulu jika data membesar.

## Tabel Terima/Tolak

| Saran AI                                                   | Keputusan                 | Alasan teknis                                                                                                  | Bukti grep/test                                                                     |
| :--------------------------------------------------------- | :------------------------ | :------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------- |
| Perlindungan race condition pada search async.             | **Terima + refactor**     | Version guard memastikan hanya request terakhir yang mengubah state.                                           | Test `hasil search lama tidak menimpa query terbaru` di `test/get_notes_test.dart`. |
| Test request yang selesai tidak berurutan.                 | **Terima**                | Test filtering biasa tidak menguji urutan penyelesaian Future.                                                 | `flutter test test/get_notes_test.dart` lulus.                                      |
| Filtering dipindahkan ke SQLite/API.                       | **Tolak untuk scope ini** | Data masih lokal dan kontrak repository hanya membutuhkan `fetchNotes()`; perubahan kontrak memperbesar scope. | `flutter test test/search_filter_test.dart test/empty_state_test.dart` lulus.       |
| Widget mengimpor detail framework/storage untuk filtering. | **Tolak**                 | Melanggar batas `presentation -> domain <- data`.                                                              | Grep import domain feature untuk Flutter/Dio/sqflite/Firebase menghasilkan 0 baris. |

## Bukti Verifikasi

```powershell
flutter analyze
flutter test
```

Hasil terakhir yang dicatat: analyzer bersih dan seluruh test lulus `+14`.

Fitur search/filter berada di use case domain `SearchNotes`, sedangkan widget hanya menampilkan daftar atau empty state.
