import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/logic/cpu_strategy.dart';
import 'package:flutter_speedcard_app/logic/game_engine.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_event.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/cpu_timer_provider.dart';

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    ref.onDispose(_cancelCpuTimer);
    return GameState.initial();
  }

  /// Start a new game with given difficulty.
  void startGame(Difficulty difficulty) {
    state = reduce(state, StartGame(difficulty));
    _checkGameEnd();
    _startCpuTimer();
  }

  /// Select a card in hand (for 2-step tap interaction).
  void selectCard(int cardIndex) {
    state = reduce(state, SelectCard(cardIndex));
  }

  /// Deselect the currently selected card.
  void deselectCard() {
    state = reduce(state, const DeselectCard());
  }

  /// Attempt to play selected card on a center pile.
  void playOnPile(CenterPile targetPile) {
    final selectedCardIndex = state.selectedCardIndex;
    if (selectedCardIndex == null) {
      return;
    }
    playCardAtIndex(selectedCardIndex, targetPile);
  }

  /// Read-only check: can card at [cardIndex] be played on [targetPile]?
  bool canPlayCardAtIndexOnPile(int cardIndex, CenterPile targetPile) {
    return canPlayCard(state, cardIndex, targetPile);
  }

  /// Play the card at [cardIndex] on [targetPile]. Returns true on success.
  /// Does not depend on selectedCardIndex and is intended for drag-and-drop.
  bool playCardAtIndex(int cardIndex, CenterPile targetPile) {
    if (state.phase != GamePhase.playing) {
      return false;
    }
    if (cardIndex < 0 || cardIndex >= state.humanHand.length) {
      return false;
    }

    final previous = state;
    state = reduce(state, PlayCard(Player.human, cardIndex, targetPile));

    if (_didHumanPlaySucceed(previous, state)) {
      state = reduce(state, const DeselectCard());
      _checkGameEnd();
      _restartCpuTimer();
      return true;
    }
    return false;
  }

  /// Called by CPU timer - applies CPU move.
  void applyCpuMove(CpuAction move) {
    if (state.phase != GamePhase.playing) {
      return;
    }

    state = reduce(
      state,
      PlayCard(Player.cpu, move.cardIndex, move.targetPile),
    );
    _checkGameEnd();
  }

  /// Reset stalemate (supply new field cards).
  void resetStalemate() {
    state = reduce(state, const ResetStalemate());
    _checkGameEnd();
    _startCpuTimer();
  }

  /// Restart the game completely.
  void restartGame() {
    _cancelCpuTimer();
    state = reduce(state, const RestartGame());
  }

  /// Check if game should end or if stalemate.
  void _checkGameEnd() {
    if (state.phase == GamePhase.stalemate ||
        state.phase == GamePhase.finished) {
      _cancelCpuTimer();
    }
  }

  bool _didHumanPlaySucceed(GameState before, GameState after) {
    return before.humanHand != after.humanHand ||
        before.humanDrawPile != after.humanDrawPile ||
        before.centerLeftPile != after.centerLeftPile ||
        before.centerRightPile != after.centerRightPile;
  }

  void _startCpuTimer() {
    if (state.phase != GamePhase.playing) {
      _cancelCpuTimer();
      return;
    }

    ref.read(cpuTimerProvider.notifier).scheduleCpuAction(state.difficulty);
  }

  void _restartCpuTimer() {
    _startCpuTimer();
  }

  void _cancelCpuTimer() {
    try {
      ref.read(cpuTimerProvider.notifier).cancelTimer();
    } on StateError {
      // Provider container may already be disposing.
    }
  }
}
