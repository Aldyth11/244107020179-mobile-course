import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model data statistik sederhana yang merepresentasikan satu item statistik.
class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// StatsNotifier adalah kelas pengelola state turunan AsyncNotifier dari flutter_riverpod.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  final Random _random;
  final Duration _delay;
  final bool? _forceSuccess;

  /// Konstruktor menggunakan initializing formals ('this._delay', 'this._forceSuccess')
  /// untuk memenuhi aturan prefer_initializing_formals pada linter Flutter.
  StatsNotifier({
    Random? random,
    this._delay = const Duration(seconds: 2),
    this._forceSuccess,
  })  : _random = random ?? Random();

  @override
  Future<List<StatItem>> build() async {
    return _fetchStats();
  }

  Future<List<StatItem>> _fetchStats() async {
    await Future.delayed(_delay);

    final isFailure = _forceSuccess != null
        ? !_forceSuccess
        : (_random.nextDouble() < 0.3);

    if (isFailure) {
      throw Exception('Gagal mengambil data statistik (Simulasi kegagalan 30%).');
    }

    return const [
      StatItem(
        title: 'Total Pengguna',
        value: '1,250',
        icon: Icons.people_alt_rounded,
        color: Colors.blue,
      ),
      StatItem(
        title: 'Penjualan Bulanan',
        value: 'Rp 45.000.000',
        icon: Icons.monetization_on_rounded,
        color: Colors.green,
      ),
      StatItem(
        title: 'Tingkat Kepuasan',
        value: '98%',
        icon: Icons.thumb_up_alt_rounded,
        color: Colors.orange,
      ),
    ];
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsNotifierProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(() {
  return StatsNotifier();
});