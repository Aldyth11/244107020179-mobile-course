import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_3_navigation_state_management/Challenge/stats_notifier.dart';

void main() {
  group('Unit Test StatsNotifier', () {
    // 1. Pengujian State Sukses (Success State)
    test('StatsNotifier mengembalikan daftar 3 item statistik saat berhasil', () async {
      // Membuat ProviderContainer dengan override StatsNotifier yang diset forceSuccess: true
      // dan delay Duration.zero agar unit test berjalan secara instan dan konsisten.
      final container = ProviderContainer(
        overrides: [
          statsNotifierProvider.overrideWith(
            () => StatsNotifier(
              delay: Duration.zero,
              forceSuccess: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Menjaga listener aktif pada provider
      container.listen(statsNotifierProvider, (previous, next) {});

      // State awal sebelum Future selesai dipastikan AsyncLoading
      expect(
        container.read(statsNotifierProvider),
        const AsyncValue<List<StatItem>>.loading(),
      );

      // Menunggu hingga proses inisialisasi async selesai
      final stats = await container.read(statsNotifierProvider.future);

      // Verifikasi bahwa data yang dikembalikan memiliki tepat 3 item
      expect(stats.length, 3);
      expect(stats[0].title, 'Total Pengguna');
      expect(stats[1].title, 'Penjualan Bulanan');
      expect(stats[2].title, 'Tingkat Kepuasan');

      // Verifikasi tipe state akhir memiliki data (AsyncData)
      expect(container.read(statsNotifierProvider).hasValue, true);
    });

    // 2. Pengujian State Error (Failure State)
    test('StatsNotifier mengembalikan AsyncError saat pengambilan data gagal', () async {
      // Membuat ProviderContainer dengan override StatsNotifier yang diset forceSuccess: false
      final container = ProviderContainer(
        overrides: [
          statsNotifierProvider.overrideWith(
            () => StatsNotifier(
              delay: Duration.zero,
              forceSuccess: false,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Menjaga listener aktif agar provider tidak ter-dispose saat loading
      container.listen(statsNotifierProvider, (previous, next) {}, fireImmediately: true);

      // Memproses event queue agar Future.delayed(Duration.zero) selesai dieksekusi
      await pumpEventQueue();

      // Verifikasi bahwa state saat ini memiliki error (AsyncError)
      final state = container.read(statsNotifierProvider);
      expect(state.hasError, true);
    });

    // 3. Pengujian Fungsi Retry (Mencoba Lagi)
    test('Method retry() berhasil memperbarui state ke AsyncData setelah dipicu', () async {
      final container = ProviderContainer(
        overrides: [
          statsNotifierProvider.overrideWith(
            () => StatsNotifier(
              delay: Duration.zero,
              forceSuccess: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Menjaga listener aktif
      container.listen(statsNotifierProvider, (previous, next) {});

      final notifier = container.read(statsNotifierProvider.notifier);

      // Menunggu build pertama selesai
      await container.read(statsNotifierProvider.future);

      // Panggil method retry()
      await notifier.retry();

      // Verifikasi bahwa state tetap atau berhasil kembali menjadi AsyncData dengan 3 item
      final state = container.read(statsNotifierProvider);
      expect(state.hasValue, true);
      expect(state.value?.length, 3);
    });
  });
}
