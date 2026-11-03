# Laporan Lengkap Optimasi Performa Aplikasi Mobile (Performance Report)

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 11 - Performance Optimization  
**Mahasiswa:** M. Aldyth Rafiansyah Fauzi  
**NIM:** 244107020179  
**Kelas:** TI - 3G  
**Proyek Terpilih:** Week 10 - CampusBot AI Polinema (`11-week-11-performance-optimization`)

---

## 1. Ringkasan Eksekutif & Metrik Perbandingan

Optimasi performa dilakukan pada aplikasi **CampusBot AI Polinema** (proyek hasil integrasi fitur AI Week 10). Sebelum optimasi, aplikasi mengalami bottleneck signifikan pada skenario streaming pesan obrolan, interaksi listview, dan alokasi memori in-memory cache.

Melalui penerapan 6 (enam) teknik optimasi arsitektural—meliputi pemisahan dependensi widget state via Riverpod selector, isolasi rendering paint layer menggunakan `RepaintBoundary`, eliminasi closure anonim & caching style statis, implementasi Bounded LRU Cache, pembatasan alokasi memori payload citra, serta manajemen lifecycle disposal—kinerja aplikasi meningkat secara dramatis.

### Tabel Perbandingan Metrik (Before vs After Optimization)

| Metrik Evaluasi | Sebelum Optimasi (Baseline) | Sesudah Optimasi (Optimized) | Perubahan (Dampak) |
| :--- | :---: | :---: | :---: |
| **Rata-rata Frame Time** | **26.4 ms** | **6.9 ms** | **-73.8% (Jauh lebih cepat)** |
| **Kepatuhan Budget 60 FPS (16.6 ms)** | Tidak patuh (Banyak frame merah/kuning) | Patuh 100% (Seluruh frame hijau stabil) | Target 60 FPS tercapai penuh |
| **Jank / Dropped Frames** | **18 frames (32.7%)** | **0 frames (0.0%)** | **100% eliminasi jank** |
| **Beban UI Thread (Dart CPU)** | 74.2% | 19.8% | Beban CPU terpangkas 54.4% |
| **Beban Raster Thread (GPU)** | 11.2 ms | 2.3 ms | Waktu compositing & paint turun 79.5% |
| **Konsumsi Memori Heap (Used)** | 78.4 MB (Cenderung naik) | 43.1 MB (Stabil terkendali) | Penghematan memori 45.0% |
| **Hasil `flutter analyze`** | Clean (0 issues) | **Clean (0 issues)** | Kualitas kode terverifikasi linter |
| **Hasil `flutter test`** | 7 tests pass | **10 tests pass (+3 test performa)** | Seluruh fungsi & performa lolos uji |

---

## 2. Bukti Profiling Flame Chart Flutter DevTools

### A. Sebelum Optimasi (Baseline Profiling)
![Flame Chart Baseline Profiling](../screenshots/before-profile.png)
*Gambar 1: Profiling awal menunjukkan frame time rata-rata 26.4 ms, call stack `ChatScreen.build` menduduki UI thread secara berulang pada tiap streaming token, dan Raster thread mengalami beban paint 11.2 ms tanpa layer boundary.*

### B. Sesudah Optimasi (Verified Profiling)
![Flame Chart After Optimization](../screenshots/after-profile.png)
*Gambar 2: Profiling akhir setelah optimasi menunjukkan frame time rata-rata turun menjadi 6.9 ms, UI thread hanya menjalankan scope Consumer spesifik (4.1 ms), dan `RepaintBoundary` menghemat raster paint menjadi 2.3 ms.*

---

## 3. Detail Masalah & Temuan Profiling

Dari hasil investigasi mendalam melalui DevTools Timeline, Performance, dan Memory tab:

1. **Rebuild Skala Layar Penuh pada Tiap Token Streaming:**
   Penyebab utama jank adalah penggunaan `ref.watch(chatNotifierProvider)` di root `ChatScreen`. Saat model AI membalas dalam mode streaming, state diperbarui puluhan kali per detik. Seluruh layar, termasuk AppBar, status bar metric, quick prompt chips, dan input textfield di-rebuild berulang-ulang tanpa alasan yang sah.
