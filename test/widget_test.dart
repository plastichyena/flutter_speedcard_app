import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_speedcard_app/app.dart';
import 'package:flutter_speedcard_app/l10n/app_strings.dart';
import 'package:flutter_speedcard_app/models/enums.dart';

void main() {
  testWidgets('renders speed card app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SpeedCardApp()));
    expect(
      find.text(AppStrings.get(AppLocale.ja, 'app_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings.get(AppLocale.ja, 'start_game')),
      findsOneWidget,
    );
  });

  testWidgets('language toggle switches title screen to English', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SpeedCardApp()));

    await tester.tap(find.text('EN'));
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.en, 'app_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings.get(AppLocale.en, 'start_game')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.get(AppLocale.ja, 'start_game')), findsNothing);
  });
}
