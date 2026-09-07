import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stats_notifier.dart';

/// StatsPage adalah ConsumerWidget yang mendengarkan perubahan state dari statsNotifierProvider.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Mengamati (watch) state dari statsNotifierProvider.
    // statsAsync bertipe AsyncValue<List<StatItem>>.
    final statsAsync = ref.watch(statsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aplikasi'),
        centerTitle: true,
        actions: [
          // Tombol refresh manual di AppBar untuk memicu ulang pemuatan data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Memicu method retry() pada StatsNotifier
              ref.read(statsNotifierProvider.notifier).retry();
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      // 2. Menggunakan method .when() dari AsyncValue untuk menangani 3 state utama:
      // data (success), error, dan loading.
      body: statsAsync.when(
        // === STATE SUCCESS (DATA) ===
        // Menampilkan ListView berisi 3 item data statistik ketika pengambilan data berhasil.
        data: (statsList) {
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(statsNotifierProvider.notifier).retry();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: statsList.length,
              itemBuilder: (context, index) {
                final item = statsList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.color.withAlpha(50),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Text(
                      item.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: item.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },

        // === STATE ERROR ===
        // Menampilkan pesan kesalahan dan tombol retry ketika simulasi error terjadi.
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi Kesalahan!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  // Tombol Retry untuk memicu pengambilan data ulang
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(statsNotifierProvider.notifier).retry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi (Retry)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },

        // === STATE LOADING ===
        // Menampilkan spinner (CircularProgressIndicator) saat data sedang dalam proses penundaan 2 detik.
        loading: () {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Mengambil data statistik...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
