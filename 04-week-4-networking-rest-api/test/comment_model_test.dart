import 'package:flutter_test/flutter_test.dart';
import 'package:week_4_networking_rest_api/AIChallenge/comment_model.dart';

void main() {
  group('Comment Model fromJson Tests', () {
    test('Berhasil handle field JSON yang null atau hilang', () {
      // Arrange: Siapkan data simulasi JSON dengan kondisi:
      // 1. postId ada
      // 2. id hilang
      // 3. name diset eksplisit ke null
      // 4. email ada
      // 5. body hilang
      final Map<String, dynamic> incompleteJson = {
        'postId': 1,
        'name': null,
        'email': 'test@example.com',
      };

      // Act: Konversi map JSON di atas menjadi objek Comment
      final comment = Comment.fromJson(incompleteJson);

      // Assert: Pastikan nilai-nilainya diubah menjadi fallback (default value) dengan benar
      expect(comment.postId, 1, reason: 'postId harusnya sesuai nilai asal');
      expect(comment.id, 0, reason: 'id yang hilang harus default ke 0');
      expect(comment.name, '', reason: 'name yang null harus default ke string kosong');
      expect(comment.email, 'test@example.com', reason: 'email harusnya sesuai nilai asal');
      expect(comment.body, '', reason: 'body yang hilang harus default ke string kosong');
    });
  });
}
