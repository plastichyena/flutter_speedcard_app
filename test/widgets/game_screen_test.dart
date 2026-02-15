import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

GameState testState({required GamePhase phase, GameResult? result}) {
  return GameState(
    phase: phase,
    difficulty: Difficulty.normal,
    humanHand: [card(Suit.spade, Rank.eight)],
    cpuHand: [card(Suit.heart, Rank.five)],
    humanDrawPile: [card(Suit.club, Rank.ace)],
    cpuDrawPile: [card(Suit.diamond, Rank.queen)],
    centerLeftPile: [card(Suit.club, Rank.seven)],
    centerRightPile: [card(Suit.heart, Rank.nine)],
    result: result,
  );
}

Widget buildGameScreen([GameState? overrideState, Key? key]) {
  return ProviderScope(
    key: key,
    overrides: overrideState == null
        ? const []
        : [gameProvider.overrideWith(() => _FixedGameNotifier(overrideState))],
    child: const MaterialApp(home: GameScreen()),
  );
}

void main() {
  testWidgets('game screen renders without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildGameScreen());
    await tester.pump();

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stalemate overlay is shown at stalemate phase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildGameScreen(testState(phase: GamePhase.stalemate)),
    );
    await tester.pump();

    expect(find.text('Stalemate!'), findsOneWidget);
    expect(find.text('Resume (Reset)'), findsOneWidget);
  });

  testWidgets('finished overlay is shown at finished phase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.humanWin),
      ),
    );
    await tester.pump();

    expect(find.text('You Win!'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('result text shows win message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.humanWin),
        const ValueKey<String>('result-win'),
      ),
    );
    await tester.pump();

    expect(find.text('You Win!'), findsOneWidget);
  });

  testWidgets('result text shows lose message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.cpuWin),
        const ValueKey<String>('result-lose'),
      ),
    );
    await tester.pump();

    expect(find.text('You Lose!'), findsOneWidget);
  });

  testWidgets('result text shows draw message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.draw),
        const ValueKey<String>('result-draw'),
      ),
    );
    await tester.pump();

    expect(find.text('Draw!'), findsOneWidget);
  });
}
