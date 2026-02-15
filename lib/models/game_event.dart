import 'enums.dart';

sealed class GameEvent {
  const GameEvent();
}

class StartGame extends GameEvent {
  const StartGame(this.difficulty);

  final Difficulty difficulty;
}

class PlayCard extends GameEvent {
  const PlayCard(this.player, this.cardIndex, this.targetPile);

  final Player player;
  final int cardIndex;
  final CenterPile targetPile;
}

class DrawCard extends GameEvent {
  const DrawCard(this.player);

  final Player player;
}

class SelectCard extends GameEvent {
  const SelectCard(this.cardIndex);

  final int cardIndex;
}

class DeselectCard extends GameEvent {
  const DeselectCard();
}

class ResetStalemate extends GameEvent {
  const ResetStalemate();
}

class RestartGame extends GameEvent {
  const RestartGame();
}
