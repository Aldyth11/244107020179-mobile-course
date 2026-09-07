import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_3_navigation_state_management/Challenge/stats_notifier.dart';
import 'package:week_3_navigation_state_management/Challenge/stats_page.dart';

void main() {
  testWidgets('StatsPage menampilkan judul dan item statistik ketika sukses', (WidgetTester tester) async {
    // Rendernya halaman StatsPage dengan ProviderScope dan override forceSuccess: true
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsNotifierProvider.overrideWith(
            () => StatsNotifier(
              delay: Duration.zero,
              forceSuccess: true,
            ),
          ),
        ],
        child: const MaterialApp(
          home: StatsPage(),
        ),
      ),
    );

    // Memproses animasi dan async state
    await tester.pumpAndSettle();

    // Verifikasi widget yang dirender
    expect(find.text('Statistik Aplikasi'), findsOneWidget);
    expect(find.text('Total Pengguna'), findsOneWidget);
    expect(find.text('Penjualan Bulanan'), findsOneWidget);
    expect(find.text('Tingkat Kepuasan'), findsOneWidget);
  });
}
