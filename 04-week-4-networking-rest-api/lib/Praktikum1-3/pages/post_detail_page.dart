import 'package:flutter/material.dart';
import '../data/models/post.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;
  final Post? initialPost;

  const PostDetailPage({super.key, required this.postId, this.initialPost});

  @override
  Widget build(BuildContext context) {
    // Jika data dikirim lewat extra (dari list)
    if (initialPost != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Detail Post #${initialPost!.id}')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                initialPost!.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                initialPost!.body,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Jika dibuka langsung via URL
    return Scaffold(
      appBar: AppBar(title: Text('Detail Post #$postId')),
      body: Center(
        child: Text('Memuat detail untuk Post ID: $postId...'),
      ),
    );
  }
}