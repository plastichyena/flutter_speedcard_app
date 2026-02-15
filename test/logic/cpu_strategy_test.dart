import 'package:flutter_speedcard_app/logic/cpu_strategy.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/cpu_visible_state.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

CpuVisibleState visibleState({
  required List<PlayingCard> hand,
  required Rank leftRank,
  required Rank rightRank,
}) {
  return CpuVisibleState(
    cpuHand: hand,
    centerLeftFieldCard: card(Suit.club, leftRank),
    centerRightFieldCard: card(Suit.heart, rightRank),
  );
}

void main() {
  group('findCpuMove', () {
    test('left pile valid -> returns left pile', () {
      final state = visibleState(
        hand: [card(Suit.spade, Rank.eight)],
        leftRank: Rank.seven,
        rightRank: Rank.king,
      );

      final move = findCpuMove(state);
      expect(move, isNotNull);
      expect(move!.cardIndex, 0);
      expect(move.targetPile, CenterPile.left);
    });

    test('only right pile valid -> returns right pile', () {
      final state = visibleState(
        hand: [card(Suit.spade, Rank.eight)],
        leftRank: Rank.king,
        rightRank: Rank.seven,
      );

      final move = findCpuMove(state);
      expect(move, isNotNull);
      expect(move!.targetPile, CenterPile.right);
    });

    test('no valid move -> returns null', () {
      final state = visibleState(
        hand: [card(Suit.spade, Rank.three), card(Suit.heart, Rank.jack)],
        leftRank: Rank.seven,
        rightRank: Rank.nine,
      );

      expect(findCpuMove(state), isNull);
    });

    test('multiple valid cards -> returns lowest index', () {
      final state = visibleState(
        hand: [
          card(Suit.spade, Rank.eight),
          card(Suit.heart, Rank.six),
          card(Suit.club, Rank.eight),
        ],
        leftRank: Rank.seven,
        rightRank: Rank.queen,
      );

      final move = findCpuMove(state);
      expect(move, isNotNull);
      expect(move!.cardIndex, 0);
      expect(move.targetPile, CenterPile.left);
    });

    test('left-first priority over right', () {
      final state = visibleState(
        hand: [card(Suit.spade, Rank.eight)],
        leftRank: Rank.seven,
        rightRank: Rank.nine,
      );

      final move = findCpuMove(state);
      expect(move, isNotNull);
      expect(move!.targetPile, CenterPile.left);
    });

    test('CPU receives CpuVisibleState, not GameState', () {
      final CpuAction? Function(CpuVisibleState) fn = findCpuMove;
      final state = visibleState(
        hand: [card(Suit.spade, Rank.eight)],
        leftRank: Rank.seven,
        rightRank: Rank.nine,
      );

      expect(fn(state), isNotNull);
    });
  });
}
