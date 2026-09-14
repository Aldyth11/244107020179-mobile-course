import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_4_networking_rest_api/Praktikum1-3/data/models/post.dart';
import 'package:week_4_networking_rest_api/Praktikum1-3/data/providers.dart';
import 'package:week_4_networking_rest_api/Praktikum1-3/data/repositories/post_repository.dart';
import 'package:week_4_networking_rest_api/Praktikum1-3/main.dart';

// Fake PostRepository agar widget test tidak melakukan HTTP request sungguhan
class FakePostRepository extends PostRepository {
  FakePostRepository() : super(Dio());

  @override
  Future<List<Post>> fetchPosts() async => [];

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async => [];
}

void main() {
  testWidgets('App renders correctly with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    // Pastikan MaterialApp berhasil di-render
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
