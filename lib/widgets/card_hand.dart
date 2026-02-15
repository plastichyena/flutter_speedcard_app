import 'package:flutter/material.dart';

import '../models/card.dart';
import 'card_widget.dart';

class CardHand extends StatelessWidget {
  const CardHand({
    super.key,
    required this.cards,
    required this.isFaceUp,
    this.selectedCardIndex,
    this.isDimmed = false,
    this.shakeCardIndex,
    this.shakeEpoch = 0,
    this.onCardTap,
    required this.cardWidth,
    required this.cardHeight,
  });

  static const double overlap = 10;

  final List<PlayingCard> cards;
  final bool isFaceUp;
  final int? selectedCardIndex;
  final bool isDimmed;
  final int? shakeCardIndex;
  final int shakeEpoch;
  final ValueChanged<int>? onCardTap;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return SizedBox(height: cardHeight);
    }

    final totalWidth = cardWidth + ((cards.length - 1) * (cardWidth - overlap));

    return SizedBox(
      width: totalWidth,
      height: cardHeight + 8,
      child: Stack(
        children: List.generate(cards.length, (index) {
          return Positioned(
            left: index * (cardWidth - overlap),
            bottom: 0,
            child: CardWidget(
              card: cards[index],
              isFaceUp: isFaceUp,
              isSelected: isFaceUp && selectedCardIndex == index,
              isDimmed: isDimmed,
              shouldShake: isFaceUp && shakeCardIndex == index,
              shakeEpoch: shakeEpoch,
              onTap: (isFaceUp && onCardTap != null)
                  ? () => onCardTap!(index)
                  : null,
              width: cardWidth,
              height: cardHeight,
            ),
          );
        }),
      ),
    );
  }
}
