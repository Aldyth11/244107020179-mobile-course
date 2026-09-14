import 'package:dio/dio.dart';

String friendlyErrorMessage(dynamic error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.sendTimeout:
        return 'Gagal mengirim data. Periksa koneksi Anda.';
      case DioExceptionType.receiveTimeout:
        return 'Server terlalu lama merespons.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) return 'Data tidak ditemukan (404).';
        if (statusCode == 500) return 'Server sedang bermasalah (500).';
        return 'Terjadi kesalahan server ($statusCode).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet.';
      default:
        return 'Terjadi kesalahan tidak terduga: ${error.message}';
    }
  }
  return error.toString();
}
