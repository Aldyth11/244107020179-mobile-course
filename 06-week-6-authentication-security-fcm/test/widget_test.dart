import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_6_authentication_security_fcm/pages/home_page.dart';
import 'package:week_6_authentication_security_fcm/main.dart';
import 'package:week_6_authentication_security_fcm/messaging/push_service.dart';

class FakePushService extends PushService {
  bool isSubscribed = false;

  @override
  Future<void> subscribeCampusTopic() async {
    isSubscribed = true;
  }

  @override
  Future<void> unsubscribeCampusTopic() async {
    isSubscribed = false;
  }
}

void main() {
  testWidgets('Smoke test for Campus Notification App dashboard and buttons', (WidgetTester tester) async {
    final fakePushService = FakePushService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pushServiceProvider.overrideWithValue(fakePushService),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Verifikasi teks dashboard muncul
    expect(find.text('Campus Notification Dashboard'), findsOneWidget);
    expect(find.text('Subscribe Topik Kampus'), findsOneWidget);
    expect(find.text('Unsubscribe Topik Kampus'), findsOneWidget);

    // Uji klik tombol Subscribe
    await tester.tap(find.text('Subscribe Topik Kampus'));
    await tester.pump();
    expect(fakePushService.isSubscribed, isTrue);

    // Uji klik tombol Unsubscribe
    await tester.tap(find.text('Unsubscribe Topik Kampus'));
    await tester.pump();
    expect(fakePushService.isSubscribed, isFalse);
  });
}
