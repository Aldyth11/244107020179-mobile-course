import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postListProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Project: Posts'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(friendlyErrorMessage(err)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(postListProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (listState) {
          if (listState.posts.isEmpty) {
            return const Center(child: Text('Tidak ada post tersedia.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(postListProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: listState.posts.length + (listState.hasReachedMax ? 0 : 1),
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                if (index >= listState.posts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final post = listState.posts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${post.id}')),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push('/detail/${post.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
