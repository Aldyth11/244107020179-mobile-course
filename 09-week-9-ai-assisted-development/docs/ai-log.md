# AI Development Log - Praktikum Minggu 9

## Praktikum 2

### 1. Prompt Mentah (5 Slot)

```
[Peran]
Senior Flutter Developer.

[Konteks]
Project Flutter ini menggunakan arsitektur Minggu 7 (feature-first, Riverpod, SQLite+Dio).
Silakan baca file kontrak repository di @note_repository.dart (atau @notification_repository.dart) dan provider terkait.

[Tugas]
Tambahkan fitur pencarian (search) berdasarkan judul beserta tampilan empty state saat hasil cari kosong.

[Batasan]
1. Jangan ubah arsitektur layer (presentation -> domain <- data).
2. Dilarang memanggil SQLite/Dio langsung dari Widget UI.
3. Kode baru/perubahan maksimal 80 baris.
4. Jangan menyertakan secret/token/API key.

[Output]
1. Kode implementasi baru / perubahan.
2. 1 test case untuk menguji pencarian/empty state.
3. Cara singkat menjalankan ujinya.

```

### 2. Output Awal AI

```
// Implementasi awal yang digenerate oleh AI Assistant
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/features/notes/domain/search_notes.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider((ref) {
  final query = ref.watch(searchQueryProvider);
  final notes = ref.watch(notesNotifierProvider);

  return filterNotes(notes, query);
});

```

### 3. Hasil Verifikasi 6 Langkah

#### 1. Baca & Pahami Baris Kode

- Kode pada `search_notes.dart` menggunakan `trim()` + `toLowerCase()` lalu `title.contains(q)`. Query kosong mengembalikan daftar utuh.

- Penyesuaian pemahaman: `StateProvider` bukan API default di Riverpod 3.4.3, dan nama fungsi disesuaikan dengan kontrak repo (`SearchNotes.filter`).

#### 2. Verifikasi Import Domain

- Perintah: `grep -rn "package:flutter" lib/features/**/domain`

- Hasil: **0 hit**. Layer domain bersih dari `flutter`, `dio`, `sqflite`, maupun `firebase`.

#### 3. Verifikasi API & Package

| Pemakaian                         | Status                           |
| --------------------------------- | -------------------------------- |
| `NoteRepository.fetchNotes()`     | Ada di kontrak                   |
| `SearchNotes.filter` / `.call`    | Ada                              |
| `NotifierProvider` + `Notifier`   | Diekspor `flutter_riverpod.dart` |
| `AsyncValue.whenData`             | Ada                              |
| `AppBar.bottom` + `PreferredSize` | Flutter Material                 |
| `StateProvider` (tanpa legacy)    | **Tidak Ada** _(Halusinasi AI)_  |
| `filterNotes(...)`                | **Tidak Ada** _(Halusinasi AI)_  |

#### 4. Static Analysis (`flutter analyze`)

```
flutter analyze

```

_Output:_ `No issues found!` (0 warning / 0 error).

#### 5. Pengujian Otomatis (`flutter test`)

Unit test berada pada `test/get_notes_test.dart`:

```
test('filter abaikan huruf besar/kecil', () {
  expect(SearchNotes.filter(list, 'belanja'), hasLength(2));
});

test('query tak cocok kembalikan kosong', () {
  expect(SearchNotes.filter(list, 'zzz-tak-ada'), isEmpty);
});

```

_Hasil saat pencatatan awal:_ `+6: All tests passed!`. Test kemudian
dikembangkan menjadi unit test terpisah dan widget test empty state.

#### 6. Pengujian Manual di UI

| Query           | Hasil Tes | Tampilan UI                                                        |
| --------------- | --------- | ------------------------------------------------------------------ |
| `' '` (kosong)  | 3 catatan | Daftar penuh                                                       |
| `'belanja'`     | 2 catatan | Menampilkan catatan cocok                                          |
| `'zzz-tak-ada'` | `isEmpty` | Tampilan Empty State: _"Tidak ada catatan dengan judul tersebut."_ |

