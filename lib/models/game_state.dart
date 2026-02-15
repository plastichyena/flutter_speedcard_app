import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart';
import 'cpu_visible_state.dart';
import 'enums.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required GamePhase phase,
    required Difficulty difficulty,
    required List<PlayingCard> humanHand,
    required List<PlayingCard> cpuHand,
    required List<PlayingCard> humanDrawPile,
    required List<PlayingCard> cpuDrawPile,
    required List<PlayingCard> centerLeftPile,
    required List<PlayingCard> centerRightPile,
    int? selectedCardIndex,
    GameResult? result,
    @Default(0) int tickId,
  }) = _GameState;

  factory GameState.initial() => const GameState(
    phase: GamePhase.ready,
    difficulty: Difficulty.normal,
    humanHand: [],
    cpuHand: [],
    humanDrawPile: [],
    cpuDrawPile: [],
    centerLeftPile: [],
    centerRightPile: [],
  );
}

extension GameStateCpuVisibleX on GameState {
  /// Creates a narrow view for CPU logic.
  CpuVisibleState toCpuVisible() {
    if (centerLeftPile.isEmpty || centerRightPile.isEmpty) {
      throw StateError(
        'Cannot build CpuVisibleState when center piles are empty.',
      );
    }

    return CpuVisibleState(
      cpuHand: List<PlayingCard>.from(cpuHand),
      centerLeftFieldCard: centerLeftPile.last,
      centerRightFieldCard: centerRightPile.last,
    );
  }
}
