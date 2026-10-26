import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_10_ai_feature_integration/core/config/env_config.dart';
import 'package:week_10_ai_feature_integration/features/chat/data/services/ai_service.dart';
import 'package:week_10_ai_feature_integration/main.dart';

void main() {
  group('AiService Unit Tests', () {
    late AiService aiService;

    setUp(() {
      aiService = AiService();
    });

    test('PII Sanitization masks sensitive NIK, phone number, and email', () {
      const sampleText =
          'Halo tolong daftarkan NIK 3507041203010002 dengan nomor HP 081234567890 dan email mahasiswa@polinema.ac.id';

      final result = aiService.sanitizePrompt(sampleText);

      expect(result.hasSensitiveData, isTrue);
      expect(result.detectedItems.contains('NIK (16 digit)'), isTrue);
      expect(result.detectedItems.contains('Nomor HP'), isTrue);
      expect(result.detectedItems.contains('Alamat Email'), isTrue);

      expect(result.sanitizedText.contains('3507041203010002'), isFalse);
      expect(result.sanitizedText.contains('[NIK_DISAMARKAN]'), isTrue);
      expect(result.sanitizedText.contains('[NO_HP_DISAMARKAN]'), isTrue);
      expect(result.sanitizedText.contains('[EMAIL_DISAMARKAN]'), isTrue);
    });

    test('Offline fallback returns accurate campus info for known queries',
        () async {
      final scheduleReply =
          await aiService.ask('Jadwal kuliah senin?', forceOffline: true);
      expect(scheduleReply.contains('Siakad Polinema'), isTrue);

      final perpusReply =
          await aiService.ask('Lokasi perpustakaan?', forceOffline: true);
      expect(perpusReply.contains('Graha Polinema'), isTrue);

      final uktReply =
          await aiService.ask('Bagaimana bayar ukt?', forceOffline: true);
      expect(uktReply.contains('Virtual Account'), isTrue);

      final beasiswaReply =
          await aiService.ask('Ada beasiswa apa?', forceOffline: true);
      expect(beasiswaReply.contains('KIP-Kuliah'), isTrue);
    });

    test('Local caching prevents redundant processing for identical queries',
        () async {
      const query = 'Jadwal kuliah senin?';
      final firstReply = await aiService.ask(query, forceOffline: true);
      expect(firstReply.startsWith('[Cached]'), isFalse);

      final secondReply = await aiService.ask(query, forceOffline: true);
      expect(secondReply.startsWith('[Cached]'), isTrue);
      expect(aiService.cacheCount, 1);
    });

    test('Understand image produces OCR description fallback', () async {
      final visionResult = await aiService.understandImage(
        prompt: 'Ekstrak KTM',
        base64Image: 'sample_base64',
      );
      expect(visionResult.contains('Simulasi OCR'), isTrue);
    });
  });

  group('Campus AI Widget Tests', () {
    testWidgets('App renders correctly with title, welcome message, and chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CampusAiApp(),
        ),
      );

      // Verify app bar title
      expect(find.text('CampusBot AI'), findsOneWidget);

      // Verify initial welcome message from assistant
      expect(
        find.textContaining('Halo! Saya CampusBot AI Polinema'),
        findsOneWidget,
      );

      // Verify quick action chips visible on screen
      expect(find.text('Jadwal perkuliahan hari ini?'), findsOneWidget);

      // Verify textfield hint is displayed
      expect(find.text('Tanyakan sesuatu pada CampusBot...'), findsOneWidget);
    });

    testWidgets('Tapping offline mode icon switches status text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CampusAiApp(),
        ),
      );

      // Initial state is online
      expect(find.text(EnvConfig.defaultModel), findsOneWidget);

      // Tap offline toggle button
      final offlineBtn = find.byIcon(Icons.cloud_done);
      expect(offlineBtn, findsOneWidget);
      await tester.tap(offlineBtn);
      await tester.pump();

      // State is now Mode Offline
      expect(find.text('Mode Offline'), findsOneWidget);
    });

    testWidgets('Tapping clear chat resets message state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CampusAiApp(),
        ),
      );

      final clearBtn = find.byIcon(Icons.delete_sweep_outlined);
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pump();

      expect(
        find.textContaining('Riwayat obrolan dibersihkan'),
        findsOneWidget,
      );
    });
  });
}
