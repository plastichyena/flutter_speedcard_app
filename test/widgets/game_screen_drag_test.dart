import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/models/hand_card_drag_data.dart';
import 'package:flutter_speedcard_app/providers/cpu_timer_provider.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/screens/game_screen.dart';
import 'package:flutter_speedcard_app/widgets/card_hand.dart';
import 'package:flutter_speedcard_app/widgets/center_pile_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_utils.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

class _AlwaysAcceptDropGameNotifier extends _FixedGameNotifier {
  _AlwaysAcceptDropGameNotifier(super.state);

  @override
  bool canPlayCardAtIndexOnPile(int cardIndex, CenterPile targetPile) => true;
}

class _FakeCpuTimerNotifier extends CpuTimerNotifier {
  @override
  void build() {}

  @override
  void scheduleCpuAction(Difficulty difficulty) {}

  @override
  void cancelTimer() {}
}

ProviderContainer _createContainer(
  GameState state, {
  bool alwaysAcceptDrop = false,
}) {
  return ProviderContainer(
    overrides: [
      gameProvider.overrideWith(
        () => alwaysAcceptDrop
            ? _AlwaysAcceptDropGameNotifier(state)
            : _FixedGameNotifier(state),
      ),
      cpuTimerProvider.overrideWith(_FakeCpuTimerNotifier.new),
    ],
  );
}

Finder _dragFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is LongPressDraggable<HandCardDragData>,
  );
}

Future<TestGesture> _startHandDrag(WidgetTester tester, {int index = 0}) async {
  final gesture = await tester.startGesture(
    tester.getCenter(_dragFinder().at(index)),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await gesture.moveBy(const Offset(0, -20));
  await tester.pump();
  return gesture;
}

Future<void> _dropOnLeftPile(WidgetTester tester, TestGesture gesture) async {
  await gesture.moveTo(tester.getCenter(find.byType(CenterPileWidget).first));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('drag to valid center pile updates game state', (tester) async {
    final container = _createContainer(
      createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        humanDrawPile: [card(Suit.diamond, Rank.ace)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    final gesture = await _startHandDrag(tester);
    await _dropOnLeftPile(tester, gesture);

    final next = container.read(gameProvider);
    expect(next.centerLeftPile.last.rank, Rank.eight);
    expect(next.humanHand, [card(Suit.diamond, Rank.ace)]);
  });

  testWidgets('drag to invalid center pile shows error feedback', (
    tester,
  ) async {
    final container = _createContainer(
      createTestState(
        humanHand: [card(Suit.spade, Rank.three)],
        humanDrawPile: [card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      ),
      alwaysAcceptDrop: true,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    final gesture = await _startHandDrag(tester);
    await _dropOnLeftPile(tester, gesture);

    final next = container.read(gameProvider);
    expect(find.text('Invalid move'), findsOneWidget);
    expect(next.centerLeftPile.last.rank, Rank.seven);
    expect(next.humanHand, [card(Suit.spade, Rank.three)]);
    expect(next.tickId, 1);
  });

  testWidgets('drag to invalid center pile is rejected by default', (
    tester,
  ) async {
    final container = _createContainer(
      createTestState(
        humanHand: [card(Suit.spade, Rank.three)],
        humanDrawPile: [card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    final gesture = await _startHandDrag(tester);
    await _dropOnLeftPile(tester, gesture);

    final next = container.read(gameProvider);
    expect(next.centerLeftPile.last.rank, Rank.seven);
    expect(next.humanHand, [card(Suit.spade, Rank.three)]);
    expect(next.tickId, 0);
  });

  testWidgets('stale drop with mismatched tickId is ignored', (tester) async {
    final container = _createContainer(
      createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        humanDrawPile: [card(Suit.diamond, Rank.ace)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
        tickId: 0,
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    final gesture = await _startHandDrag(tester);

    container.read(gameProvider.notifier).playCardAtIndex(0, CenterPile.right);
    await tester.pump();

    await _dropOnLeftPile(tester, gesture);

    final next = container.read(gameProvider);
    expect(next.tickId, 1);
    expect(next.centerLeftPile.last.rank, Rank.seven);
    expect(next.humanHand, [card(Suit.spade, Rank.eight)]);
    expect(find.text('Invalid move'), findsNothing);
  });

  testWidgets('draggingCardIndex is set on drag start and cleared on end', (
    tester,
  ) async {
    final container = _createContainer(
      createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    expect(
      tester.widgetList<CardHand>(find.byType(CardHand)).last.draggingCardIndex,
      isNull,
    );

    final gesture = await _startHandDrag(tester);
    expect(
      tester.widgetList<CardHand>(find.byType(CardHand)).last.draggingCardIndex,
      0,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      tester.widgetList<CardHand>(find.byType(CardHand)).last.draggingCardIndex,
      isNull,
    );
  });

  testWidgets('drag is disabled during non-playing phase', (tester) async {
    final container = _createContainer(
      createTestState(
        phase: GamePhase.ready,
        humanHand: [card(Suit.spade, Rank.eight)],
      ),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    expect(_dragFinder(), findsNothing);
  });
}
