# Week 2: Declarative UI & Responsive Design

**Nama:** M. Aldyth Rafiansyah Fauzi  
**NIM:** 244107020179  
**Kelas:** TI - 3G

## Tujuan
1. Memahami konsep UI deklaratif dan hubungan antara widget tree, state, serta tampilan aplikasi.
2. Menerapkan layout dasar Flutter menggunakan `Container`, `Row`, `Column`, `Expanded`, dan `Card`.
3. Membuat tampilan yang responsif terhadap perubahan lebar layar menggunakan `LayoutBuilder`, breakpoint, dan `GridView`.
4. Menerapkan tema terang-gelap serta kontrol interaktif menggunakan `Switch.adaptive`.
5. Menambahkan dukungan aksesibilitas dengan widget `Semantics` pada komponen aplikasi.

---

## Konsep UI Deklaratif dan Responsive Design
* **UI deklaratif:** Tampilan aplikasi didefinisikan berdasarkan kondisi dan data saat ini. Ketika state berubah, Flutter membangun ulang bagian widget tree yang diperlukan.
* **Responsive design:** Susunan komponen menyesuaikan ukuran layar. Pada layar sempit, elemen ditampilkan dalam satu kolom, sedangkan pada layar lebar elemen dapat disusun menjadi beberapa kolom.
* **Breakpoint:** Batas lebar tertentu yang digunakan untuk menentukan perubahan layout. Pada dashboard utama, breakpoint `600.0` digunakan untuk mengubah susunan kartu informasi.

---

## Dokumentasi & Screenshots
### 1. Layout Profil Mahasiswa Dasar
![Layout Sederhana](screenshots/layout%20sederhana%20awal.png)
> **Penjelasan:** Implementasi layout dasar menggunakan `Container`, `Row`, `Column`, `CircleAvatar`, dan `Expanded` untuk menampilkan nama mahasiswa, NIM, serta kelas.

---

### 2. Eksperimen Layout Sederhana
![Eksperimen Layout Sederhana](screenshots/layout%20sederhana%20eksperimen1.png)
![Eksperimen Layout Sederhana 2](screenshots/layout%20sederhana%20eksperimen2.png)
![Eksperimen Layout Sederhana 3](screenshots/layout%20sederhana%20eksperimen3.png)
> **Penjelasan:** Beberapa hasil eksperimen terhadap susunan widget, jarak antar-komponen, ukuran layar, dan tampilan kartu profil pada Flutter.

---

### 3. Dashboard Responsif
![Responsive Dashboard](screenshots/responsive%20dashboard.png)
> **Penjelasan:** Dashboard mahasiswa menampilkan kartu `Assignments`, `Attendance`, `Portfolio`, dan `Current week`. `LayoutBuilder` dan `GridView.count` digunakan untuk mengatur satu atau dua kolom sesuai lebar layar.

---

### 4. Dashboard pada Emulator
![Responsive Dashboard Emulator](screenshots/responsive%20dashboard%20emulator.png)
> **Penjelasan:** Hasil render dashboard pada emulator perangkat dengan layout yang menyesuaikan ukuran layar mobile.

---

### 5. Eksperimen Breakpoint dan Tema
![Responsive Dashboard Experiment](screenshots/responsive%20dashboard%20eksperimen.png)
> **Penjelasan:** Eksperimen perubahan breakpoint dari `700` menjadi `500`, penggunaan `Switch.adaptive`, serta penerapan tema terang dan tema gelap pada dashboard.

---

### 6. Pengujian Tampilan pada Layar Berbeda
![Tampilan Lebar](screenshots/Tugas%20mandiri%20sendiri%20lebar.png)
![Tampilan Sempit](screenshots/Tugas%20mandiri%20sendiri%20sempit.png)
> **Penjelasan:** Perbandingan tampilan aplikasi pada layar lebar dan layar sempit untuk memastikan komponen tetap tersusun rapi dan mudah digunakan.

---

## Refleksi
- **Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?**
Imperative mengatur perubahan UI satu per satu secara manual. Declarative cukup menjelaskan tampilan berdasarkan state. Flutter kemudian memperbarui UI sesuai perubahan state tersebut.

- **Kapan `Expanded` membantu dan kapan penggunaannya justru menghasilkan layout error?**
`Expanded` membantu mengisi ruang kosong di dalam `Row` atau `Column`. Widget ini bisa menyebabkan error jika digunakan pada ruang yang ukurannya tidak terbatas.

- **Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?**
Breakpoint membuat tampilan menyesuaikan ukuran layar. Theme membantu pengguna memilih tampilan terang atau gelap yang lebih nyaman.

- **Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?**
Saya mengecek apakah saran AI sesuai dengan tugas. Saya juga mencoba hasilnya pada layar lebar dan sempit lalu menjalankan `flutter analyze`.
