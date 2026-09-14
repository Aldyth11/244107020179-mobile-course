import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Repository Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostRepository(apiClient);
});

// Post List State
class PostListState {
  final List<Post> posts;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  PostListState({
    this.posts = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  PostListState copyWith({
    List<Post>? posts,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }
}

// AsyncNotifier for Pagination
class PostListNotifier extends AsyncNotifier<PostListState> {
  static const int _limit = 10;

  @override
  FutureOr<PostListState> build() async {
    final repository = ref.read(postRepositoryProvider);
    final posts = await repository.fetchPosts(start: 0, limit: _limit);
    return PostListState(posts: posts, hasReachedMax: posts.length < _limit);
  }

  Future<void> fetchMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(postRepositoryProvider);
      final newPosts = await repository.fetchPosts(
        start: currentState.posts.length,
        limit: _limit,
      );

      state = AsyncData(
        currentState.copyWith(
          posts: [...currentState.posts, ...newPosts],
          isLoadingMore: false,
          hasReachedMax: newPosts.length < _limit,
        ),
      );
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(postRepositoryProvider);
      final posts = await repository.fetchPosts(start: 0, limit: _limit);
      return PostListState(posts: posts, hasReachedMax: posts.length < _limit);
    });
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, PostListState>(() {
  return PostListNotifier();
});

// Post Detail Provider
final postDetailProvider =
    FutureProvider.family<Post, int>((ref, id) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPostDetail(id);
});
