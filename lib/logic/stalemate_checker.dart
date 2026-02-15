import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';

/// Checks if a list of hand cards has any valid play on either center pile.
bool hasValidPlay(
  List<PlayingCard> hand,
  Rank leftFieldRank,
  Rank rightFieldRank,
) {
  for (final card in hand) {
    if (isAdjacent(card.rank, leftFieldRank) ||
        isAdjacent(card.rank, rightFieldRank)) {
      return true;
    }
  }
  return false;
}

/// Checks if the game is in stalemate (both players have no valid plays).
/// Must handle hand sizes 0-4. If either hand is empty AND draw pile is empty,
/// that's a win condition, not stalemate.
bool isStalemate(GameState state) {
  if (state.centerLeftPile.isEmpty || state.centerRightPile.isEmpty) {
    return false;
  }

  final humanTotal = state.humanHand.length + state.humanDrawPile.length;
  final cpuTotal = state.cpuHand.length + state.cpuDrawPile.length;
  if (humanTotal == 0 || cpuTotal == 0) {
    return false;
  }

  final leftRank = state.centerLeftPile.last.rank;
  final rightRank = state.centerRightPile.last.rank;

  final humanHasValid = hasValidPlay(state.humanHand, leftRank, rightRank);
  final cpuHasValid = hasValidPlay(state.cpuHand, leftRank, rightRank);

  return !humanHasValid && !cpuHasValid;
}
