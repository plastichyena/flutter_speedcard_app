import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/models/cpu_visible_state.dart';
import 'package:flutter_speedcard_app/models/enums.dart';

/// CPU move result.
class CpuAction {
  final int cardIndex;
  final CenterPile targetPile;

  const CpuAction(this.cardIndex, this.targetPile);
}

/// Finds the best CPU move using deterministic strategy.
/// 1. Check centerLeft first, then centerRight
/// 2. For each pile, check hand[0], hand[1], hand[2], hand[3] in order
/// 3. Return first valid move found, or null if no valid move
CpuAction? findCpuMove(CpuVisibleState visibleState) {
  final hand = visibleState.cpuHand;

  final pileChecks = <({CenterPile pile, Rank fieldRank})>[
    (pile: CenterPile.left, fieldRank: visibleState.centerLeftFieldCard.rank),
    (pile: CenterPile.right, fieldRank: visibleState.centerRightFieldCard.rank),
  ];

  for (final check in pileChecks) {
    for (var index = 0; index < hand.length; index++) {
      if (isAdjacent(hand[index].rank, check.fieldRank)) {
        return CpuAction(index, check.pile);
      }
    }
  }

  return null;
}
