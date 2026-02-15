import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/card.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    this.card,
    required this.isFaceUp,
    this.isSelected = false,
    this.isDimmed = false,
    this.shouldShake = false,
    this.shakeEpoch = 0,
    this.onTap,
    required this.width,
    required this.height,
  });

  final PlayingCard? card;
  final bool isFaceUp;
  final bool isSelected;
  final bool isDimmed;
  final bool shouldShake;
  final int shakeEpoch;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final Duration selectionDuration = reduceMotion
        ? Duration.zero
        : AppTheme.cardSelectionDuration;
    final Duration shakeDuration = reduceMotion
        ? Duration.zero
        : AppTheme.invalidShakeDuration;
    final bool showFace = isFaceUp && card != null;

    Widget content = AnimatedContainer(
      duration: selectionDuration,
      curve: Curves.easeOut,
      width: width,
      height: height,
      transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(
          color: isSelected ? AppTheme.selectedCardBorder : AppTheme.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : const [],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.cardBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showFace) _CardFace(card: card!) else const _CardBack(),
            if (isDimmed)
              const DecoratedBox(
                decoration: BoxDecoration(color: AppTheme.dimmedOverlay),
              ),
          ],
        ),
      ),
    );

    content = _ShakeEffect(
      shouldShake: shouldShake,
      shakeEpoch: shakeEpoch,
      duration: shakeDuration,
      child: content,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.cardBorderRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: Align(alignment: Alignment.center, child: content),
    );
  }
}

class _ShakeEffect extends StatelessWidget {
  const _ShakeEffect({
    required this.shouldShake,
    required this.shakeEpoch,
    required this.duration,
    required this.child,
  });

  final bool shouldShake;
  final int shakeEpoch;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!shouldShake || duration == Duration.zero) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(shakeEpoch),
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, animatedChild) {
        final offsetX = math.sin(value * math.pi * 6) * (1 - value) * 8;
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: animatedChild,
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.card});

  final PlayingCard card;

  @override
  Widget build(BuildContext context) {
    final Color suitColor = _suitColor(card.suit);
    final String rankText = _rankLabel(card.rank);
    final String suitText = _suitSymbol(card.suit);

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppTheme.cardFaceBackground),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: _CornerLabel(
              rankText: rankText,
              suitText: suitText,
              color: suitColor,
            ),
          ),
          Center(
            child: Text(
              suitText,
              style: TextStyle(
                color: suitColor,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
                height: 1,
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: Transform.rotate(
              angle: math.pi,
              child: _CornerLabel(
                rankText: rankText,
                suitText: suitText,
                color: suitColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({
    required this.rankText,
    required this.suitText,
    required this.color,
  });

  final String rankText;
  final String suitText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: color,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: 'serif',
        height: 1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(rankText), Text(suitText)],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _CardBackPainter());
  }
}

class _CardBackPainter extends CustomPainter {
  const _CardBackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppTheme.cardBackBackground);

    final Paint patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 1.2;

    const double gap = 9;
    for (double x = -size.height; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        patternPaint,
      );
    }
    for (double x = 0; x < size.width + size.height; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        patternPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _rankLabel(Rank rank) {
  return switch (rank) {
    Rank.ace => 'A',
    Rank.two => '2',
    Rank.three => '3',
    Rank.four => '4',
    Rank.five => '5',
    Rank.six => '6',
    Rank.seven => '7',
    Rank.eight => '8',
    Rank.nine => '9',
    Rank.ten => '10',
    Rank.jack => 'J',
    Rank.queen => 'Q',
    Rank.king => 'K',
  };
}

String _suitSymbol(Suit suit) {
  return switch (suit) {
    Suit.spade => '♠',
    Suit.heart => '♥',
    Suit.diamond => '♦',
    Suit.club => '♣',
  };
}

Color _suitColor(Suit suit) {
  return switch (suit) {
    Suit.heart || Suit.diamond => AppTheme.redSuit,
    Suit.spade || Suit.club => AppTheme.blackSuit,
  };
}
