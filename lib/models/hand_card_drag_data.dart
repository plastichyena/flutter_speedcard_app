import 'card.dart';

/// Data payload carried during a card drag operation.
class HandCardDragData {
  const HandCardDragData({
    required this.cardIndex,
    required this.card,
    required this.tickId,
  });

  final int cardIndex;
  final PlayingCard card;
  final int tickId;
}
