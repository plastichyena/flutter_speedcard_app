import 'package:flutter/material.dart';

import '../constants/game_constants.dart';

class AppTheme {
  const AppTheme._();

  static const double mobileCardWidth = 70;
  static const double mobileCardHeight = 100;
  static const double tabletCardWidth = 90;
  static const double tabletCardHeight = 128;
  static const double desktopCardWidth = 110;
  static const double desktopCardHeight = 157;

  static const double cardAspectRatio = 0.7;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  static const Color cardFaceBackground = Colors.white;
  static const Color cardBackBackground = Color(0xFF1565C0);
  static const Color cardBorder = Color(0xFFBDBDBD);
  static const Color selectedCardBorder = Color(0xFFFFD600);
  static const Color validTargetHighlight = Color(0xFF66BB6A);
  static const Color dimmedOverlay = Color(0x80000000);

  static const Color redSuit = Color(0xFFD32F2F);
  static const Color blackSuit = Color(0xFF212121);

  static const Color tableBackground = Color(0xFF2E7D32);

  static const Duration cardPlacementDuration =
      AnimationDurations.cardPlacement;
  static const Duration cardDrawDuration = AnimationDurations.cardDraw;
  static const Duration invalidShakeDuration = AnimationDurations.invalidShake;
  static const Duration cardSelectionDuration =
      AnimationDurations.cardSelection;
  static const Duration stalemateResetDuration =
      AnimationDurations.stalemateReset;

  static double cardWidthForScreen(double screenWidth) {
    if (screenWidth >= LayoutBreakpoints.desktopMinWidth) {
      return desktopCardWidth;
    }
    if (screenWidth >= LayoutBreakpoints.tabletMinWidth) {
      return tabletCardWidth;
    }
    return mobileCardWidth;
  }

  static double cardHeightForScreen(double screenWidth) {
    if (screenWidth >= LayoutBreakpoints.desktopMinWidth) {
      return desktopCardHeight;
    }
    if (screenWidth >= LayoutBreakpoints.tabletMinWidth) {
      return tabletCardHeight;
    }
    return mobileCardHeight;
  }

  static ThemeData get themeData {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: tableBackground,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: tableBackground,
    );
  }
}
