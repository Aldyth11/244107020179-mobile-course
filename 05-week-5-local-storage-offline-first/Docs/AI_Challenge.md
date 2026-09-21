# AI Challenge: Strategi Penyimpanan Data Lokal (Offline Notes)

Dokumen ini berisi dokumentasi evaluasi dan analisis pemilihan media penyimpanan lokal (*local storage*) untuk aplikasi Flutter Offline Notes berbasis panduan *AI Challenge*.

---

## 1. Prompt AI Challenge
Berikut adalah prompt yang digunakan untuk menguji rekomendasi dari AI Coding Assistant:

> Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema. Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini.
> 
> **Requirements:**
> - Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing.
> - Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel.
> - Tunjukkan skema tabel/kotak untuk 1000+ catatan. Jelaskan trade-off setiap pilihan.

---

## 2. Hasil Evaluasi & Analisis AI

### A. Tabel Perbandingan Media Penyimpanan

| Kriteria Evaluasi | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat Terbatas (Key-Value) | Dasar (Filtering manual) | Tinggi (Raw SQL) | Sangat Tinggi (Fluent SQL / Type-safe) |
| **Kebutuhan Relasi** | Tidak Mendukung | Tidak Mendukung | Mendukung (Foreign Key) | Mendukung (Relasi Type-safe) |
| **Reaktivitas (Stream)** | Tidak Ada | Ada (`ValueListenable`) | Tidak Ada (Perlu manual) | Sangat Baik (Native `.watch()`) |
| **Type-Safety** | Rendah | Sedang (Adapter) | Rendah (`Map<String, dynamic>`) | Sangat Tinggi (Code Gen) |
| **Ukuran Boilerplate** | Sangat Minimal | Sedang | Sedang | Sangat Besar (`build_runner`) |
| **Kemudahan Testing** | Sangat Mudah | Mudah (*In-memory box*) | Agak Rumit | Mudah (*In-memory SQLite*) |

---

### B. Rekomendasi Awal AI

| Kebutuhan Data | Media Direkomendasikan | Alasan Utama AI |
| :--- | :--- | :--- |
| **Preferensi Tema** | `SharedPreferences` | Efisien dan ringan untuk menyimpan variabel UI berskala kecil. |
| **Data Catatan** | `Drift` / `Hive` | **Drift:** Menawarkan *type-safety* dan pencarian SQL.<br>**Hive:** Kinerja membaca/menulis data sangat cepat (*NoSQL*). |

---

## 3. Checklist Verifikasi AI

Hasil penelusuran terhadap jawaban yang diberikan oleh AI:

- [x] **Apakah AI menolak SharedPreferences untuk koleksi catatan?**
  * **Status:** Ya, AI menolak.
  * **Temuan:** AI dengan tepat menyarankan `SharedPreferences` hanya untuk preferensi statis karena tidak dirancang untuk menangani struktur daftar/koleksi data yang besar.
- [x] **Apakah skema mendukung antrean sinkronisasi (dirty flag / updated_at)?**
  * **Status:** Terpenuhi.
  * **Temuan:** Skema menyediakan kolom `dirty` dan `updated_at` untuk mengelola status data lokal yang belum tersinkron ke server.
- [x] **Apakah fitur real-time didukung oleh Stream?**
  * **Status:** Tervalidasi.
  * **Temuan:** Reaktivitas data pada Drift diverifikasi menggunakan mekanisme `.watch()` native.
- [x] **Apakah estimasi boilerplate tergolong masuk akal?**
  * **Status:** Sesuai.
  * **Temuan:** Drift dan Hive memang membutuhkan waktu setup tambahan karena ketergantungan pada pustaka *code generation*.

---

## 4. Keputusan Akhir Arsitektur Storage

Setelah mempertimbangkan performa, produktivitas pengembangan, efisiensi resource, dan kemudahan pengujian, berikut adalah arsitektur *local storage* yang ditetapkan:

### 1. Storage Preferensi (Tema & Konfigurasi): `SharedPreferences`
* **Keputusan:** Menerima rekomendasi AI.
* **Analisis & Alasan:**
  * **Karakteristik Data:** Preferensi tema dan setting UI bersifat *flat key-value* sederhana (seperti `bool` atau `int`).
  * **Efisiensi:** Menggunakan database relasional/NoSQL untuk sekadar menyimpan 1–2 flag status adalah bentuk *over-engineering* yang tidak perlu. `SharedPreferences` menawarkan *bootstrapping* tercepat dan beban RAM yang sangat minimal untuk kebutuhan ini.

### 2. Storage Data Catatan (1000+ Items): `Drift`
* **Keputusan:** Menerima rekomendasi AI (*Menolak sqflite dan SharedPreferences*).
* **Analisis & Alasan:**
  * **Menolak SharedPreferences:** Tidak aman dan sangat tidak efisien untuk membaca/menulis list berisi 1000+ objek JSON (memicu kemacetan thread/UI jank akibat beban *parsing* string).
  * **Menolak sqflite:** Meskipun ringan tanpa *code generation*, `sqflite` mengandalkan kueri string mentah (*raw SQL*) dan mengembalikan `Map<String, dynamic>` yang rentan *human-error* (salah ketik nama kolom), serta butuh usaha manual ekstra untuk membuat mekanisme *Stream/reactive*.
  * **Memilih Drift:** Drift memberikan proteksi *compile-time type-safety* yang kuat, otomatis meminimalisir bug penulisan query, dan mendukung fitur `.watch()` native untuk pembaruan UI otomatis (*real-time reactive UI*). *Overhead setup* awal menggunakan `build_runner` terbayar tuntas dengan kualitas kode yang maintainable dan mudah di-test (*In-memory SQLite testing*).

---

### 3. Rancangan Skema Tabel Catatan (Drift / SQL Ready)

Skema ini dirancang menggunakan SQLite engine (via Drift/sqflite) agar *scalable* saat jumlah catatan membengkak hingga ribuan, lengkap dengan indikator sinkronisasi *offline-first*:

```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_dirty INTEGER NOT NULL DEFAULT 0,
    is_deleted INTEGER NOT NULL DEFAULT 0
);