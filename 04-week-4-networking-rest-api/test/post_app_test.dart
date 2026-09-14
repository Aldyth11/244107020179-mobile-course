import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_4_networking_rest_api/Tugas/data/models/post.dart';
import 'package:week_4_networking_rest_api/Tugas/data/providers.dart';
import 'package:week_4_networking_rest_api/Tugas/data/repositories/post_repository.dart';
import 'package:week_4_networking_rest_api/Tugas/data/api_client.dart';

// Mock Repository
class FakePostRepository implements PostRepository {
  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<Post>> fetchPosts({int start = 0, int limit = 10}) async {
    return [
      Post(id: 1, userId: 1, title: 'Fake Title', body: 'Fake Body'),
    ];
  }

  @override
  Future<Post> fetchPostDetail(int id) async {
    return Post(id: id, userId: 1, title: 'Detail Title', body: 'Detail Body');
  }
}

void main() {
  group('Unit Test: Post Model', () {
    test('fromJson should handle null fields gracefully', () {
      final json = {'id': 1}; 
      final post = Post.fromJson(json);

      expect(post.id, 1);
      expect(post.title, '');
      expect(post.body, '');
      expect(post.userId, 0);
    });
  });

  group('Provider Test: Post List Provider', () {
    test('should return list of posts from FakePostRepository', () async {
      final container = ProviderContainer(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
      );

      addTearDown(container.dispose);

      // Listen to provider
      final state = await container.read(postListProvider.future);
      
      expect(state.posts.length, 1);
      expect(state.posts.first.title, 'Fake Title');
      expect(state.hasReachedMax, true);
    });
  });
}
