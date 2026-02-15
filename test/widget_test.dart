import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_speedcard_app/app.dart';

void main() {
  testWidgets('renders speed card app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeedCardApp());
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });
}
