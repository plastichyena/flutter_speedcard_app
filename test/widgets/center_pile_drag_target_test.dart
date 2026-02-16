import 'package:flutter/material.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/hand_card_drag_data.dart';
import 'package:flutter_speedcard_app/widgets/center_pile_widget.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

const sourceKey = ValueKey<String>('drag-source');
const targetKey = ValueKey<String>('drag-target');

const dragData = HandCardDragData(
  cardIndex: 0,
  card: PlayingCard(suit: Suit.spade, rank: Rank.eight),
  tickId: 10,
);

Future<void> _dragToTarget(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(sourceKey)),
  );
  await gesture.moveBy(const Offset(4, 0));
  await tester.pump();
  await gesture.moveTo(tester.getCenter(find.byKey(targetKey)));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

Widget _buildTargetHarness({
  required bool Function(HandCardDragData data) onWillAccept,
  ValueChanged<HandCardDragData>? onAccept,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Draggable<HandCardDragData>(
              data: dragData,
              feedback: Container(width: 60, height: 60, color: Colors.blue),
              childWhenDragging: const SizedBox(width: 60, height: 60),
              child: Container(
                key: sourceKey,
                width: 60,
                height: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 24),
            CenterPileWidget(
              key: targetKey,
              topCard: card(Suit.club, Rank.seven),
              onTap: onTap,
              onWillAcceptDrag: onWillAccept,
              onAcceptDrag: onAccept,
              cardWidth: 70,
              cardHeight: 100,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('CenterPileWidget accepts valid drag', (tester) async {
    var willAcceptCalls = 0;
    HandCardDragData? accepted;

    await tester.pumpWidget(
      _buildTargetHarness(
        onWillAccept: (data) {
          willAcceptCalls += 1;
          return true;
        },
        onAccept: (data) => accepted = data,
      ),
    );

    await _dragToTarget(tester);

    expect(willAcceptCalls, greaterThan(0));
    expect(accepted, isNotNull);
    expect(accepted!.cardIndex, dragData.cardIndex);
  });

  testWidgets('CenterPileWidget rejects invalid drag', (tester) async {
    var willAcceptCalls = 0;
    var acceptCalls = 0;

    await tester.pumpWidget(
      _buildTargetHarness(
        onWillAccept: (data) {
          willAcceptCalls += 1;
          return false;
        },
        onAccept: (_) => acceptCalls += 1,
      ),
    );

    await _dragToTarget(tester);

    expect(willAcceptCalls, greaterThan(0));
    expect(acceptCalls, 0);
  });

  testWidgets('onAcceptDrag fires when valid drag is dropped', (tester) async {
    var acceptCalls = 0;

    await tester.pumpWidget(
      _buildTargetHarness(
        onWillAccept: (_) => true,
        onAccept: (_) => acceptCalls += 1,
      ),
    );

    await _dragToTarget(tester);

    expect(acceptCalls, 1);
  });

  testWidgets('drag hover activates highlight style', (tester) async {
    await tester.pumpWidget(_buildTargetHarness(onWillAccept: (_) => true));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(sourceKey)),
    );
    await gesture.moveBy(const Offset(4, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(targetKey)));
    await tester.pump();

    final outerAnimatedContainerFinder = find.descendant(
      of: find.byType(CenterPileWidget),
      matching: find.byWidgetPredicate(
        (widget) => widget is AnimatedContainer && widget.padding != null,
      ),
    );
    final animatedContainer = tester.widget<AnimatedContainer>(
      outerAnimatedContainerFinder,
    );
    expect(animatedContainer.padding, const EdgeInsets.all(2));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('tap still works alongside DragTarget', (tester) async {
    var tapCalls = 0;

    await tester.pumpWidget(
      _buildTargetHarness(
        onWillAccept: (_) => true,
        onTap: () => tapCalls += 1,
      ),
    );

    await tester.tap(find.byType(CenterPileWidget));
    await tester.pump();

    expect(tapCalls, 1);
  });
}
