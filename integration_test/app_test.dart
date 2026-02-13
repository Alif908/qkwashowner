import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qkwashowner/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app integration test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Wait for splash + navigation
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // App should not crash
    expect(find.byType(MyApp), findsOneWidget);
  });
}
