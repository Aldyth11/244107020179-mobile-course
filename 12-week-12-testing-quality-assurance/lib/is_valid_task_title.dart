/// Memeriksa apakah judul tugas valid.
/// Judul tugas dianggap valid jika tidak kosong setelah spasi di awal dan akhir diabaikan.
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}

