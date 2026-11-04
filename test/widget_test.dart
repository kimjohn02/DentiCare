import 'package:flutter_test/flutter_test.dart';
import 'package:denticare/main.dart';

void main() {
  testWidgets('DentiCare smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DentiCareApp());

    // Verify that the title and welcome messages are displayed.
    expect(find.text('DentiCare'), findsWidgets);
    expect(find.text('Our Services'), findsOneWidget);
  });
}
