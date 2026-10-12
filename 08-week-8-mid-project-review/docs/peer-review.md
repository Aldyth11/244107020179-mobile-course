# Laporan Peer Review Pull Request

## Ringkasan PR
- **Judul PR:** feat(notes): validasi judul kosong + test
- **Branch:** `feat/notes-validation` -> `develop`

## Catatan Review (Simulasi Peer Review)
1. **Temuan Kebenaran (Null / Edge Case):**
   - *Observasi:* `title.trim()` belum mengecek kondisi `null` sebelum diproses.
   - *Dampak:* Berpotensi memicu `NoSuchMethodError` jika input bernilai null.
   - *Usulan:* Gunakan `title?.trim().isEmpty ?? true`.

2. **Temuan Arsitektur:**
   - *Observasi:* Logika validasi ditempatkan langsung pada layer UI (Widget).
   - *Dampak:* Menyulitkan pengujian unit test dan melanggar Clean Architecture.
   - *Usulan:* Buat `ValidateNoteUseCase` di `core/validate.dart` agar bisa di-test tanpa tergantung Widget UI.

3. **Temuan Test & Keterbacaan:**
   - *Observasi:* Pengujian hanya memeriksa string kosong `""`.
   - *Dampak:* Input berisi karakter spasi `"   "` tidak ter-cover.
   - *Usulan:* Tambahkan test case khusus untuk input spasi.

## Keputusan Akhir
- **Status Review:** Approved