import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/constants/game_constants.dart';
import 'package:flutter_speedcard_app/logic/cpu_strategy.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';

final cpuTimerProvider = NotifierProvider<CpuTimerNotifier, void>(
  CpuTimerNotifier.new,
);

class CpuTimerNotifier extends Notifier<void> {
  Timer? _timer;
  final Random _random = Random();

  @override
  void build() {
    ref.onDispose(cancelTimer);
  }

  /// Schedule CPU action with random delay based on difficulty.
  void scheduleCpuAction(Difficulty difficulty) {
    cancelTimer();

    final range = GameConstants.cpuDelayRanges[difficulty]!;
    final span = range.maxMs - range.minMs;
    final delayMs = span > 0
        ? range.minMs + _random.nextInt(span)
        : range.minMs;

    _timer = Timer(Duration(milliseconds: delayMs), _executeCpuAction);
  }

  void _executeCpuAction() {
    final gameState = ref.read(gameProvider);
    if (gameState.phase != GamePhase.playing) {
      cancelTimer();
      return;
    }

    final move = findCpuMove(gameState.toCpuVisible());
    if (move == null) {
      return;
    }

    ref.read(gameProvider.notifier).applyCpuMove(move);

    final updatedState = ref.read(gameProvider);
    if (updatedState.phase == GamePhase.playing) {
      scheduleCpuAction(updatedState.difficulty);
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
