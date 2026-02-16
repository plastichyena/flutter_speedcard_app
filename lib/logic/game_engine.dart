import 'dart:math';

import 'package:flutter_speedcard_app/constants/game_constants.dart';
import 'package:flutter_speedcard_app/logic/card_utils.dart';
import 'package:flutter_speedcard_app/logic/stalemate_checker.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_event.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';

final _random = Random();

/// Pure reducer: takes current state + event, returns new state.
GameState reduce(GameState state, GameEvent event) {
  if (event is StartGame) {
    final initial = dealInitialState(event.difficulty);
    if (isStalemate(initial)) {
      return initial.copyWith(phase: GamePhase.stalemate);
    }
    return initial;
  }

  if (event is RestartGame) {
    return GameState.initial();
  }

  if (event is SelectCard) {
    return state.copyWith(selectedCardIndex: event.cardIndex);
  }

  if (event is DeselectCard) {
    return state.copyWith(selectedCardIndex: null);
  }

  if (event is DrawCard) {
    return _drawCard(state, event.player);
  }

  if (event is PlayCard) {
    return _playCard(state, event);
  }

  if (event is ResetStalemate) {
    return _resetStalemate(state);
  }

  return state;
}

/// Resolves multiple actions in the same tick.
/// Human play actions are always processed before CPU play actions.
GameState resolveTick(GameState state, List<GameEvent> events) {
  if (events.isEmpty) {
    return state;
  }

  final hasPlayAction = events.any((event) => event is PlayCard);
  if (!hasPlayAction) {
    var nextState = state;
    for (final event in events) {
      nextState = reduce(nextState, event);
    }
    return nextState;
  }

  final humanActions = <PlayCard>[];
  final cpuActions = <PlayCard>[];
  final otherEvents = <GameEvent>[];

  for (final event in events) {
    if (event is PlayCard) {
      if (event.player == Player.human) {
        humanActions.add(event);
      } else {
        cpuActions.add(event);
      }
    } else {
      otherEvents.add(event);
    }
  }

  var nextState = state.copyWith(tickId: state.tickId + 1);

  for (final event in otherEvents) {
    nextState = reduce(nextState, event);
  }

  for (final event in humanActions) {
    nextState = _playCard(nextState, event, incrementTick: false);
  }

  for (final event in cpuActions) {
    nextState = _playCard(nextState, event, incrementTick: false);
  }

  return nextState;
}

GameState _drawCard(GameState state, Player player) {
  final hand = List<PlayingCard>.from(
    player == Player.human ? state.humanHand : state.cpuHand,
  );
  final drawPile = List<PlayingCard>.from(
    player == Player.human ? state.humanDrawPile : state.cpuDrawPile,
  );

  if (hand.length >= GameConstants.maxHandSize || drawPile.isEmpty) {
    return state;
  }

  hand.add(drawPile.removeLast());

  if (player == Player.human) {
    return state.copyWith(humanHand: hand, humanDrawPile: drawPile);
  }
  return state.copyWith(cpuHand: hand, cpuDrawPile: drawPile);
}

