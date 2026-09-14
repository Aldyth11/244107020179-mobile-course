import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'data/models/post.dart';
import 'pages/post_detail_page.dart';

// Definisikan GoRouter di sini
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PagedPostPage(),
    ),
    // Rute detail post sesuai tantangan
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final post = state.extra as Post?;
        return PostDetailPage(postId: id, initialPost: post);
      },
    ),
  ],
);

void main() {
  runApp(
    // Wajib dibungkus ProviderScope untuk Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan MaterialApp.router agar GoRouter berfungsi
    return MaterialApp.router(
      title: 'Praktikum API',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}