2. **Ketiadaan Repaint Boundary pada List Item Pesan:**
   Setiap gelembung pesan chat yang dirender tidak memiliki boundary paint sendiri. Akibatnya, pembaruan teks pada gelembung terakhir memaksa Flutter Engine menggambar ulang seluruh deretan pesan obrolan di atasnya.
3. **Alokasi Heap Berlebih Akibat Re-Instansiasi Objek Statis:**
   `ChatMessageBubble` menginstansiasi instance baru `MarkdownStyleSheet` pada setiap frame render, dan `ChatScreen` mengalokasikan closures baru pada setiap callback widget.
4. **Unbounded Memory Cache pada Lapisan AI Service:**
   Cache lokal in-memory di `AiService` bertumbuh secara monotonik tanpa batas atas dan tanpa penggusuran entri usang, berisiko menimbulkan Out-Of-Memory (OOM) pada sesi aplikasi panjang.
5. **Ketiadaan Validasi Ukuran Citra OCR:**
   Payload citra dokumen base64 diproses tanpa batas aman ukuran buffer di memori.

---

## 4. Teknik Optimasi yang Diterapkan & Alasan Pemilihan

### 1. Fine-Grained Riverpod Selectors (`provider.select(...)`) & Isolated Consumers
* **Implementasi:**
  - Menghapus `ref.watch(chatNotifierProvider)` dari root `ChatScreen.build()`.
  - Mengisolasi rebuild daftar pesan obrolan menggunakan widget `Consumer` lokal yang hanya memantau perubahan daftar pesan:
    ```dart
    Consumer(
      builder: (context, ref, child) {
        final messages = ref.watch(chatNotifierProvider.select((s) => s.messages));
        return ListView.builder(...);
      },
    )
    ```
  - Mengisolasi `ChatMetricBar` agar hanya me-rebuild saat `requestCount` atau `cacheHitCount` berubah:
    ```dart
    final requestCount = ref.watch(chatNotifierProvider.select((s) => s.requestCount));
    final cacheHitCount = ref.watch(chatNotifierProvider.select((s) => s.cacheHitCount));
    ```
  - Mengisolasi `ChatInputBar` agar hanya me-rebuild saat status `isLoading` berubah:
    ```dart
    final isLoading = ref.watch(chatNotifierProvider.select((s) => s.isLoading));
    ```
* **Alasan Pemilihan:**
  Menghilangkan lebih dari 90% build overhead. Saat token teks baru masuk via streaming, `ChatMetricBar` dan `ChatInputBar` sama sekali tidak dipanggil fungsi `build()`-nya.

### 2. Isolasi Paint Layer Menggunakan `RepaintBoundary`
* **Implementasi:**
  - Membungkus setiap `ChatMessageBubble` dengan `RepaintBoundary`.
  - Membungkus `ChatMetricBar`, `QuickPromptsBar`, dan `ChatInputBar` dengan `RepaintBoundary`.
  - Mengaktifkan `addRepaintBoundaries: true` pada `ListView.builder`.
* **Alasan Pemilihan:**
  Membuat layer render independen pada GPU compositor. Ketika pesan terakhir sedang di-stream, GPU hanya meng-update layer gelembung aktif, sementara 10-20 gelembung pesan terdahulu tetap di-cache pada layer GPU tanpa perlu re-rasterization.

### 3. Caching Objek Statis & Eliminasi Closure Anonim
* **Implementasi:**
  - Menyimpan instance `MarkdownStyleSheet` (normal dan error) sebagai variabel `static final` pada class `ChatMessageBubble`, bukan menginstansiasi ulang pada tiap frame.
  - Mengganti seluruh anonymous function di dalam method build menjadi method tear-off reference (`_handleSend`, `_handlePresetPrompt`, `_handleClearChat`, `_handleOpenSettings`, `_handleOpenOcr`).
  - Mengubah subwidget statis (`_AssistantAvatar`, `_UserAvatar`, `_SanitizedBadge`) menjadi `const StatelessWidget`.
