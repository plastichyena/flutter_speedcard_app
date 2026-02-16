import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/hand_card_drag_data.dart';
import 'package:flutter_speedcard_app/widgets/card_hand.dart';
import 'package:flutter_speedcard_app/widgets/card_widget.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

Finder _dragFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is LongPressDraggable<HandCardDragData>,
  );
}

Future<void> _pumpHand(WidgetTester tester, CardHand hand) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: hand)),
    ),
  );
  await tester.pump();
}

void main() {
  final cards = <PlayingCard>[
    card(Suit.spade, Rank.eight),
    card(Suit.heart, Rank.king),
  ];

  testWidgets('enableDrag true renders LongPressDraggable for each card', (
    tester,
  ) async {
    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: true,
        tickId: 12,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    expect(_dragFinder(), findsNWidgets(cards.length));
  });

  testWidgets('enableDrag false does not render LongPressDraggable', (
    tester,
  ) async {
    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: false,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    expect(_dragFinder(), findsNothing);
  });

  testWidgets('drag payload contains cardIndex card and tickId', (
    tester,
  ) async {
    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: true,
        tickId: 42,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    final draggableWidgets = tester
        .widgetList<LongPressDraggable<HandCardDragData>>(_dragFinder())
        .toList();

    final payload = draggableWidgets[1].data;
    expect(payload, isNotNull);
    expect(payload!.cardIndex, 1);
    expect(payload.card, cards[1]);
    expect(payload.tickId, 42);
  });

  testWidgets('onDragStarted and onDragEnd fire for drag cancel', (
    tester,
  ) async {
    final started = <int>[];
    var endCount = 0;

    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: true,
        tickId: 5,
        onDragStarted: started.add,
        onDragEnd: () => endCount += 1,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(_dragFinder().at(1)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();

    expect(started, [1]);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(endCount, 1);
  });

  testWidgets('tap still works when drag is enabled', (tester) async {
    final tapped = <int>[];

    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: true,
        tickId: 1,
        onCardTap: tapped.add,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    await tester.tap(find.text('8').first);
    await tester.pump();

    expect(tapped, [0]);
  });

  testWidgets('draggingCardIndex card renders as dimmed', (tester) async {
    await _pumpHand(
      tester,
      CardHand(
        cards: cards,
        isFaceUp: true,
        enableDrag: true,
        tickId: 1,
        draggingCardIndex: 1,
        cardWidth: 70,
        cardHeight: 100,
      ),
    );

    final cardWidgets = tester
        .widgetList<CardWidget>(find.byType(CardWidget))
        .toList();
    expect(cardWidgets[0].isDimmed, isFalse);
    expect(cardWidgets[1].isDimmed, isTrue);
  });
}
