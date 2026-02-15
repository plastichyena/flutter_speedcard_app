import 'package:flutter/material.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/theme/app_theme.dart';
import 'package:flutter_speedcard_app/widgets/card_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    PlayingCard? card,
    required bool isFaceUp,
    bool isSelected = false,
    bool isDimmed = false,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CardWidget(
              card: card,
              isFaceUp: isFaceUp,
              isSelected: isSelected,
              isDimmed: isDimmed,
              onTap: onTap,
              width: 70,
              height: 100,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders face-up card with rank and suit symbol', (
    WidgetTester tester,
  ) async {
    await pumpCard(
      tester,
      card: const PlayingCard(suit: Suit.spade, rank: Rank.ace),
      isFaceUp: true,
    );

    expect(find.text('A'), findsNWidgets(2));
    expect(find.text('♠'), findsNWidgets(3));
  });

  testWidgets('renders card back without rank and suit text', (
    WidgetTester tester,
  ) async {
    await pumpCard(
      tester,
      card: const PlayingCard(suit: Suit.spade, rank: Rank.ace),
      isFaceUp: false,
    );

    expect(find.text('A'), findsNothing);
    expect(find.text('♠'), findsNothing);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('selected state uses highlight border', (
    WidgetTester tester,
  ) async {
    await pumpCard(
      tester,
      card: const PlayingCard(suit: Suit.heart, rank: Rank.ten),
      isFaceUp: true,
      isSelected: true,
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;

    expect(border.top.color, AppTheme.selectedCardBorder);
    expect(border.top.width, 2);
  });

  testWidgets('dimmed state shows overlay', (WidgetTester tester) async {
    await pumpCard(
      tester,
      card: const PlayingCard(suit: Suit.club, rank: Rank.king),
      isFaceUp: true,
      isDimmed: true,
    );

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! DecoratedBox) {
          return false;
        }
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppTheme.dimmedOverlay;
      }),
      findsOneWidget,
    );
  });

  testWidgets('tap callback fires', (WidgetTester tester) async {
    var tapped = false;
    await pumpCard(
      tester,
      card: const PlayingCard(suit: Suit.diamond, rank: Rank.two),
      isFaceUp: true,
      onTap: () {
        tapped = true;
      },
    );

    await tester.tap(find.byType(CardWidget));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