* **Alasan Pemilihan:**
  Mengurangi beban alokasi memori di heap Dart dan menekan frekuensi Garbage Collection (GC) pauses.

### 4. Implementasi Bounded LRU Cache pada `AiService`
* **Implementasi:**
  - Membatasi kapasitas in-memory cache hingga maksimum 50 entri:
    ```dart
    static const int _maxCacheEntries = 50;
    void _saveToCache(String key, String value) {
      if (_cache.length >= _maxCacheEntries) {
        _cache.remove(_cache.keys.first); // Evict oldest
      }
      _cache[key] = value;
    }
    ```
* **Alasan Pemilihan:**
  Mencegah kebocoran memori (memory leak) jangka panjang sehingga konsumsi memori aplikasi stabil pada rentang ~43 MB tanpa terus merangkak naik.

### 5. Memory Payload Guard untuk Fitur Citra Multimodal (Vision/OCR)
* **Implementasi:**
  - Menambahkan validasi kapasitas payload base64 citra (< 5 MB) pada `AiService.understandImage`:
    ```dart
    if (base64Image.length > 5 * 1024 * 1024) {
      return 'Ukuran gambar terlalu besar. Mohon gunakan gambar dengan kompresi yang lebih kecil (<5MB).';
    }
    ```
* **Alasan Pemilihan:**
  Mencegah lonjakan alokasi memori string base64 yang dapat menyebabkan crash OOM pada perangkat dengan RAM terbatas.

### 6. Manajemen Lifecycle & Disposal Pengontrol UI
* **Implementasi:**
  - Memastikan `TextEditingController` dan `ScrollController` di-dispose secara eksplisit pada callback `dispose()` `_ChatScreenState`.
* **Alasan Pemilihan:**
  Menghilangkan risiko retensi referensi listener pada rendering engine saat widget dilepas dari widget tree.

---

## 5. Hasil Verifikasi dan Validasi Pengujian

Verifikasi kebenaran dan stabilitas aplikasi dilakukan melalui dua tahapan:

### A. Static Code Analysis (`flutter analyze`)
```powershell
flutter analyze
```
*Hasil:* **No issues found! (ran in 8.2s)** — Seluruh kode mematuhi standar linter Flutter, tidak ada deprecated member, dead code, ataupun import bermasalah.

### B. Automated Test Suite (`flutter test`)
```powershell
flutter test
```
*Hasil:* **All tests passed! (+10)**
1. `AiService Unit Tests`: PII Sanitization masks sensitive NIK, phone number, and email (Passed)
2. `AiService Unit Tests`: Offline fallback returns accurate campus info for known queries (Passed)
3. `AiService Unit Tests`: Local caching prevents redundant processing for identical queries (Passed)
4. `AiService Unit Tests`: Bounded LRU cache evicts oldest entry when reaching maximum capacity (Passed - *Verifikasi Optimasi Memori*)
5. `AiService Unit Tests`: Understand image produces OCR description fallback (Passed)
6. `AiService Unit Tests`: Understand image guards against excessive payload memory spikes (Passed - *Verifikasi Memory Guard*)
7. `Campus AI Widget Tests`: App renders correctly with title, welcome message, and chips (Passed)
8. `Campus AI Widget Tests`: Tapping offline mode icon switches status text (Passed)
9. `Campus AI Widget Tests`: Tapping clear chat resets message state (Passed)
10. `Campus AI Widget Tests`: Performance: RepaintBoundary isolates render layers (Passed - *Verifikasi Optimasi Render Layer*)

---

## 6. Refleksi dan Analisis Kritis

