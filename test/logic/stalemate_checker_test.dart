import 'package:flutter_speedcard_app/logic/stalemate_checker.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

GameState baseState({
  required List<PlayingCard> humanHand,
  required List<PlayingCard> cpuHand,
  List<PlayingCard> humanDraw = const [],
  List<PlayingCard> cpuDraw = const [],
  Rank leftRank = Rank.seven,
  Rank rightRank = Rank.nine,
}) {
  return GameState(
    phase: GamePhase.playing,
    difficulty: Difficulty.normal,
    humanHand: humanHand,
    cpuHand: cpuHand,
    humanDrawPile: humanDraw,
    cpuDrawPile: cpuDraw,
    centerLeftPile: [card(Suit.club, leftRank)],
    centerRightPile: [card(Suit.heart, rightRank)],
  );
}

void main() {
  group('hasValidPlay', () {
    test('hand has valid card -> true', () {
      final hand = [card(Suit.spade, Rank.eight)];
      expect(hasValidPlay(hand, Rank.seven, Rank.king), isTrue);
    });

    test('hand has no valid card -> false', () {
      final hand = [card(Suit.spade, Rank.three), card(Suit.heart, Rank.jack)];
      expect(hasValidPlay(hand, Rank.seven, Rank.nine), isFalse);
    });

    test('empty hand -> false', () {
      expect(hasValidPlay([], Rank.seven, Rank.nine), isFalse);
    });
  });

  group('isStalemate', () {
    test('both stuck -> true', () {
      final state = baseState(
        humanHand: [card(Suit.spade, Rank.three)],
        cpuHand: [card(Suit.club, Rank.jack)],
      );
      expect(isStalemate(state), isTrue);
    });

    test('human can play -> false', () {
      final state = baseState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.club, Rank.jack)],
      );
      expect(isStalemate(state), isFalse);
    });

    test('cpu can play -> false', () {
      final state = baseState(
        humanHand: [card(Suit.spade, Rank.three)],
        cpuHand: [card(Suit.club, Rank.eight)],
      );
      expect(isStalemate(state), isFalse);
    });

    test('with various hand sizes (0-4 cards)', () {
      final suits = Suit.values;
      for (var size = 0; size <= 4; size++) {
        final humanHand = List.generate(
          size,
          (i) => card(suits[i], Rank.three),
        );
        final cpuHand = List.generate(size, (i) => card(suits[i], Rank.jack));

        final state = baseState(
          humanHand: humanHand,
          cpuHand: cpuHand,
          humanDraw: [card(Suit.diamond, Rank.ace)],
          cpuDraw: [card(Suit.heart, Rank.ace)],
        );

        expect(isStalemate(state), isTrue, reason: 'size=$size should stall');
      }
    });
  });
}
