import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../data/network_errors.dart';

class PostDetailPage extends ConsumerWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(friendlyErrorMessage(err)),
            ],
          ),
        ),
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'By User ID: ${post.userId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 32),
              Text(
                post.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
