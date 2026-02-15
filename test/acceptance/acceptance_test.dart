import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/constants/game_constants.dart';
import 'package:flutter_speedcard_app/layouts/desktop_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/mobile_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/tablet_game_layout.dart';
import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/logic/game_engine.dart';
import 'package:flutter_speedcard_app/logic/stalemate_checker.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_event.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/screens/game_screen.dart';
import 'package:flutter_speedcard_app/theme/app_theme.dart';
import 'package:flutter_speedcard_app/widgets/card_widget.dart';
import 'package:flutter_speedcard_app/widgets/center_pile_widget.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

GameState basePlayingState({
  List<PlayingCard>? humanHand,
  List<PlayingCard>? cpuHand,
  List<PlayingCard>? humanDrawPile,
  List<PlayingCard>? cpuDrawPile,
  List<PlayingCard>? centerLeftPile,
  List<PlayingCard>? centerRightPile,
  int? selectedCardIndex,
  GamePhase phase = GamePhase.playing,
  GameResult? result,
}) {
  return GameState(
    phase: phase,
    difficulty: Difficulty.normal,
    humanHand: humanHand ?? [card(Suit.spade, Rank.eight)],
    cpuHand: cpuHand ?? [card(Suit.heart, Rank.five)],
    humanDrawPile: humanDrawPile ?? [card(Suit.club, Rank.ace)],
    cpuDrawPile: cpuDrawPile ?? [card(Suit.diamond, Rank.queen)],
    centerLeftPile: centerLeftPile ?? [card(Suit.club, Rank.seven)],
    centerRightPile: centerRightPile ?? [card(Suit.heart, Rank.nine)],
    selectedCardIndex: selectedCardIndex,
    result: result,
  );
}

Widget gameScreenWithState(GameState state, {ProviderContainer? container}) {
  final scope = container == null
      ? ProviderScope(
          overrides: [
            gameProvider.overrideWith(() => _FixedGameNotifier(state)),
          ],
          child: const MaterialApp(home: GameScreen()),
        )
      : UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: GameScreen()),
        );
  return scope;
}

