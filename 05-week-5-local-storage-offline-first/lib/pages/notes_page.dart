import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repository.dart';
import '../widgets/note_tile.dart';
import '../providers/theme_provider.dart';
import '../data/prefs.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String? _lastOpened;

  @override
  void initState() {
    super.initState();
    _loadLastOpened();
  }

  Future<void> _loadLastOpened() async {
    final prefs = PrefsRepository();
    final last = await prefs.getLastOpened();
    setState(() {
      _lastOpened = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final repo = ref.read(noteRepositoryProvider);
              await syncNotes(repo);
              if (!context.mounted) return;
              ref.invalidate(notesProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync completed!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastOpened != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.blue.withValues(alpha: 0.1),
              width: double.infinity,
              child: Text(
                'Terakhir dibuka: $_lastOpened',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: notesAsync.when(
              data: (notes) => ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) => NoteTile(
                  note: notes[index],
                  onTap: () => context.push('/note/${notes[index].id}'),
                  onDelete: () async {
                    await ref.read(noteRepositoryProvider).deleteNote(notes[index].id!);
                    ref.invalidate(notesProvider);
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(noteRepositoryProvider).addNote(
                title: 'Catatan Baru ${DateTime.now().second}',
                body: 'Isi catatan offline-first',
              );
          ref.invalidate(notesProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
