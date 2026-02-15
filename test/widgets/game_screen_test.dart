import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/l10n/app_strings.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/providers/locale_provider.dart';
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

Widget buildGameScreen([
  GameState? overrideState,
  Key? key,
  AppLocale? localeOverride,
]) {
  final overrides = <Override>[];
  if (overrideState != null) {
    overrides.add(
      gameProvider.overrideWith(() => _FixedGameNotifier(overrideState)),
    );
  }
  if (localeOverride != null) {
    overrides.add(localeProvider.overrideWith((ref) => localeOverride));
  }

  return ProviderScope(
    key: key,
    overrides: overrides,
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
    expect(
      find.text(AppStrings.get(AppLocale.ja, 'phase_ready')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('stalemate overlay is shown at stalemate phase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildGameScreen(testState(phase: GamePhase.stalemate)),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.ja, 'stalemate_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings.get(AppLocale.ja, 'stalemate_button')),
      findsOneWidget,
    );
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

    expect(
      find.text(AppStrings.get(AppLocale.ja, 'result_human_win')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.get(AppLocale.ja, 'restart')), findsOneWidget);
  });

  testWidgets('result text shows win message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.humanWin),
        const ValueKey<String>('result-win'),
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.ja, 'result_human_win')),
      findsOneWidget,
    );
  });

  testWidgets('result text shows lose message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.cpuWin),
        const ValueKey<String>('result-lose'),
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.ja, 'result_cpu_win')),
      findsOneWidget,
    );
  });

  testWidgets('result text shows draw message', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.draw),
        const ValueKey<String>('result-draw'),
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.ja, 'result_draw')),
      findsOneWidget,
    );
  });

  testWidgets('stalemate overlay uses English locale when selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.stalemate),
        const ValueKey<String>('stalemate-en'),
        AppLocale.en,
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.en, 'stalemate_title')),
      findsOneWidget,
    );
    expect(
      find.text(AppStrings.get(AppLocale.en, 'stalemate_button')),
      findsOneWidget,
    );
  });

  testWidgets('finished overlay uses English locale when selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildGameScreen(
        testState(phase: GamePhase.finished, result: GameResult.cpuWin),
        const ValueKey<String>('finished-en'),
        AppLocale.en,
      ),
    );
    await tester.pump();

    expect(
      find.text(AppStrings.get(AppLocale.en, 'result_cpu_win')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.get(AppLocale.en, 'restart')), findsOneWidget);
  });
}
