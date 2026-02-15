import 'dart:math';

import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createDeck', () {
    test('produces 52 unique cards', () {
      final deck = createDeck();
      final unique = deck.map((c) => '${c.suit.name}-${c.rank.name}').toSet();

      expect(deck.length, 52);
      expect(unique.length, 52);
    });
  });

  group('shuffleDeck', () {
    test('with seeded Random produces deterministic result', () {
      final deck = createDeck();

      final shuffledA = shuffleDeck(deck, Random(42));
      final shuffledB = shuffleDeck(deck, Random(42));

      expect(shuffledA, equals(shuffledB));
    });

    test('does not modify original list', () {
      final deck = createDeck();
      final snapshot = List.of(deck);

      shuffleDeck(deck, Random(42));

      expect(deck, equals(snapshot));
    });
  });

  group('isAdjacent', () {
    test('normal cases', () {
      expect(isAdjacent(Rank.seven, Rank.eight), isTrue);
      expect(isAdjacent(Rank.seven, Rank.six), isTrue);
      expect(isAdjacent(Rank.seven, Rank.nine), isFalse);
      expect(isAdjacent(Rank.seven, Rank.seven), isFalse);
    });

    test('A-K wrapping', () {
      expect(isAdjacent(Rank.ace, Rank.king), isTrue);
      expect(isAdjacent(Rank.ace, Rank.two), isTrue);
      expect(isAdjacent(Rank.king, Rank.queen), isTrue);
    });

    test('same rank is false', () {
      expect(isAdjacent(Rank.seven, Rank.seven), isFalse);
    });
  });

  group('dealInitialState', () {
    test('correct counts (4+4+1+1+21+21 = 52)', () {
      final state = dealInitialState(Difficulty.normal, Random(1));

      expect(state.humanHand.length, 4);
      expect(state.cpuHand.length, 4);
      expect(state.centerLeftPile.length, 1);
      expect(state.centerRightPile.length, 1);
      expect(state.humanDrawPile.length, 21);
      expect(state.cpuDrawPile.length, 21);

      final total =
          state.humanHand.length +
          state.cpuHand.length +
          state.centerLeftPile.length +
          state.centerRightPile.length +
          state.humanDrawPile.length +
          state.cpuDrawPile.length;
      expect(total, 52);
    });

    test('phase is playing and difficulty is set', () {
      final state = dealInitialState(Difficulty.hard, Random(7));

      expect(state.phase, GamePhase.playing);
      expect(state.difficulty, Difficulty.hard);
    });
  });
}
