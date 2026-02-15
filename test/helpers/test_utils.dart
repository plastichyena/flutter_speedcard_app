import 'dart:math';

import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';

Random seededRandom([int seed = 42]) => Random(seed);

GameState createTestState({
  List<PlayingCard>? humanHand,
  List<PlayingCard>? cpuHand,
  List<PlayingCard>? centerLeftPile,
  List<PlayingCard>? centerRightPile,
  List<PlayingCard>? humanDrawPile,
  List<PlayingCard>? cpuDrawPile,
  GamePhase phase = GamePhase.playing,
  Difficulty difficulty = Difficulty.normal,
  int tickId = 0,
}) {
  return GameState(
    phase: phase,
    difficulty: difficulty,
    humanHand: List<PlayingCard>.from(humanHand ?? const []),
    cpuHand: List<PlayingCard>.from(cpuHand ?? const []),
    humanDrawPile: List<PlayingCard>.from(humanDrawPile ?? const []),
    cpuDrawPile: List<PlayingCard>.from(cpuDrawPile ?? const []),
    centerLeftPile: List<PlayingCard>.from(
      centerLeftPile ?? const [PlayingCard(suit: Suit.club, rank: Rank.seven)],
    ),
    centerRightPile: List<PlayingCard>.from(
      centerRightPile ??
          const [PlayingCard(suit: Suit.heart, rank: Rank.queen)],
    ),
    tickId: tickId,
  );
}
