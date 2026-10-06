import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_7_clean_architecture/main.dart';

void main() {
  testWidgets('Clean Architecture app smoke test', (WidgetTester tester) async {
    // Render MyApp yang sudah terbungkus ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verifikasi widget MyApp berhasil di-mount tanpa error
    expect(find.byType(MyApp), findsOneWidget);
  });
}