import 'dart:core';

import '../models/enums.dart';

class LayoutBreakpoints {
  const LayoutBreakpoints._();

  static const double mobileMaxWidth = 600;
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 1023;
  static const double desktopMinWidth = 1024;
}

class AnimationDurations {
  const AnimationDurations._();

  static const Duration cardPlacement = Duration(milliseconds: 160);
  static const Duration cardDraw = Duration(milliseconds: 125);
  static const Duration invalidShake = Duration(milliseconds: 150);
  static const Duration cardSelection = Duration(milliseconds: 100);
  static const Duration stalemateReset = Duration(milliseconds: 250);
}

class CpuDelayRange {
  const CpuDelayRange({required this.minMs, required this.maxMs});

  final int minMs;
  final int maxMs;
}

class GameConstants {
  const GameConstants._();

  static const int maxHandSize = 4;
  static const int initialDrawPileSize = 21;
  static const int totalCards = 52;

  static const Map<Difficulty, CpuDelayRange> cpuDelayRanges = {
    Difficulty.easy: CpuDelayRange(minMs: 3000, maxMs: 5000),
    Difficulty.normal: CpuDelayRange(minMs: 1000, maxMs: 3000),
    Difficulty.hard: CpuDelayRange(minMs: 500, maxMs: 1000),
  };
}