### 4. Bukti Halusinasi AI & Perbaikan

- **Klaim Halusinasi AI:** AI menyarankan penggunaan `StateProvider<String>((ref) => '')` langsung dari `import 'package:flutter_riverpod/flutter_riverpod.dart'` pada Riverpod versi 3.4.3.

- **Bukti Source Code (Grep):**
  Export default pada package `flutter_riverpod-3.4.3` tidak menyertakan `StateProvider`:

  ```
  // flutter_riverpod.dart
  AsyncNotifierProvider,
  FutureProvider,
  Notifier,
  NotifierProvider,
  Provider,

  ```

  `StateProvider` telah dipindahkan ke `legacy.dart`.

- **Bukti Error Analyzer:** `The function 'StateProvider' isn't defined.`

- **Perbaikan:** Melakukan refactor kode menggunakan `NotifierProvider<SearchQueryNotifier, String>` sesuai standar Riverpod versi terbaru.

## Praktikum 3 Debug & Refactor

### Reproduksi bug

1. Ada catatan berjudul `Belanja Mingguan`.
2. Ketik query `belanja  mingguan` (dua spasi di tengah).
3. UI menampilkan empty state; filter mengembalikan daftar kosong.

### Test merah (sebelum perbaikan)

Perintah:

```powershell
flutter test test/get_notes_test.dart --name "filter abaikan spasi berlebih"
```

Hasil:

```
Expected: an object with length of <1>
  Actual: []
   Which: has length of <0>
```

### Isolasi

Aturan filter dipindah ke use case murni `SearchNotes` (domain).
Notifier hanya memanggil `searchNotesUseCaseProvider`.
Widget tidak memfilter dan tidak membuka SQLite/Dio.

### Akar masalah

`String.contains` membandingkan query setelah `trim()` + `toLowerCase()` saja.
Spasi berlebih tidak dinormalisasi, jadi `belanja  mingguan` tidak dianggap
bagian dari `belanja mingguan`.

### Perbaikan

`SearchNotes.normalize` merapikan spasi (`\s+` → satu spasi) sebelum filter.
Test yang sama dijalankan ulang hingga hijau.

### Refactor layer

`widget (UI)` → `NotesListNotifier (state)` → `SearchNotes (filter)` → `NoteRepository (SQLite)`

## Refactoring Challenge

### Keputusan refactor

- Output awal AI disederhanakan menjadi `SearchNotes.filter`, `normalize`, dan
  `emptyMessage` di domain. Setiap fungsi kecil dan dapat diuji tanpa Flutter,
  database, atau jaringan.
- Filter/search dipindahkan dari widget ke use case domain. Widget hanya
  membaca state notifier dan menampilkan daftar atau empty state.
- Import lintas layer diperiksa. Domain feature tidak mengimpor `flutter`,
  `dio`, `sqflite`, atau `firebase`.
- Race condition pada pencarian async juga diperbaiki dengan version guard di
  `NotesListNotifier`, sehingga hasil request lama tidak menimpa query terbaru.

### Test yang ditambahkan

Perintah unit test sesuai challenge:

```powershell
flutter test test/search_filter_test.dart
```

Hasil: `All tests passed (+4)`.

Widget test empty state berada di `test/empty_state_test.dart` dan dijalankan
dengan:

```powershell
flutter test test/empty_state_test.dart
```

Hasil: `All tests passed (+1)`. Repository palsu mengembalikan daftar kosong,
lalu UI menampilkan `Belum ada catatan.`.

### Tiga query untuk uji manual

| Query         | Hasil yang diharapkan                                  |
| :------------ | :----------------------------------------------------- |
| kosong/spasi  | Semua catatan ditampilkan                              |
| `belanja`     | Catatan dengan judul yang memuat belanja ditampilkan   |
| `zzz-tak-ada` | Empty state `Tidak ada catatan dengan judul tersebut.` |

Screenshot manual disimpan pada folder `screenshots/` sebagai bukti visual.

### Checklist verifikasi mandiri

