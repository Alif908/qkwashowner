import 'package:flutter_test/flutter_test.dart';
import 'package:qkwashowner/main.dart';

void main() {
  testWidgets('App opens test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isTest: true));

    expect(find.text('Test Mode'), findsOneWidget);
  });
}
