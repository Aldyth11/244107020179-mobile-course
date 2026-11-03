# Laporan Temuan Profiling Performa (Performance Findings)

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Optimasi Performa Aplikasi Mobile (Minggu 11)  
**Mahasiswa:** M. Aldyth Rafiansyah Fauzi  
**NIM:** 244107020179  
**Kelas:** TI - 3G  
**Baseline Project:** Week 10 - CampusBot AI Polinema (`10-week-10-ai-feature-integration`)

---

## 1. Ringkasan Eksekutif Baseline Profiling

Sebelum menerapkan optimasi pada project CampusBot AI Polinema, dilakukan profiling komprehensif menggunakan Flutter DevTools pada mode `--profile` di perangkat target dengan skenario uji:
1. Membuka aplikasi chat dan memuat pesan awal (welcome message & chips prompt).
2. Mengirim pertanyaan akademik kompleks dan menerima respons teks streaming beruntun (chunk token masuk setiap ~15 ms).
3. Melakukan fast-scrolling pada riwayat obrolan pesan teks dan Markdown panjang.
4. Membuka dan menutup bottom sheet OCR / Analisis Citra berulang kali (5x).
5. Mengirim pertanyaan identik secara berulang untuk menguji efisiensi caching.

### Metrik Kinerja Awal (Baseline Metrics)
- **Rata-rata Frame Time:** 26.4 ms (jauh di atas batas budget rendering 16.6 ms untuk 60 FPS).
- **Jumlah Frame Bermasalah (Jank):** 18 frame jank dari 55 frame rekaman (~32.7% frame drop).
- **Beban CPU UI Thread (Dart Engine):** Mencapai puncak 74.2% saat respons streaming berlangsung.
- **Beban Raster Thread (GPU Engine):** 11.2 ms per frame akibat repainting seluruh tree pesan.
- **Konsumsi Memori Heap (Dart + Native):** 78.4 MB dengan tren meningkat akibat cache memory unbounded.

Bukti visual Flame Chart awal tersimpan pada: [`screenshots/before-profile.png`](../screenshots/before-profile.png).

---

## 2. Identifikasi Masalah & Analisis Bottleneck

Berdasarkan analisis visual Flame Chart dan Timeline Events pada DevTools, diidentifikasi 5 (lima) masalah utama:

### Masalah 1: Widget Rebuild Berlebih pada Root Screen (`ChatScreen`)
* **Lokasi Kode:** `lib/features/chat/presentation/screens/chat_screen.dart`
* **Gejala Profiling:**
  Pada Flame Chart UI Thread, fungsi `ChatScreen.build` menduduki call stack dengan durasi hingga 23.4 ms. Seluruh subtree widget di bawah `ChatScreen` ikut dieksekusi ulang secara repetitif.
* **Penyebab Akar (Root Cause):**
  `ChatScreen` menggunakan `ref.watch(chatNotifierProvider)` langsung pada tingkat root `build()`. Ketika asisten AI melakukan streaming teks (`_streamResponse`), notifier meng-update state pesan setiap beberapa kata (~15 ms). Akibatnya, seluruh widget anak—termasuk `ChatAppBar`, `ChatMetricBar`, `QuickPromptsBar`, dan `ChatInputBar`—ikut me-rebuild puluhan kali per detik, padahal input bar dan metric bar tidak berubah teks pesannya.

### Masalah 2: Ketiadaan Isolasi Paint Layer (`RepaintBoundary`) pada Pesan Obrolan
* **Lokasi Kode:** `lib/features/chat/presentation/widgets/chat_message_bubble.dart`
* **Gejala Profiling:**
  Pada Flame Chart Raster Thread, proses `Rasterize LayerTree` memakan waktu 11.2 ms. Event `Paint` memicu render ulang untuk seluruh item di `ListView`.
