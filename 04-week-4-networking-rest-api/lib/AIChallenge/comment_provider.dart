import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_model.dart';
import 'comment_repository.dart';

// Provider untuk CommentRepository agar mudah di-inject atau di-mock untuk testing
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

// Notifier untuk menyimpan dan mengatur postId aktif yang ingin dimuat komentarnya
class SelectedPostIdNotifier extends Notifier<int> {
  @override
  int build() => 1; // Nilai default postId = 1

  // Mengubah postId yang sedang dipilih
  void setPostId(int id) => state = id;
}

final selectedPostIdProvider =
    NotifierProvider<SelectedPostIdNotifier, int>(SelectedPostIdNotifier.new);

// AsyncNotifier yang mengelola state daftar komentar (List<Comment>) secara asinkron
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    // Menonton selectedPostIdProvider dan commentRepositoryProvider.
    // Jika postId berubah, build() akan dipanggil ulang secara otomatis.
    final postId = ref.watch(selectedPostIdProvider);
    final repository = ref.watch(commentRepositoryProvider);

    // Penanganan error otomatis:
    // Setiap exception (seperti DioException) dari repository secara otomatis
    // dikonversi oleh Riverpod menjadi state AsyncError(error, stackTrace).
    return repository.fetchComments(postId);
  }

  // Method untuk me-refresh data komentar secara manual
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final postId = ref.read(selectedPostIdProvider);
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      // Mengeset state ke AsyncError jika terjadi kesalahan
      state = AsyncError(e, st);
    }
  }

  // Helper method untuk mengubah postId dan memicu pemuatan ulang komentar
  void fetchForPost(int postId) {
    ref.read(selectedPostIdProvider.notifier).setPostId(postId);
  }
}

// Provider utama AsyncNotifierProvider untuk komentar
final commentsProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  // Nonaktifkan retry otomatis agar error langsung final dan mudah ditampilkan/diuji
  retry: (retryCount, error) => null,
);

// Fungsi pesan error ramah pengguna (user-friendly error message)
// Menangani secara spesifik: timeout, connection error, 404, dan 500
String commentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      // Kasus Timeout (koneksi, kirim, atau terima data melebihi 10 detik)
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis (Timeout 10 detik). Silakan periksa jaringan dan coba lagi.';

      // Kasus Connection Error (tidak ada akses internet / DNS gagal)
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';

      // Kasus Respons HTTP (404, 500, dll)
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (Error 404).';
        } else if (statusCode == 500) {
          return 'Terjadi gangguan internal pada server (Error 500). Coba lagi nanti.';
        }
        return 'Terjadi kesalahan respons server (Status: $statusCode).';

      default:
        return 'Terjadi gangguan jaringan yang tidak terduga.';
    }
  }
  // Kasus error umum non-Dio
  return 'Terjadi kesalahan sistem: $error';
}
