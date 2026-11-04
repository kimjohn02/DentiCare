import 'package:flutter_test/flutter_test.dart';
import 'package:denticare/main.dart';

void main() {
  testWidgets('DentiCare smoke and navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DentiCareApp());
    await tester.pumpAndSettle();

    // Verify home elements
    expect(find.text('DentiCare'), findsWidgets);
    expect(find.text('Book with ease'), findsOneWidget);
    expect(find.text('Book Now!'), findsOneWidget);

    // Tap 'Book Now' bottom navigation tab
    await tester.tap(find.text('Book Now'));
    await tester.pumpAndSettle();

    // Verify Step 0: Service Selection screen
    expect(find.text('Appointment Information'), findsOneWidget);
    expect(find.text('Select Service'), findsOneWidget);
  });
}
