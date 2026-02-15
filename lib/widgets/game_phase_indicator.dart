import 'package:flutter/material.dart';

import '../models/enums.dart';

class GamePhaseIndicator extends StatelessWidget {
  const GamePhaseIndicator({super.key, required this.phase});

  final GamePhase phase;

  @override
  Widget build(BuildContext context) {
    final Color color = _phaseColor(phase);

    return Chip(
      label: Text(_phaseLabel(phase)),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _phaseLabel(GamePhase phase) {
  return switch (phase) {
    GamePhase.ready => 'Ready',
    GamePhase.playing => 'Playing',
    GamePhase.stalemate => 'Stalemate',
    GamePhase.finished => 'Finished',
  };
}

Color _phaseColor(GamePhase phase) {
  return switch (phase) {
    GamePhase.ready => Colors.grey,
    GamePhase.playing => Colors.green,
    GamePhase.stalemate => Colors.orange,
    GamePhase.finished => Colors.blue,
  };
}