GameState _playCard(
  GameState state,
  PlayCard event, {
  bool incrementTick = true,
}) {
  final baseState = incrementTick
      ? state.copyWith(tickId: state.tickId + 1)
      : state;

  if (baseState.phase != GamePhase.playing) {
    return baseState;
  }

  final hand = List<PlayingCard>.from(
    event.player == Player.human ? baseState.humanHand : baseState.cpuHand,
  );
  if (event.cardIndex < 0 || event.cardIndex >= hand.length) {
    return baseState;
  }

  final centerPile = List<PlayingCard>.from(
    event.targetPile == CenterPile.left
        ? baseState.centerLeftPile
        : baseState.centerRightPile,
  );
  if (centerPile.isEmpty) {
    return baseState;
  }

  final playedCard = hand[event.cardIndex];
  final fieldRank = centerPile.last.rank;
  if (!isAdjacent(playedCard.rank, fieldRank)) {
    return baseState;
  }

  hand.removeAt(event.cardIndex);
  centerPile.add(playedCard);

  final drawPile = List<PlayingCard>.from(
    event.player == Player.human
        ? baseState.humanDrawPile
        : baseState.cpuDrawPile,
  );
  if (drawPile.isNotEmpty && hand.length < GameConstants.maxHandSize) {
    hand.insert(event.cardIndex, drawPile.removeLast());
  }

  var nextState = event.player == Player.human
      ? baseState.copyWith(
          humanHand: hand,
          humanDrawPile: drawPile,
          centerLeftPile: event.targetPile == CenterPile.left
              ? centerPile
              : baseState.centerLeftPile,
          centerRightPile: event.targetPile == CenterPile.right
              ? centerPile
              : baseState.centerRightPile,
          selectedCardIndex: null,
        )
      : baseState.copyWith(
          cpuHand: hand,
          cpuDrawPile: drawPile,
          centerLeftPile: event.targetPile == CenterPile.left
              ? centerPile
              : baseState.centerLeftPile,
          centerRightPile: event.targetPile == CenterPile.right
              ? centerPile
              : baseState.centerRightPile,
        );

  final result = _evaluateResult(nextState);
  if (result != null) {
    return nextState.copyWith(phase: GamePhase.finished, result: result);
  }

  if (isStalemate(nextState)) {
    return nextState.copyWith(phase: GamePhase.stalemate);
  }

  nextState = nextState.copyWith(phase: GamePhase.playing, result: null);
  return nextState;
}

GameState _resetStalemate(GameState state) {
  final preSupplyResult = _evaluateResult(state);
  if (preSupplyResult != null) {
    return state.copyWith(
      phase: GamePhase.finished,
      result: preSupplyResult,
      selectedCardIndex: null,
    );
  }

  final leftPile = List<PlayingCard>.from(state.centerLeftPile);
  final rightPile = List<PlayingCard>.from(state.centerRightPile);
  final humanDraw = List<PlayingCard>.from(state.humanDrawPile);
  final cpuDraw = List<PlayingCard>.from(state.cpuDrawPile);

  final humanHand = List<PlayingCard>.from(state.humanHand);
  final cpuHand = List<PlayingCard>.from(state.cpuHand);

  if (humanDraw.isNotEmpty) {
    leftPile.add(humanDraw.removeLast());
  } else if (humanHand.isNotEmpty) {
    final index = _random.nextInt(humanHand.length);
    leftPile.add(humanHand.removeAt(index));
  }
  if (cpuDraw.isNotEmpty) {
    rightPile.add(cpuDraw.removeLast());
  } else if (cpuHand.isNotEmpty) {
    final index = _random.nextInt(cpuHand.length);
    rightPile.add(cpuHand.removeAt(index));
  }

  var afterSupplyState = state.copyWith(
    centerLeftPile: leftPile,
    centerRightPile: rightPile,
    humanHand: humanHand,
    cpuHand: cpuHand,
    humanDrawPile: humanDraw,
    cpuDrawPile: cpuDraw,
    selectedCardIndex: null,
    tickId: state.tickId + 1,
  );

  final postSupplyResult = _evaluateResult(afterSupplyState);
  if (postSupplyResult != null) {
    return afterSupplyState.copyWith(
      phase: GamePhase.finished,
      result: postSupplyResult,
    );
  }

  if (isStalemate(afterSupplyState)) {
    return afterSupplyState.copyWith(phase: GamePhase.stalemate, result: null);
  }

  return afterSupplyState.copyWith(phase: GamePhase.playing, result: null);
}

GameResult? _evaluateResult(GameState state) {
  final humanTotal = state.humanHand.length + state.humanDrawPile.length;
  final cpuTotal = state.cpuHand.length + state.cpuDrawPile.length;

  if (humanTotal == 0 && cpuTotal == 0) {
    return GameResult.draw;
  }
  if (humanTotal == 0) {
    return GameResult.humanWin;
  }
  if (cpuTotal == 0) {
    return GameResult.cpuWin;
  }
  return null;
}
