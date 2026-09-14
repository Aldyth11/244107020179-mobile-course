import 'package:dio/dio.dart';
import 'comment_model.dart';

class CommentRepository {
  final Dio _dio;

  // Inisialisasi Dio. Jika tidak ada Dio yang di-inject (seperti untuk testing), 
  // akan menggunakan instance default baru.
  CommentRepository({Dio? dio}) : _dio = dio ?? Dio() {
    // Set Base URL dari JSONPlaceholder
    _dio.options.baseUrl = 'https://jsonplaceholder.typicode.com';
    
    // Set timeout koneksi 10 detik sesuai requirements
    _dio.options.connectTimeout = const Duration(seconds: 10); 
    // Set timeout penerimaan data 10 detik
    _dio.options.receiveTimeout = const Duration(seconds: 10); 
  }

  // Method untuk mengambil daftar komentar berdasarkan postId
  Future<List<Comment>> fetchComments(int postId) async {
    try {
      // Memanggil endpoint GET /comments?postId={id}
      final response = await _dio.get(
        '/comments',
        queryParameters: {'postId': postId},
      );

      // Cek apakah response berupa List dan mapping ke list of Comment
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Comment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Format data tidak sesuai ekspektasi (bukan List)");
      }
    } on DioException {
      // Lempar kembali error dari Dio agar bisa ditangkap dan diolah oleh layer Provider
      rethrow;
    } catch (e) {
      throw Exception("Terjadi kesalahan tak terduga: $e");
    }
  }
}
