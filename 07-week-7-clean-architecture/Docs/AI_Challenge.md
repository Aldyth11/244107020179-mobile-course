# Dokumen AI Challenge - Clean Architecture Refactoring

## 1. Prompt AI yang Digunakan
> "Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
> Kondisi kini: folder lib/{data, providers, pages, messaging}, repository tercampur dengan implementasi, widget memanggil Dio langsung.
> Tugas:
> 1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data) untuk fitur auth + announcements.
> 2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
> 3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana, dan kapan use case benar-benar dibutuhkan vs repository langsung.
> 4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
> Jelaskan trade-off setiap keputusan."

---

## 2. Tabel Usulan AI vs Keputusan Final (Trade-off Analysis)

| File / Komponen Lama | Usulan AI | Keputusan Final Saya | Alasan Teknis & Trade-off |
| :--- | :--- | :--- | :--- |
| `data/auth_repository.dart` | Dipecah jadi Interface di `domain/` dan Impl di `data/`. | **Diterima (Dipecah)** | Memisahkan abstraksi dari implementasi HTTP/Dio agar domain layer tidak tergantung pihak ketiga. |
| `pages/login_page.dart` | Dipindah ke `features/auth/presentation/pages/`. | **Diterima (Dipindah)** | Menjaga UI tetap berada murni di Presentation Layer tanpa memanggil API langsung. |
| `providers/auth_provider.dart` | Dipindah ke `features/auth/presentation/providers/`. | **Diterima (Dipindah)** | Tempat terpusat untuk wiring Dependency Injection via Riverpod. |
| **Use Cases untuk CRUD Sederhana** | AI mengusulkan Use Case terpisah untuk tiap aksi (`GetNotes`, `AddNote`, `DeleteNote`). | **Ditolak Sebagian (Over-engineering)** | Untuk CRUD 1-baris tanpa logika bisnis rumit, Notifier langsung memanggil Repository. Use Case **hanya dibuat** untuk aksi yang melibatkan validasi/sorting khusus (misal: `GetNotes`) agar kode tidak bloat. |

---

## 3. Hasil Verifikasi AI Checklist

1. **Aturan Abstraksi Repository:**
   - **Status:** Lolos. Interface `NoteRepository` berada di `domain/repositories/`, sedangkan `NoteRepositoryImpl` berada di `data/repositories/`.

2. **Sterilisasi Layer Domain (Grep Check):**
   - **Status:** Lolos (0 Violations). Domain steril dari `flutter`, `sqflite`, `dio`, dan `firebase`.

3. **Analisis Over-engineering:**
   - **Status:** Diidentifikasi. Pembuatan Use Case untuk operasi CRUD dasar bernilai 1 baris dianggap over-engineering. Repository dipanggil langsung dari StateNotifier/Riverpod provider pada operasi simpel.

4. **Kemerdekaan Entity:**
   - **Status:** Lolos. Model (`NoteModel`) menangani `toMap()` dan `fromMap()`. Entity (`Note`) murni tanpa mapping.

5. **Pusat Dependency Injection:**
   - **Status:** Lolos. Wiring DI dikelola sepenuhnya oleh Provider Riverpod di layer Presentation (`notes_providers.dart`).

---

## 4. Hasil Perintah Verifikasi Grep

```powershell
# 1. Cek Presentation Steril dari Data/Storage Mentah
Get-ChildItem -Path lib/features/*/presentation -Recurse -Include *.dart -ErrorAction SilentlyContinue | Select-String -Pattern "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode"
# Hasil: 0 Violations (Bersih)

# 2. Cek Domain Steril dari Framework & Package Pihak Ketiga
Get-ChildItem -Path lib/features/*/domain, lib/core -Recurse -Include *.dart -ErrorAction SilentlyContinue | Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# Hasil: 0 Violations (Bersih)