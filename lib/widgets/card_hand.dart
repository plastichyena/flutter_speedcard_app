import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/hand_card_drag_data.dart';
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
    this.enableDrag = false,
    this.tickId = 0,
    this.draggingCardIndex,
    this.onDragStarted,
    this.onDragEnd,
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
  final bool enableDrag;
  final int tickId;
  final int? draggingCardIndex;
  final ValueChanged<int>? onDragStarted;
  final VoidCallback? onDragEnd;
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
          final bool isDraggingThisCard = draggingCardIndex == index;
          final cardWidget = CardWidget(
            card: cards[index],
            isFaceUp: isFaceUp,
            isSelected: isFaceUp && selectedCardIndex == index,
            isDimmed: isDimmed || isDraggingThisCard,
            shouldShake: isFaceUp && shakeCardIndex == index,
            shakeEpoch: shakeEpoch,
            onTap: (isFaceUp && onCardTap != null)
                ? () => onCardTap!(index)
                : null,
            width: cardWidth,
            height: cardHeight,
          );

          return Positioned(
            left: index * (cardWidth - overlap),
            bottom: 0,
            child: enableDrag
                ? LongPressDraggable<HandCardDragData>(
                    data: HandCardDragData(
                      cardIndex: index,
                      card: cards[index],
                      tickId: tickId,
                    ),
                    onDragStarted: () => onDragStarted?.call(index),
                    onDragEnd: (_) => onDragEnd?.call(),
                    feedback: Material(
                      type: MaterialType.transparency,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: CardWidget(
                          card: cards[index],
                          isFaceUp: isFaceUp,
                          isSelected: false,
                          isDimmed: isDimmed,
                          shouldShake: false,
                          shakeEpoch: shakeEpoch,
                          width: cardWidth,
                          height: cardHeight,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: cardWidget),
                    child: cardWidget,
                  )
                : cardWidget,
          );
        }),
      ),
    );
  }
}
