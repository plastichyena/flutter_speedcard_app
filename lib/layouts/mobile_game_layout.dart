import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/theme/app_theme.dart';
import 'package:flutter_speedcard_app/widgets/card_hand.dart';
import 'package:flutter_speedcard_app/widgets/center_pile_widget.dart';
import 'package:flutter_speedcard_app/widgets/draw_pile_indicator.dart';
import 'package:flutter_speedcard_app/widgets/game_phase_indicator.dart';

class MobileGameLayout extends ConsumerWidget {
  const MobileGameLayout({
    super.key,
    required this.onCenterPileTap,
    this.humanHandKey,
    this.humanDrawPileKey,
    this.leftCenterPileKey,
    this.rightCenterPileKey,
    this.shakeCardIndex,
    this.shakeEpoch = 0,
  });

  final ValueChanged<CenterPile> onCenterPileTap;
  final Key? humanHandKey;
  final Key? humanDrawPileKey;
  final Key? leftCenterPileKey;
  final Key? rightCenterPileKey;
  final int? shakeCardIndex;
  final int shakeEpoch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = AppTheme.cardWidthForScreen(screenWidth);
    final cardHeight = AppTheme.cardHeightForScreen(screenWidth);
    final selectedCard = _selectedCard(state);
    final leftFieldCard = state.centerLeftPile.lastOrNull;
    final rightFieldCard = state.centerRightPile.lastOrNull;

    final canPlay = state.phase == GamePhase.playing;
    final leftIsValid = _isValidTarget(selectedCard, leftFieldCard);
    final rightIsValid = _isValidTarget(selectedCard, rightFieldCard);

    return Container(
      color: AppTheme.tableBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CardHand(
                    cards: state.cpuHand,
                    isFaceUp: false,
                    isDimmed: state.phase == GamePhase.stalemate,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                  const SizedBox(height: 8),
                  DrawPileIndicator(
                    remainingCount: state.cpuDrawPile.length,
                    label: 'CPU Draw',
                  ),
                ],
              ),
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
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                  const SizedBox(width: 16),
                  CenterPileWidget(
                    key: rightCenterPileKey,
                    topCard: rightFieldCard,
                    isValidTarget: rightIsValid,
                    onTap: canPlay
                        ? () => onCenterPileTap(CenterPile.right)
                        : null,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawPileIndicator(
                    key: humanDrawPileKey,
                    remainingCount: state.humanDrawPile.length,
                    label: 'Your Draw',
                  ),
                  const SizedBox(height: 8),
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
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  ),
                ],
              ),
              GamePhaseIndicator(phase: state.phase),
            ],
          ),
        ),
      ),
    );
  }
}

PlayingCard? _selectedCard(GameState state) {
  final selectedIndex = state.selectedCardIndex;
  if (selectedIndex == null) {
    return null;
  }
  if (selectedIndex < 0 || selectedIndex >= state.humanHand.length) {
    return null;
  }
  return state.humanHand[selectedIndex];
}

bool _isValidTarget(PlayingCard? selectedCard, PlayingCard? fieldCard) {
  if (selectedCard == null || fieldCard == null) {
    return false;
  }
  return isAdjacent(selectedCard.rank, fieldCard.rank);
}
