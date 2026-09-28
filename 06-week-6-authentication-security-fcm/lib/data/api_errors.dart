import 'dart:io';
import 'package:dio/dio.dart';

/// Kelas helper untuk memetakan error jaringan/API (termasuk DioException)
/// ke pesan yang ramah dan mudah dipahami oleh pengguna di layer UI.
class ApiErrorMapper {
  static String map(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi timeout. Silakan periksa jaringan Anda dan coba lagi.';

        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Sesi Anda telah berakhir atau belum terautentikasi (401). Silakan login kembali.';
          } else if (statusCode == 403) {
            return 'Anda tidak memiliki hak akses untuk layanan ini (403).';
          } else if (statusCode == 404) {
            return 'Layanan atau data yang diminta tidak ditemukan (404).';
          } else if (statusCode != null && statusCode >= 500) {
            return 'Terjadi gangguan pada server internal ($statusCode). Silakan coba lagi nanti.';
          }
          return 'Terjadi kesalahan pada respon server (${error.response?.statusMessage ?? statusCode}).';

        case DioExceptionType.cancel:
          return 'Permintaan ke server telah dibatalkan.';

        case DioExceptionType.badCertificate:
          return 'Sertifikat keamanan server tidak valid.';

        case DioExceptionType.unknown:
        default:
          if (error.error is SocketException) {
            return 'Perangkat Anda sedang offline. Silakan sambungkan ke jaringan internet.';
          }
          return 'Terjadi kesalahan jaringan yang tidak terduga. Silakan coba lagi.';
      }
    }

    if (error is SocketException) {
      return 'Perangkat Anda sedang offline. Silakan aktifkan koneksi internet.';
    }

    return error?.toString().replaceAll('Exception: ', '') ??
        'Terjadi kesalahan tidak terduga.';
  }
}
