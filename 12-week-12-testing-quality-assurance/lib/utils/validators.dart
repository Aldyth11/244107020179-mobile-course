export 'package:testing_lab/is_valid_task_title.dart';

/// Validator judul tugas dengan pesan error deskriptif.
/// Mengembalikan null jika valid, atau string pesan kegagalan jika tidak valid.
String? validateTaskTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Judul tugas tidak boleh kosong';
  }
  final trimmed = value.trim();
  if (trimmed.length < 3) {
    return 'Judul tugas minimal 3 karakter';
  }
  if (trimmed.length > 50) {
    return 'Judul tugas maksimal 50 karakter';
  }
  return null;
}
