import 'dart:math';

import 'package:flutter_speedcard_app/constants/game_constants.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';

/// Creates an ordered deck of 52 cards.
List<PlayingCard> createDeck() {
  final deck = <PlayingCard>[];
  for (final suit in Suit.values) {
    for (final rank in Rank.values) {
      deck.add(PlayingCard(suit: suit, rank: rank));
    }
  }
  return deck;
}

/// Returns a shuffled copy of the deck. Optional Random for deterministic testing.
List<PlayingCard> shuffleDeck(List<PlayingCard> deck, [Random? random]) {
  final rng = random ?? Random();
  final shuffled = List<PlayingCard>.from(deck);

  for (var i = shuffled.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = tmp;
  }

  return shuffled;
}

/// Checks if two ranks are adjacent (+/-1 with A-K wrapping).
/// A(1) is adjacent to 2 and K(13). Same rank = NOT adjacent.
bool isAdjacent(Rank a, Rank b) {
  if (a == b) {
    return false;
  }

  final diff = (a.value - b.value).abs();
  if (diff == 1) {
    return true;
  }

  return (a == Rank.ace && b == Rank.king) || (a == Rank.king && b == Rank.ace);
}

/// Creates the initial game state from a shuffled deck.
/// Deal order: 4 human hand, 4 cpu hand, 1 centerLeft, 1 centerRight, 21 humanDraw, 21 cpuDraw.
GameState dealInitialState(Difficulty difficulty, [Random? random]) {
  final deck = shuffleDeck(createDeck(), random);

  final humanHand = List<PlayingCard>.from(deck.take(4));
  final cpuHand = List<PlayingCard>.from(deck.skip(4).take(4));
  final centerLeftPile = List<PlayingCard>.from(deck.skip(8).take(1));
  final centerRightPile = List<PlayingCard>.from(deck.skip(9).take(1));
  final humanDrawPile = List<PlayingCard>.from(
    deck.skip(10).take(GameConstants.initialDrawPileSize),
  );
  final cpuDrawPile = List<PlayingCard>.from(
    deck
        .skip(10 + GameConstants.initialDrawPileSize)
        .take(GameConstants.initialDrawPileSize),
  );

  return GameState(
    phase: GamePhase.playing,
    difficulty: difficulty,
    humanHand: humanHand,
    cpuHand: cpuHand,
    humanDrawPile: humanDrawPile,
    cpuDrawPile: cpuDrawPile,
    centerLeftPile: centerLeftPile,
    centerRightPile: centerRightPile,
  );
}
