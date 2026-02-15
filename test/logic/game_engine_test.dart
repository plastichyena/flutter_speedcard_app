import 'package:flutter_speedcard_app/logic/game_engine.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_event.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

GameState playingState({
  required List<PlayingCard> humanHand,
  required List<PlayingCard> cpuHand,
  required List<PlayingCard> humanDraw,
  required List<PlayingCard> cpuDraw,
  required List<PlayingCard> leftPile,
  required List<PlayingCard> rightPile,
  GamePhase phase = GamePhase.playing,
  Difficulty difficulty = Difficulty.normal,
  int? selectedCardIndex,
  GameResult? result,
}) {
  return GameState(
    phase: phase,
    difficulty: difficulty,
    humanHand: humanHand,
    cpuHand: cpuHand,
    humanDrawPile: humanDraw,
    cpuDrawPile: cpuDraw,
    centerLeftPile: leftPile,
    centerRightPile: rightPile,
    selectedCardIndex: selectedCardIndex,
    result: result,
  );
}

void main() {
  group('reduce', () {
    test('StartGame creates correct initial state', () {
      final next = reduce(
        GameState.initial(),
        const StartGame(Difficulty.hard),
      );

      expect(next.phase, GamePhase.playing);
      expect(next.difficulty, Difficulty.hard);
      expect(next.humanHand.length, 4);
      expect(next.cpuHand.length, 4);
      expect(next.centerLeftPile.length, 1);
      expect(next.centerRightPile.length, 1);
      expect(next.humanDrawPile.length, 21);
      expect(next.cpuDrawPile.length, 21);
    });

    test('PlayCard with valid card: updates state correctly', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.heart, Rank.jack)],
        humanDraw: [card(Suit.diamond, Rank.three)],
        cpuDraw: [card(Suit.club, Rank.five)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.queen)],
        selectedCardIndex: 0,
      );

      final next = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );

      expect(next.centerLeftPile.last.rank, Rank.eight);
      expect(next.humanHand.length, 1);
      expect(next.humanHand.last.rank, Rank.three);
      expect(next.humanDrawPile, isEmpty);
      expect(next.selectedCardIndex, isNull);
    });

    test('PlayCard with invalid card: no board change, tick advances', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.three)],
        cpuHand: [card(Suit.heart, Rank.jack)],
        humanDraw: [card(Suit.diamond, Rank.four)],
        cpuDraw: [card(Suit.club, Rank.five)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );

      expect(next.humanHand, equals(state.humanHand));
      expect(next.centerLeftPile, equals(state.centerLeftPile));
      expect(next.centerRightPile, equals(state.centerRightPile));
      expect(next.tickId, state.tickId + 1);
    });

    test('PlayCard auto-draws from draw pile', () {
      final state = playingState(
        humanHand: [
          card(Suit.spade, Rank.eight),
          card(Suit.spade, Rank.four),
          card(Suit.spade, Rank.five),
          card(Suit.spade, Rank.six),
        ],
        cpuHand: [card(Suit.heart, Rank.jack)],
        humanDraw: [card(Suit.diamond, Rank.king)],
        cpuDraw: [card(Suit.club, Rank.five)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );

      expect(next.humanHand.length, 4);
      expect(next.humanDrawPile.length, 0);
      expect(next.humanHand.any((c) => c.rank == Rank.king), isTrue);
    });

    test('Win condition: human empties hand and draw pile -> human wins', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.heart, Rank.jack)],
        humanDraw: [],
        cpuDraw: [card(Suit.club, Rank.five)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );

      expect(next.phase, GamePhase.finished);
      expect(next.result, GameResult.humanWin);
    });

    test('Win condition: cpu empties -> cpu wins', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.three)],
        cpuHand: [card(Suit.heart, Rank.eight)],
        humanDraw: [card(Suit.club, Rank.ace)],
        cpuDraw: [],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(
        state,
        const PlayCard(Player.cpu, 0, CenterPile.left),
      );

      expect(next.phase, GamePhase.finished);
      expect(next.result, GameResult.cpuWin);
    });

    test('Win condition: both empty -> draw', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [],
        humanDraw: [],
        cpuDraw: [],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );

      expect(next.phase, GamePhase.finished);
      expect(next.result, GameResult.draw);
    });

    test('ResetStalemate: follows exact spec order', () {
      final state = playingState(
        phase: GamePhase.stalemate,
        humanHand: [],
        cpuHand: [card(Suit.spade, Rank.three)],
        humanDraw: [],
        cpuDraw: [card(Suit.heart, Rank.two)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
      );

      final next = reduce(state, const ResetStalemate());

      expect(next.phase, GamePhase.finished);
      expect(next.result, GameResult.humanWin);
      expect(next.humanDrawPile.length, 0);
      expect(next.cpuDrawPile.length, 1);
      expect(next.centerLeftPile.length, 1);
      expect(next.centerRightPile.length, 1);
    });

    test('RestartGame: returns initial state', () {
      final state = playingState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.heart, Rank.three)],
        humanDraw: [card(Suit.club, Rank.ace)],
        cpuDraw: [card(Suit.club, Rank.king)],
        leftPile: [card(Suit.club, Rank.seven)],
        rightPile: [card(Suit.heart, Rank.nine)],
        phase: GamePhase.finished,
        result: GameResult.humanWin,
      );

      final next = reduce(state, const RestartGame());
      expect(next, equals(GameState.initial()));
    });
  });
}
