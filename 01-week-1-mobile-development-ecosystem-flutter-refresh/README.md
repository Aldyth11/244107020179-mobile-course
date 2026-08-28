# Week 1: Mobile Development Ecosystem & Flutter Refresh

##  Tujuan
1. Memahami ekosistem dan arsitektur pengembangan aplikasi mobile menggunakan Flutter.
2. Menguasai dasar-dasar bahasa Dart (seperti *null safety* dan fungsi dasar).
3. Menerapkan widget dasar Flutter untuk membangun halaman profil mahasiswa.
4. Menerapkan alur kerja *Git and Version Control* yang terstruktur.

---

##  Perbedaan hot reload dan hot restart
* **Hot Reload (`r`):** Menyegarkan tampilan kode secara instan tanpa memulai ulang dari awal.
* **Hot Restart (`R`):** Memulai ulang aplikasi dari awal secara total seperti menutup dan membuka kembali aplikasinya.
---

##  Dokumentasi & Screenshots
### 1. Pengecekan Perangkat Terhubung (`flutter devices`)
![Flutter Devices](screenshots/flutter%20devices.png)
> **Penjelasan:** Untuk memastikan perangkat fisik HP serta emulator/browser desktop terdeteksi dan siap digunakan.

---

### 2. Pengecekan Sistem (`flutter doctor`)
![Flutter Doctor](screenshots/flutter%20doctor.png)
> **Penjelasan:** Proses verifikasi lingkungan pengembangan untuk memastikan seluruh dependensi seperti Flutter SDK dan Android Toolchain sudah terpasang dengan benar.

---

### 3. Eksekusi Logika Pemrograman Dart (`dart run`)
![Dart Execution](screenshots/hasil%20latihan%20mandiri.png)
> **Penjelasan:** Menguji file latihan mandiri Dart (`latihan_mandiri.dart`) yang menerapkan fungsi perhitungan matematika serta penanganan *null safety* pada data string.

---

### 4. Tampilan Antarmuka Aplikasi Flutter (`UI Profil Mahasiswa`)
![Flutter UI App](screenshots/mini%20assignment.png)
> **Penjelasan:** Hasil render UI profil mahasiswa yang menampilkan nama, NIM, serta widget Flutter.

---

### 5. Proses Pembaruan Langsung (`Hot Restart / Hot Reload`)
![Hot Restart Terminal](screenshots/r%20reload%20dan%20R%20restart.png)
> **Penjelasan:** Menjalankan perintah pembaruan instan di terminal menggunakan *Hot Reload* (`r`) untuk menyegarkan tampilan tanpa hilang posisi, atau *Hot Restart* (`R`) untuk memulai ulang aplikasi dari awal secara cepat.
---

##  Refleksi
1. **Kapan native lebih tepat dipilih daripada cross-platform?**
Native lebih tepat dipilih ketika aplikasi membutuhkan performa komputasi tingkat tinggi (seperti game 3D berat) atau integrasi mendalam dengan fitur *hardware* perangkat spesifik. Untuk aplikasi standar, *cross-platform* lebih efisien.

2. **Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**
Di Flutter, tampilan layar (UI) itu otomatis ngikutin data (*state*) yang ada. Jadi kalau datanya berubah, Flutter bakal langsung update bagian pohon widget (*widget tree*) yang kena imbasnya secara instan tanpa perlu kita atur manual satu-satu.

3. **Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?**
Bagi tim, *commit* kecil memudahkan pelacakan letak *bug* atau *error*. Bagi portofolio, riwayat *commit* yang terstruktur mencerminkan alur kerja pengembangan yang profesional dan sistematis.