- Prompt 5 slot + konteks: **terpenuhi** di bagian Prompt Mentah.
- Filter domain murni dan import lintas layer: **terpenuhi**.
- `flutter analyze`: **bersih**, `No issues found!`.
- `flutter test`: **hijau**, semua test lulus.
- Temuan AI terbukti benar: race condition dibuktikan dengan test request
  selesai tidak berurutan di `test/get_notes_test.dart`.
- Temuan AI ditolak dengan alasan teknis: filtering SQLite/API ditunda karena
  kontrak repository masih lokal dan perubahan tersebut di luar scope codelab.
- Keputusan dapat dijelaskan tanpa membuka AI: **terpenuhi**.

## Praktikum 5 Mini Project / Industry Challenge

### Fitur yang ditambahkan

Fitur kecil yang dipilih adalah **search/filter catatan berdasarkan judul**
dengan empty state ketika tidak ada hasil. Alurnya:

`NotesSearchField` → `NotesListNotifier` → `SearchNotes` → `NoteRepository`

Filter berada di use case domain melalui `SearchNotes.filter`, sehingga aturan
normalisasi huruf dan spasi dapat diuji tanpa Flutter, SQLite, atau jaringan.
`NotesBody` hanya menampilkan daftar hasil atau pesan empty state.

### Prompt inti, konteks, dan output awal

Prompt inti dengan konteks 5 slot dan output awal AI terdokumentasi di bagian
**Praktikum 2** pada file ini. Output awal tersebut mengusulkan
`StateProvider` dan `filterNotes`, lalu diverifikasi terhadap Riverpod serta
kontrak repository aktual. Keduanya tidak digunakan karena API/fungsi tersebut
tidak tersedia pada implementasi repo ini.

### Tabel terima/tolak saran AI

| Saran AI                                                                           | Keputusan                 | Alasan teknis                                                                                                                                      | Bukti grep/test                                                                                                               |
| :--------------------------------------------------------------------------------- | :------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------- | --- | ------- | ------------------------------- |
| Tambahkan perlindungan terhadap race condition pada search async.                  | **Terima + refactor**     | Request lama dapat selesai setelah query baru dan menimpa state terbaru. Version guard memastikan hanya request terakhir yang mengubah state.      | Test `hasil search lama tidak menimpa query terbaru` di `test/get_notes_test.dart` lulus.                                     |
| Tambahkan test untuk request yang selesai tidak berurutan.                         | **Terima**                | Test filter biasa tidak menguji urutan penyelesaian Future atau konsistensi state notifier.                                                        | `flutter test test/get_notes_test.dart` lulus `+8`; `flutter test` lulus `+14`.                                               |
| Pindahkan filtering ke SQLite/API dengan menambah parameter query pada repository. | **Tolak untuk scope ini** | Data masih lokal dan kontrak repository hanya membutuhkan `fetchNotes()`. Mengubah kontrak domain akan memperbesar scope tanpa kebutuhan saat ini. | `flutter test test/search_filter_test.dart test/empty_state_test.dart` lulus `+5`; filter domain tetap teruji tanpa database. |
| Widget boleh mengimpor detail framework/storage untuk melakukan filter.            | **Tolak**                 | Melanggar batas `presentation -> domain <- data`; widget cukup membaca state dan menampilkan hasil.                                                | Grep domain feature dengan pola import `flutter                                                                               | dio | sqflite | firebase` menghasilkan 0 baris. |

Status setiap keputusan dapat dijelaskan dari bukti kode dan test tanpa perlu
menerima output AI secara mentah.

### Bukti mesin hijau

```powershell
flutter analyze
# No issues found!

flutter test
# All tests passed (+14)
```

Test fitur secara khusus:

```powershell
flutter test test/search_filter_test.dart test/empty_state_test.dart
# All tests passed (+5)
```

Unit test mencakup query kosong, pencarian case-insensitive, spasi berlebih,
dan query yang tidak cocok. Widget test memverifikasi empty state
`Belum ada catatan.` menggunakan repository palsu.