* **Penyebab Akar (Root Cause):**
  Tanpa `RepaintBoundary`, setiap kali gelembung chat terakhir (streaming) menambah teks baru, seluruh render object gelembung pesan sebelumnya (pesan user dan pesan history) ikut digambar ulang (repainted) oleh Flutter GPU engine. Hal ini membuang siklus GPU dan menyebabkan frame drop nyata.

### Masalah 3: Alokasi Memori dan Objek Berulang pada Setiap Frame (`MarkdownStyleSheet` & Closures)
* **Lokasi Kode:**
  - `lib/features/chat/presentation/widgets/chat_message_bubble.dart`
  - `lib/features/chat/presentation/screens/chat_screen.dart`
* **Gejala Profiling:**
  Aktivitas Garbage Collection (GC) sering terjadi pada timeline (banyak event GC kecil) dan alokasi memori heap berfluktuasi naik.
* **Penyebab Akar (Root Cause):**
  1. `ChatMessageBubble` membuat instance baru `MarkdownStyleSheet(...)` dan sejumlah `TextStyle` baru di dalam method `build()` setiap kali frame dirender.
  2. `ChatScreen.build` mengoper anonymous lambda function closure baru (`() => _handleSend(...)`, `() => SettingsDialog.show(context)`, dll.) ke widget anak pada tiap build cycle.

### Masalah 4: Unbounded In-Memory Cache pada `AiService` (Potensi Memory Leak)
* **Lokasi Kode:** `lib/features/chat/data/services/ai_service.dart`
* **Gejala Profiling:**
  Ukuran heap snapshot naik terus seiring bertambahnya sesi pertanyaan pengguna dan tidak pernah turun kembali ke baseline awal.
* **Penyebab Akar (Root Cause):**
  Variabel `final Map<String, String> _cache = {};` menampung semua pertanyaan dan respons secara permanen tanpa adanya mekanisme pembatasan kapasitas (size limit) maupun kebijakan penggusuran entri usang (eviction policy seperti LRU). Jika pengguna menggunakan aplikasi dalam waktu lama, cache ini akan terus membesar dan memicu OOM (*Out of Memory*).

### Masalah 5: Ketiadaan Memory Guard pada Payload Citra Multimodal (Vision/OCR)
* **Lokasi Kode:** `lib/features/chat/data/services/ai_service.dart`
* **Gejala Profiling:**
  Lonjakan tajam alokasi heap Dart saat modal analisis citra memproses dokumen KTM atau bukti pembayaran UKT.
* **Penyebab Akar (Root Cause):**
  String base64 citra dokumen resolusi tinggi langsung dienkapsulasi ke JSON payload tanpa batasan memori atau validasi kapasitas. Ini berisiko membebani UI thread saat string parsing dan serialisasi JSON.

---

## 3. Rencana Tindakan Perbaikan (Action Plan)

| Masalah | Solusi Optimasi Terpilih | Target Metrik |
| :--- | :--- | :--- |
| Rebuild berlebih di `ChatScreen` | Terapkan Riverpod fine-grained selector `ref.watch(provider.select(...))` dan pisahkan rebuild scope dengan `Consumer` lokal. | Frame time < 10 ms, rebuild isolatif hanya pada active bubble. |
| Re-paint seluruh list chat | Bungkus `ChatMessageBubble`, `ChatMetricBar`, dan `ChatInputBar` dengan `RepaintBoundary`. | Raster paint time < 4 ms. |
| Re-alokasi objek berulang | Buat `MarkdownStyleSheet` statis/konstan dan ubah closure anonim menjadi method tear-off. | GC event berkurang drastis, alokasi heap stabil. |
| Unbounded in-memory cache | Terapkan Bounded LRU Cache (maksimal 50 entri) dengan penggusuran FIFO/LRU otomatis. | Ukuran heap memori stabil pada rentang ~40-45 MB. |
| Memory risk payload citra | Tambahkan memory guard validation (< 5 MB payload limit) sebelum pemrosesan base64. | Mencegah lonjakan heap tak terduga. |

