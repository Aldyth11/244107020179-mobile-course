import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushService = ref.watch(pushServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notification Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.indigo, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Autentikasi: Terhubung',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Token tersimpan aman di FlutterSecureStorage.',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Aksi Push Notification & Topik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      await pushService.subscribeCampusTopic();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Berhasil subscribe topik: pengumuman-kampus'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    label: const Text('Subscribe Topik'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_off),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await pushService.unsubscribeCampusTopic();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Berhasil unsubscribe topik: pengumuman-kampus'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    label: const Text('Unsubscribe'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Simulasi Rute Notifikasi (/pengumuman/:id)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Klik tombol di bawah untuk menguji navigasi halaman detail pengumuman:',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text('1', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('Pengumuman Kuis UTS'),
                subtitle: const Text('Rute: /pengumuman/1'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go(AppRoutes.announcementDetail('1'));
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Text('2', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('Jadwal Libur Semester'),
                subtitle: const Text('Rute: /pengumuman/2'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go(AppRoutes.announcementDetail('2'));
                },
              ),
            ),

            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              label: const Text('Logout Mahasiswa'),
            ),
          ],
        ),
      ),
    );
  }
}
