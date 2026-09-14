import 'package:dio/dio.dart';

String friendlyErrorMessage(Object? error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Waktu koneksi habis. Periksa sambungan internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data tidak ditemukan (Error 404).';
        } else if (statusCode == 500) {
          return 'Terjadi gangguan pada server (Error 500).';
        }
        return 'Terjadi kesalahan pada server (Kode: $statusCode).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Terjadi kesalahan jaringan yang tidak diketahui.';
    }
  }
  return 'Terjadi kesalahan: $error';
}