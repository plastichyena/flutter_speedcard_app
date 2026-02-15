import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/enums.dart';

class GamePhaseIndicator extends StatelessWidget {
  const GamePhaseIndicator({
    super.key,
    required this.phase,
    required this.locale,
  });

  final GamePhase phase;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final Color color = _phaseColor(phase);

    return Chip(
      label: Text(_phaseLabel(locale, phase)),
      backgroundColor: color.withValues(alpha: 0.2),
      side: BorderSide(color: color),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _phaseLabel(AppLocale locale, GamePhase phase) {
  return switch (phase) {
    GamePhase.ready => AppStrings.get(locale, 'phase_ready'),
    GamePhase.playing => AppStrings.get(locale, 'phase_playing'),
    GamePhase.stalemate => AppStrings.get(locale, 'phase_stalemate'),
    GamePhase.finished => AppStrings.get(locale, 'phase_finished'),
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
