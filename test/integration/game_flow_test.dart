import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/app.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/screens/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

GameState stalemateState() {
  return GameState(
    phase: GamePhase.stalemate,
    difficulty: Difficulty.normal,
    humanHand: [card(Suit.spade, Rank.five)],
    cpuHand: [card(Suit.heart, Rank.jack)],
    humanDrawPile: [card(Suit.club, Rank.six)],
    cpuDrawPile: [card(Suit.diamond, Rank.ten)],
    centerLeftPile: [card(Suit.club, Rank.seven)],
    centerRightPile: [card(Suit.heart, Rank.two)],
  );
}

GameState selectionState() {
  return GameState(
    phase: GamePhase.playing,
    difficulty: Difficulty.easy,
    humanHand: [card(Suit.spade, Rank.eight)],
    cpuHand: [card(Suit.heart, Rank.five)],
    humanDrawPile: [card(Suit.club, Rank.ace)],
    cpuDrawPile: [card(Suit.diamond, Rank.queen)],
    centerLeftPile: [card(Suit.club, Rank.seven)],
    centerRightPile: [card(Suit.heart, Rank.king)],
  );
}

void main() {
  testWidgets('full start flow: title to difficulty select to game screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SpeedCardApp()));

    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);

    await tester.tap(find.text('Hard'));
    await tester.pump();

    await tester.tap(find.text('Start Game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Start Game'), findsNothing);
  });

  testWidgets('stalemate reset flow transitions back to active game', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        gameProvider.overrideWith(() => _FixedGameNotifier(stalemateState())),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Stalemate!'), findsOneWidget);

    await tester.tap(find.text('Resume (Reset)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Stalemate!'), findsNothing);
    expect(container.read(gameProvider).phase, GamePhase.playing);
  });

  testWidgets('basic card selection and deselection works', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        gameProvider.overrideWith(() => _FixedGameNotifier(selectionState())),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GameScreen()),
      ),
    );
    await tester.pump();

    expect(container.read(gameProvider).selectedCardIndex, isNull);

    await tester.tap(find.text('8').first);
    await tester.pump();
    expect(container.read(gameProvider).selectedCardIndex, 0);

    await tester.tap(find.text('8').first);
    await tester.pump();
    expect(container.read(gameProvider).selectedCardIndex, isNull);
  });
}