void main() {
  group('Acceptance Criteria', () {
    test('AC1: game can start and reach completion outcomes', () {
      final started = reduce(
        GameState.initial(),
        const StartGame(Difficulty.normal),
      );
      expect(started.phase, GamePhase.playing);
      expect(started.humanHand, isNotEmpty);
      expect(started.cpuHand, isNotEmpty);

      final humanFinisher = basePlayingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.heart, Rank.three)],
        humanDrawPile: const [],
        cpuDrawPile: [card(Suit.club, Rank.five)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
      );
      final afterHuman = reduce(
        humanFinisher,
        const PlayCard(Player.human, 0, CenterPile.left),
      );
      expect(afterHuman.phase, GamePhase.finished);
      expect(afterHuman.result, GameResult.humanWin);

      final cpuFinisher = basePlayingState(
        humanHand: [card(Suit.spade, Rank.three)],
        cpuHand: [card(Suit.heart, Rank.eight)],
        humanDrawPile: [card(Suit.club, Rank.five)],
        cpuDrawPile: const [],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
      );
      final afterCpu = reduce(
        cpuFinisher,
        const PlayCard(Player.cpu, 0, CenterPile.left),
      );
      expect(afterCpu.phase, GamePhase.finished);
      expect(afterCpu.result, GameResult.cpuWin);
    });

    test('AC2: hand size stays at up to 4 with auto replenishment', () {
      final state = basePlayingState(
        humanHand: [
          card(Suit.spade, Rank.eight),
          card(Suit.spade, Rank.four),
          card(Suit.spade, Rank.five),
          card(Suit.spade, Rank.six),
        ],
        humanDrawPile: [
          card(Suit.diamond, Rank.king),
          card(Suit.diamond, Rank.ace),
        ],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      );

      final afterPlay = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );
      expect(afterPlay.humanHand.length, GameConstants.maxHandSize);
      expect(afterPlay.humanDrawPile.length, 1);

      final afterDrawAttempt = reduce(afterPlay, const DrawCard(Player.human));
      expect(afterDrawAttempt.humanHand.length, GameConstants.maxHandSize);
      expect(afterDrawAttempt.humanDrawPile.length, 1);
    });

    test('AC3: +/-1 rule with A-K wrapping is validated', () {
      expect(isAdjacent(Rank.seven, Rank.eight), isTrue);
      expect(isAdjacent(Rank.seven, Rank.six), isTrue);
      expect(isAdjacent(Rank.ace, Rank.king), isTrue);
      expect(isAdjacent(Rank.king, Rank.ace), isTrue);
      expect(isAdjacent(Rank.seven, Rank.seven), isFalse);
      expect(isAdjacent(Rank.seven, Rank.ten), isFalse);
    });

    test('AC4: stalemate is detected and reset can resume play', () {
      final stalledPlaying = basePlayingState(
        humanHand: [card(Suit.spade, Rank.five)],
        cpuHand: [card(Suit.heart, Rank.jack)],
        humanDrawPile: [card(Suit.club, Rank.six)],
        cpuDrawPile: [card(Suit.diamond, Rank.ten)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.two)],
      );

      expect(isStalemate(stalledPlaying), isTrue);

      final stalledPhase = stalledPlaying.copyWith(phase: GamePhase.stalemate);
      final afterReset = reduce(stalledPhase, const ResetStalemate());
      expect(afterReset.phase, GamePhase.playing);
      expect(afterReset.centerLeftPile.last.rank, Rank.six);
      expect(afterReset.centerRightPile.last.rank, Rank.ten);
    });

    test('AC5: CPU difficulty speed ranges are configured correctly', () {
      final easy = GameConstants.cpuDelayRanges[Difficulty.easy]!;
      final normal = GameConstants.cpuDelayRanges[Difficulty.normal]!;
      final hard = GameConstants.cpuDelayRanges[Difficulty.hard]!;

      expect(easy.minMs, 3000);
      expect(easy.maxMs, 5000);
      expect(normal.minMs, 1000);
      expect(normal.maxMs, 3000);
      expect(hard.minMs, 500);
      expect(hard.maxMs, 1000);
      expect(easy.minMs >= normal.maxMs, isTrue);
      expect(normal.minMs >= hard.maxMs, isTrue);
    });

    test('AC6: same-tick conflicts are resolved with human priority', () {
      final state = basePlayingState(
        humanHand: [card(Suit.spade, Rank.eight), card(Suit.heart, Rank.king)],
        cpuHand: [card(Suit.club, Rank.six), card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.heart, Rank.seven)],
        centerRightPile: [card(Suit.club, Rank.jack)],
      );

      final next = resolveTick(state, const [
        PlayCard(Player.cpu, 0, CenterPile.left),
        PlayCard(Player.human, 0, CenterPile.left),
      ]);

      expect(next.centerLeftPile.last.rank, Rank.eight);
      expect(next.cpuHand.first.rank, Rank.six);
    });

    testWidgets(
      'AC7: breakpoint routing selects mobile/tablet/desktop layouts',
      (WidgetTester tester) async {
        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
        });

        final state = basePlayingState();

        await tester.binding.setSurfaceSize(const Size(500, 900));
        await tester.pumpWidget(gameScreenWithState(state));
        await tester.pump();
        expect(find.byType(MobileGameLayout), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(800, 900));
        await tester.pumpWidget(gameScreenWithState(state));
        await tester.pump();
        expect(find.byType(TabletGameLayout), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(1200, 900));
        await tester.pumpWidget(gameScreenWithState(state));
        await tester.pump();
        expect(find.byType(DesktopGameLayout), findsOneWidget);
      },
    );

    test('AC8: GitHub Pages workflow file exists and uses dynamic base-href', () {
      final workflow = File('.github/workflows/deploy.yml');
      expect(workflow.existsSync(), isTrue);

      final content = workflow.readAsStringSync();
      expect(content, contains('name: Deploy to GitHub Pages'));
      expect(content, contains('flutter test'));
      expect(
        content,
        contains(
          'flutter build web --release --base-href "/\${{ github.event.repository.name }}/"',
        ),
      );
      expect(content, contains('uses: actions/deploy-pages@v4'));
    });

    testWidgets('AC9: selected card highlights valid target pile', (
      WidgetTester tester,
    ) async {
      final state = basePlayingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        selectedCardIndex: 0,
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.two)],
      );

      await tester.pumpWidget(gameScreenWithState(state));
      await tester.pump();

      final highlightFinder = find.byWidgetPredicate((widget) {
        if (widget is! AnimatedContainer) {
          return false;
        }
        final decoration = widget.decoration;
        if (decoration is! BoxDecoration) {
          return false;
        }
        final border = decoration.border;
        return border is Border &&
            border.top.color == AppTheme.validTargetHighlight &&
            border.top.width == 2;
      });

      expect(highlightFinder, findsOneWidget);
    });

    testWidgets('AC10: invalid action shows shake feedback and snackbar', (
      WidgetTester tester,
    ) async {
      final state = basePlayingState(
        humanHand: [card(Suit.spade, Rank.three)],
        selectedCardIndex: 0,
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
      );

      await tester.pumpWidget(gameScreenWithState(state));
      await tester.pump();

      await tester.tap(find.byType(CenterPileWidget).first);
      await tester.pump();

      expect(find.text('Invalid move'), findsOneWidget);

      final shakingCards = tester
          .widgetList<CardWidget>(find.byType(CardWidget))
          .where((widget) => widget.shouldShake);
      expect(shakingCards.length, 1);
    });
  });
}
