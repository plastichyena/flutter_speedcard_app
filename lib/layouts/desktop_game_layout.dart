import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/hand_card_drag_data.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/theme/app_theme.dart';
import 'package:flutter_speedcard_app/widgets/card_hand.dart';
import 'package:flutter_speedcard_app/widgets/center_pile_widget.dart';
import 'package:flutter_speedcard_app/widgets/draw_pile_indicator.dart';
import 'package:flutter_speedcard_app/widgets/game_phase_indicator.dart';

class DesktopGameLayout extends ConsumerWidget {
  const DesktopGameLayout({
    super.key,
    required this.locale,
    required this.cpuDrawLabel,
    required this.yourDrawLabel,
    this.cpuAnimatingPile,
    required this.onCenterPileTap,
    this.humanHandKey,
    this.humanDrawPileKey,
    this.leftCenterPileKey,
    this.rightCenterPileKey,
    this.shakeCardIndex,
    this.shakeEpoch = 0,
    this.draggingCardIndex,
    this.tickId = 0,
    this.onCardDragStarted,
    this.onCardDragEnd,
    this.onCardDropOnPile,
  });

  final AppLocale locale;
  final String cpuDrawLabel;
  final String yourDrawLabel;
  final CenterPile? cpuAnimatingPile;
  final ValueChanged<CenterPile> onCenterPileTap;
  final Key? humanHandKey;
  final Key? humanDrawPileKey;
  final Key? leftCenterPileKey;
  final Key? rightCenterPileKey;
  final int? shakeCardIndex;
  final int shakeEpoch;
  final int? draggingCardIndex;
  final int tickId;
  final ValueChanged<int>? onCardDragStarted;
  final VoidCallback? onCardDragEnd;
  final void Function(HandCardDragData data, CenterPile pile)? onCardDropOnPile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = AppTheme.cardWidthForScreen(screenWidth);
    final cardHeight = AppTheme.cardHeightForScreen(screenWidth);
    final effectiveCardIndex = draggingCardIndex ?? state.selectedCardIndex;
    final selectedCard = _cardAtIndex(state.humanHand, effectiveCardIndex);
    final leftFieldCard =
        cpuAnimatingPile == CenterPile.left && state.centerLeftPile.length >= 2
        ? state.centerLeftPile[state.centerLeftPile.length - 2]
        : state.centerLeftPile.lastOrNull;
    final rightFieldCard =
        cpuAnimatingPile == CenterPile.right &&
            state.centerRightPile.length >= 2
        ? state.centerRightPile[state.centerRightPile.length - 2]
        : state.centerRightPile.lastOrNull;

    final canPlay = state.phase == GamePhase.playing;
    final leftIsValid = _isValidTarget(selectedCard, leftFieldCard);
    final rightIsValid = _isValidTarget(selectedCard, rightFieldCard);

    return Container(
      color: AppTheme.tableBackground,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CardHand(
                  cards: state.cpuHand,
                  isFaceUp: false,
                  isDimmed: state.phase == GamePhase.stalemate,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
                const SizedBox(height: 14),
                DrawPileIndicator(
                  remainingCount: state.cpuDrawPile.length,
                  label: cpuDrawLabel,
                ),
                const SizedBox(height: 34),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CenterPileWidget(
                      key: leftCenterPileKey,
                      topCard: leftFieldCard,
                      isValidTarget: leftIsValid,
                      onTap: canPlay
                          ? () => onCenterPileTap(CenterPile.left)
                          : null,
                      onWillAcceptDrag: canPlay
                          ? (data) => notifier.canPlayCardAtIndexOnPile(
                              data.cardIndex,
                              CenterPile.left,
                            )
                          : null,
                      onAcceptDrag: canPlay
                          ? (data) =>
                                onCardDropOnPile?.call(data, CenterPile.left)
                          : null,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                    ),
                    const SizedBox(width: 56),
                    CenterPileWidget(
                      key: rightCenterPileKey,
                      topCard: rightFieldCard,
                      isValidTarget: rightIsValid,
                      onTap: canPlay
                          ? () => onCenterPileTap(CenterPile.right)
                          : null,
                      onWillAcceptDrag: canPlay
                          ? (data) => notifier.canPlayCardAtIndexOnPile(
                              data.cardIndex,
                              CenterPile.right,
                            )
                          : null,
                      onAcceptDrag: canPlay
                          ? (data) =>
                                onCardDropOnPile?.call(data, CenterPile.right)
                          : null,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                DrawPileIndicator(
                  key: humanDrawPileKey,
                  remainingCount: state.humanDrawPile.length,
                  label: yourDrawLabel,
                ),
                const SizedBox(height: 14),
                CardHand(
                  key: humanHandKey,
                  cards: state.humanHand,
                  isFaceUp: true,
                  selectedCardIndex: state.selectedCardIndex,
                  shakeCardIndex: shakeCardIndex,
                  shakeEpoch: shakeEpoch,
                  isDimmed: state.phase == GamePhase.stalemate,
                  onCardTap: canPlay
                      ? (index) {
                          if (state.selectedCardIndex == index) {
                            notifier.deselectCard();
                            return;
                          }
                          notifier.selectCard(index);
                        }
                      : null,
                  enableDrag: canPlay,
                  tickId: tickId,
                  draggingCardIndex: draggingCardIndex,
                  onDragStarted: onCardDragStarted,
                  onDragEnd: onCardDragEnd,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
                const SizedBox(height: 18),
                GamePhaseIndicator(phase: state.phase, locale: locale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PlayingCard? _cardAtIndex(List<PlayingCard> cards, int? cardIndex) {
  if (cardIndex == null) {
    return null;
  }
  if (cardIndex < 0 || cardIndex >= cards.length) {
    return null;
  }
  return cards[cardIndex];
}

bool _isValidTarget(PlayingCard? selectedCard, PlayingCard? fieldCard) {
  if (selectedCard == null || fieldCard == null) {
    return false;
  }
  return isAdjacent(selectedCard.rank, fieldCard.rank);
}
