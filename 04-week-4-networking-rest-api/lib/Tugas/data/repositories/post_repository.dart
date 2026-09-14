import 'package:dio/dio.dart';
import '../models/post.dart';
import '../api_client.dart';

class PostRepository {
  final ApiClient apiClient;

  PostRepository(this.apiClient);

  Future<List<Post>> fetchPosts({int start = 0, int limit = 10}) async {
    try {
      final response = await apiClient.dio.get(
        '/posts',
        queryParameters: {
          '_start': start,
          '_limit': limit,
        },
      );
      
      final List<dynamic> data = response.data;
      return data.map((json) => Post.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }

  Future<Post> fetchPostDetail(int id) async {
    try {
      final response = await apiClient.dio.get('/posts/$id');
      return Post.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
