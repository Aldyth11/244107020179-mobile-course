import 'dart:convert';
import 'package:dio/dio.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

Future<List<Map<String, dynamic>>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts');
  return rows.map((row) {
    return jsonDecode(row['payload'] as String) as Map<String, dynamic>;
  }).toList();
}

Future<void> refreshPostsInBackground({bool forceOffline = false}) async {
  if (forceOffline) return;

  try {
    final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    final response = await dio.get('/posts');
    if (response.statusCode == 200) {
      final data = response.data as List;
      final db = await openNotesDb();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (var item in data) {
        batch.insert('cached_posts', {
          'id': item['id'],
          'payload': jsonEncode(item),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
    }
  } catch (_) {}
}

Future<List<Map<String, dynamic>>> loadPostsCacheFirst() async {
  final cached = await readCachedPosts();
  try {
    await refreshPostsInBackground();
  } catch (_) {}
  return cached;
}

Future<int> syncNotes(NoteRepository repo, {bool forceOffline = false}) async {
  if (forceOffline) return 0;
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
