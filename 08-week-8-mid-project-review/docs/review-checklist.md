# Review Hygiene Commit & Branch

## Audit Riwayat Commit Lama (Minggu 5–7)
| Commit Lama | Commit Baru (Conventional) | Alasan Perubahan |
| :--- | :--- | :--- |
| `Week 5 Local Storage dan Offline-First` | `feat(storage): tambah fitur penyimpanan lokal dan offline-first` | Mengubah ke tipe `feat` dengan scope `storage` agar memperjelas penambahan fitur penyimpanan lokal pada Week 5. |
| `Menyelesaikan Week 6` | `feat(auth): tambah autentikasi dan integrasi fcm week 6` | Memperjelas fitur spesifik yang dikerjakan alih-alih menggunakan nama minggu yang generik. |
| `Menyelesaikan Jobsheet 7` | `feat(architecture): implementasi clean architecture pada aplikasi week 7` | Mengganti kata 'Jobsheet 7' menjadi tipe `feat` dan nama modul arsitektur yang dikerjakan. |


## Kesiapan Mid Review (Praktikum 3)
- [x] Static Analysis (`flutter analyze`): Clean / 0 issues.
- [x] Code Formatting (`dart format`): Formatted & pass.
- [x] Automated Testing (`flutter test`): Pass (All tests passed).
- [x] Continuous Integration: Menambahkan GitHub Actions `.github/workflows/ci.yml`.

## Checklist Verifikasi Mandiri (Mid-Project Review)

- [x] **Branching & Issue:** Branch dibuat dari `develop`, PR dibuat kecil (satu fitur/refactor), dan issue ditutup otomatis via PR.
- [x] **Peer Review Process:** Minimal 3 komentar review bermakna dari reviewer sejawat telah ditindaklanjuti hingga mendapat `Approve`.
- [x] **Automated Checks:** Perintah `flutter analyze` bersih (0 issues), `dart format` rapi, dan `flutter test` hijau (semua test pass).
- [x] **AI Challenge Documentation:** Tabel perbandingan usulan AI vs keputusan final telah terdokumentasi lengkap di `docs/AI_Challenge.md`.
- [x] **Continuous Integration:** Automated CI workflow (`.github/workflows/ci.yml`) siap menolak PR kotor secara otomatis.