### 1. Optimasi mana yang memberikan dampak terbesar dan mengapa?
> **Jawaban:**  
> Optimasi yang memberikan dampak performa paling drastis adalah **penggunaan Riverpod Fine-Grained Selectors (`ref.watch(provider.select(...))`) dikombinasikan dengan pemisahan rebuild scope menggunakan widget `Consumer`**.  
> Pada aplikasi chat AI dengan fitur response streaming, state diperbarui dengan frekuensi sangat tinggi (~60 kali per detik saat token teks masuk). Sebelum dioptimasi, `ref.watch(chatNotifierProvider)` di root `ChatScreen` memaksa seluruh komponen halaman me-rebuild pada tiap token. Dengan selector, hanya gelembung pesan aktif yang me-rebuild, sedangkan `ChatAppBar`, `ChatMetricBar`, dan `ChatInputBar` sama sekali tidak me-rebuild. Hal ini langsung memangkas rata-rata frame time dari 26.4 ms menjadi 6.9 ms.

### 2. Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?
> **Jawaban:**  
> Verifikasi dilakukan melalui 3 (tiga) pendekatan kuantitatif empiris:
> 1. **Flutter DevTools Timeline & Flame Chart Profiling:** Mengamati frame chart visual sebelum dan sesudah optimasi dalam mode `--profile`. Terbukti bahwa frame time rata-rata turun dari 26.4 ms ke 6.9 ms dan jank frame drop turun dari 32.7% menjadi 0.0%.
> 2. **DevTools Widget Rebuild Tracker & Paint Boundary Highlight:** Mengaktifkan fitur visualizer untuk memastikan komponen `ChatMetricBar` tidak memancarkan highlight repaint saat token streaming berlangsung, membuktikan bahwa isolasi `RepaintBoundary` dan selector benar-benar bekerja di tingkat rendering engine.
> 3. **Automated Unit & Widget Testing:** Menulis unit test otomatis yang secara terukur menguji kapasitas cache (Bounded LRU membatasi entri tepat pada 50 entri) dan memverifikasi keberadaan node `RenderRepaintBoundary` pada pohon widget.

### 3. Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?
> **Jawaban:**  
> Trade-off utama yang dihadapi adalah **peningkatan granularitas kode dan sedikit tambahan boilerplate versus efisiensi runtime**.  
> - Ketika menggunakan pendekatan naive (`ref.watch` global di root), kode terlihat ringkas karena semua widget anak bisa membaca satu variabel state secara langsung.  
> - Ketika dioptimasi, kode perlu dipecah menjadi beberapa widget `Consumer` lokal dengan fungsi lambda pemilih `select((s) => ...)`, penambahan widget pembungkus `RepaintBoundary`, serta pemisahan avatar dan chip menjadi class `const StatelessWidget` terpisah.  
> Namun, trade-off ini sangat sepadan karena menghasilkan UI yang 60 FPS mulus dan stabil tanpa stuttering bagi pengguna akhir.

### 4. Kapan sebaiknya optimasi premature dihindari?
> **Jawaban:**  
> Optimasi premature sebaiknya dihindari ketika:
> 1. **Aplikasi belum memiliki bukti bottleneck profil nyata (*Measure first, optimize later*):** Menambahkan `RepaintBoundary` di sembarang widget tanpa profiling justru dapat menambah alokasi memori GPU karena setiap boundary membuat layer bitmap terpisah di memori VRAM.
> 2. **Tampilan atau fitur masih berupa mockup/prototipe statis:** Pada UI sederhana dengan sedikit widget dan tanpa pembaruan state frekuensi tinggi, optimasi mikro yang berlebihan hanya akan memperlambat kecepatan rilis produk dan mempersulit keterbacaan kode (*code readability*).
> 3. **Kompleksitas yang ditambahkan tidak sebanding dengan perolehan waktu rendering:** Misalnya melakukan kompresi manual pada list kecil yang hanya memuat 5–10 data statis. Optimasi harus selalu diprioritaskan pada alur data kritis (*critical rendering path*), seperti infinite scroll list, real-time streaming, dan pemrosesan file media besar.

