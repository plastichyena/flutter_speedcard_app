import 'package:flutter/material.dart';

import '../models/card.dart';
import '../theme/app_theme.dart';
import 'card_widget.dart';

class CenterPileWidget extends StatefulWidget {
  const CenterPileWidget({
    super.key,
    this.topCard,
    this.isValidTarget = false,
    this.onTap,
    required this.cardWidth,
    required this.cardHeight,
  });

  final PlayingCard? topCard;
  final bool isValidTarget;
  final VoidCallback? onTap;
  final double cardWidth;
  final double cardHeight;

  @override
  State<CenterPileWidget> createState() => _CenterPileWidgetState();
}

class _CenterPileWidgetState extends State<CenterPileWidget> {
  bool _pulseExpanded = false;

  @override
  void didUpdateWidget(covariant CenterPileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isValidTarget && _pulseExpanded) {
      _pulseExpanded = false;
    }
  }

  void _onPulseEnd() {
    if (!mounted) {
      return;
    }

    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!widget.isValidTarget || reduceMotion) {
      return;
    }

    setState(() {
      _pulseExpanded = !_pulseExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    final bool pulseEnabled = widget.isValidTarget && !reduceMotion;
    final Duration highlightDuration = reduceMotion
        ? Duration.zero
        : AppTheme.cardSelectionDuration;
    final Duration pulseDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(
        '${widget.isValidTarget}-${widget.topCard}-$reduceMotion-$_pulseExpanded',
      ),
      tween: Tween<double>(
        begin: pulseEnabled ? (_pulseExpanded ? 1.0 : 0.74) : 1.0,
        end: pulseEnabled ? (_pulseExpanded ? 0.74 : 1.0) : 1.0,
      ),
      duration: pulseEnabled ? pulseDuration : Duration.zero,
      curve: Curves.easeInOut,
      onEnd: _onPulseEnd,
      builder: (context, pulse, child) {
        return AnimatedContainer(
          duration: highlightDuration,
          curve: Curves.easeOut,
          padding: EdgeInsets.all(widget.isValidTarget ? 2 : 0),
          decoration: BoxDecoration(
            borderRadius: AppTheme.cardBorderRadius,
            border: Border.all(
              color: widget.isValidTarget
                  ? AppTheme.validTargetHighlight
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: widget.isValidTarget
                ? [
                    BoxShadow(
                      color: AppTheme.validTargetHighlight.withValues(
                        alpha: 0.36 + (pulse * 0.34),
                      ),
                      blurRadius: 8 + (pulse * 8),
                      spreadRadius: 0.8 + (pulse * 1.8),
                    ),
                  ]
                : const [],
          ),
          child: child,
        );
      },
      child: CardWidget(
        card: widget.topCard,
        isFaceUp: widget.topCard != null,
        onTap: widget.onTap,
        width: widget.cardWidth,
        height: widget.cardHeight,
      ),
    );
  }
}
