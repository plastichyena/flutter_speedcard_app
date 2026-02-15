import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/constants/game_constants.dart';
import 'package:flutter_speedcard_app/l10n/app_strings.dart';
import 'package:flutter_speedcard_app/layouts/desktop_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/mobile_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/tablet_game_layout.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/cpu_timer_provider.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_speedcard_app/providers/locale_provider.dart';
import 'package:flutter_speedcard_app/theme/app_theme.dart';
import 'package:flutter_speedcard_app/widgets/card_hand.dart';
import 'package:flutter_speedcard_app/widgets/card_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  static const String routeName = '/game';

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static const Duration _cpuRevealDuration = Duration(milliseconds: 260);
  static const Duration _cpuSlideDuration = Duration(milliseconds: 240);
  static const Duration _statusOverlayFadeDuration = Duration(
    milliseconds: 180,
  );

  final GlobalKey _boardStackKey = GlobalKey();
  final GlobalKey _humanHandKey = GlobalKey();
  final GlobalKey _humanDrawPileKey = GlobalKey();
  final GlobalKey _leftCenterPileKey = GlobalKey();
  final GlobalKey _rightCenterPileKey = GlobalKey();

  Timer? _cpuRevealTimer;
  Timer? _cpuAnimationEndTimer;
  PlayingCard? _animatedCpuCard;
  CenterPile? _animatedCpuTargetPile;
  bool _isCpuCardSliding = false;

  int _nextAnimationId = 1;
  int? _invalidShakeCardIndex;
  int _invalidShakeEpoch = 0;
  List<_CardTravelAnimation> _humanPlacementAnimations =
      const <_CardTravelAnimation>[];
  List<_CardTravelAnimation> _humanDrawAnimations =
      const <_CardTravelAnimation>[];
  List<_CenterArrivalAnimation> _stalemateArrivalAnimations =
      const <_CenterArrivalAnimation>[];
  late final CpuTimerNotifier _cpuTimerNotifier;

  @override
  void initState() {
    super.initState();
    _cpuTimerNotifier = ref.read(cpuTimerProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final locale = ref.watch(localeProvider);
    ref.listen<GameState>(gameProvider, _onGameStateChanged);

    final bool reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cardWidth = AppTheme.cardWidthForScreen(width);
          final cardHeight = AppTheme.cardHeightForScreen(width);
          final CenterPile? cpuAnimatingPile = _animatedCpuCard != null
              ? _animatedCpuTargetPile
              : null;

          final Widget layout;
          if (width < LayoutBreakpoints.mobileMaxWidth) {
            layout = MobileGameLayout(
              locale: locale,
              cpuDrawLabel: AppStrings.get(locale, 'cpu_draw'),
              yourDrawLabel: AppStrings.get(locale, 'your_draw'),
              cpuAnimatingPile: cpuAnimatingPile,
              onCenterPileTap: _onCenterPileTap,
              humanHandKey: _humanHandKey,
              humanDrawPileKey: _humanDrawPileKey,
              leftCenterPileKey: _leftCenterPileKey,
              rightCenterPileKey: _rightCenterPileKey,
              shakeCardIndex: _invalidShakeCardIndex,
              shakeEpoch: _invalidShakeEpoch,
            );
          } else if (width < LayoutBreakpoints.desktopMinWidth) {
            layout = TabletGameLayout(
              locale: locale,
              cpuDrawLabel: AppStrings.get(locale, 'cpu_draw'),
              yourDrawLabel: AppStrings.get(locale, 'your_draw'),
              cpuAnimatingPile: cpuAnimatingPile,
              onCenterPileTap: _onCenterPileTap,
              humanHandKey: _humanHandKey,
              humanDrawPileKey: _humanDrawPileKey,
              leftCenterPileKey: _leftCenterPileKey,
              rightCenterPileKey: _rightCenterPileKey,
              shakeCardIndex: _invalidShakeCardIndex,
              shakeEpoch: _invalidShakeEpoch,
            );
          } else {
            layout = DesktopGameLayout(
              locale: locale,
              cpuDrawLabel: AppStrings.get(locale, 'cpu_draw'),
              yourDrawLabel: AppStrings.get(locale, 'your_draw'),
              cpuAnimatingPile: cpuAnimatingPile,
              onCenterPileTap: _onCenterPileTap,
              humanHandKey: _humanHandKey,
              humanDrawPileKey: _humanDrawPileKey,
              leftCenterPileKey: _leftCenterPileKey,
              rightCenterPileKey: _rightCenterPileKey,
              shakeCardIndex: _invalidShakeCardIndex,
              shakeEpoch: _invalidShakeEpoch,
            );
          }

          return Stack(
            key: _boardStackKey,
            children: [
              layout,
              for (final animation in _humanPlacementAnimations)
                _CardTravelOverlay(
                  animation: animation,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              for (final animation in _humanDrawAnimations)
                _CardTravelOverlay(
                  animation: animation,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              if (_animatedCpuCard != null && _animatedCpuTargetPile != null)
                _CpuPlayAnimationOverlay(
                  card: _animatedCpuCard!,
                  targetPile: _animatedCpuTargetPile!,
                  isSliding: _isCpuCardSliding,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              for (final animation in _stalemateArrivalAnimations)
                _CenterArrivalOverlay(
                  animation: animation,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring:
                      state.phase != GamePhase.stalemate &&
                      state.phase != GamePhase.finished,
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : _statusOverlayFadeDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _buildStatusOverlay(state, locale),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _cancelCpuAnimation();
    _cpuTimerNotifier.cancelTimer();
    super.dispose();
  }

  void _onCenterPileTap(CenterPile targetPile) {
    final before = ref.read(gameProvider);
    final selectedIndex = before.selectedCardIndex;
    if (before.phase != GamePhase.playing || selectedIndex == null) {
      return;
    }
    if (selectedIndex < 0 || selectedIndex >= before.humanHand.length) {
      return;
    }

    final selectedCard = before.humanHand[selectedIndex];

    ref.read(gameProvider.notifier).playOnPile(targetPile);
    final after = ref.read(gameProvider);
    final didSucceed = _didHumanPlaySucceed(before, after);

    if (!didSucceed) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid move'),
          duration: Duration(milliseconds: 900),
        ),
      );

      setState(() {
        _invalidShakeCardIndex = selectedIndex;
        _invalidShakeEpoch += 1;
      });
      return;
    }

    if (_invalidShakeCardIndex != null) {
      setState(() {
        _invalidShakeCardIndex = null;
      });
    }

    if (_shouldReduceMotion()) {
      return;
    }

    _startHumanPlacementAnimation(
      card: selectedCard,
      targetPile: targetPile,
      selectedIndex: selectedIndex,
      handCountBeforePlay: before.humanHand.length,
    );

    final drawnCard = _extractHumanDrawnCard(before, after);
    if (drawnCard == null) {
      return;
    }

    final destinationIndex = after.humanHand.indexOf(drawnCard);
    if (destinationIndex == -1) {
      return;
    }

    _startHumanDrawAnimation(
      card: drawnCard,
      destinationIndex: destinationIndex,
      handCountAfterDraw: after.humanHand.length,
    );
  }

  void _onGameStateChanged(GameState? previous, GameState next) {
    if (previous == null) {
      return;
    }

    if (_invalidShakeCardIndex != null &&
        (next.selectedCardIndex == null ||
            next.selectedCardIndex != _invalidShakeCardIndex)) {
      setState(() {
        _invalidShakeCardIndex = null;
      });
    }

    final cpuPlay = _extractCpuPlay(previous, next);
    if (cpuPlay != null) {
      _startCpuAnimation(cpuPlay.card, cpuPlay.targetPile);
    }

    final stalemateCards = _extractStalemateResetCards(previous, next);
    if (stalemateCards.isNotEmpty) {
      _startStalemateResetAnimation(stalemateCards);
    }
  }

  _CpuPlayVisual? _extractCpuPlay(GameState before, GameState after) {
    if (before.phase != GamePhase.playing) {
      return null;
    }
    if (before.cpuHand == after.cpuHand) {
      return null;
    }

    final leftAdded =
        after.centerLeftPile.length == before.centerLeftPile.length + 1;
    final rightAdded =
        after.centerRightPile.length == before.centerRightPile.length + 1;

    if (leftAdded == rightAdded) {
      return null;
    }

    if (leftAdded && after.centerLeftPile.isNotEmpty) {
      return _CpuPlayVisual(
        card: after.centerLeftPile.last,
        targetPile: CenterPile.left,
      );
    }
    if (rightAdded && after.centerRightPile.isNotEmpty) {
      return _CpuPlayVisual(
        card: after.centerRightPile.last,
        targetPile: CenterPile.right,
      );
    }

    return null;
  }

  List<_StalemateResetCard> _extractStalemateResetCards(
    GameState before,
    GameState after,
  ) {
    if (before.phase != GamePhase.stalemate) {
      return const [];
    }

    final cards = <_StalemateResetCard>[];

    if (after.centerLeftPile.length == before.centerLeftPile.length + 1 &&
        after.centerLeftPile.isNotEmpty) {
      cards.add(
        _StalemateResetCard(
          card: after.centerLeftPile.last,
          targetPile: CenterPile.left,
        ),
      );
    }

    if (after.centerRightPile.length == before.centerRightPile.length + 1 &&
        after.centerRightPile.isNotEmpty) {
      cards.add(
        _StalemateResetCard(
          card: after.centerRightPile.last,
          targetPile: CenterPile.right,
        ),
      );
    }

    return cards;
  }

  PlayingCard? _extractHumanDrawnCard(GameState before, GameState after) {
    if (before.humanDrawPile.isEmpty) {
      return null;
    }

    if (before.humanDrawPile.length <= after.humanDrawPile.length) {
      return null;
    }

    final drawnCard = before.humanDrawPile.last;
    if (!after.humanHand.contains(drawnCard)) {
      return null;
    }

    return drawnCard;
  }

  void _startCpuAnimation(PlayingCard card, CenterPile targetPile) {
    _cancelCpuAnimationTimers();

    if (_shouldReduceMotion() || !mounted) {
      return;
    }

    setState(() {
      _animatedCpuCard = card;
      _animatedCpuTargetPile = targetPile;
      _isCpuCardSliding = false;
    });

    _cpuRevealTimer = Timer(_cpuRevealDuration, () {
      if (!mounted || _animatedCpuCard == null) {
        return;
      }
      setState(() {
        _isCpuCardSliding = true;
      });
    });

    _cpuAnimationEndTimer = Timer(_cpuRevealDuration + _cpuSlideDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _animatedCpuCard = null;
        _animatedCpuTargetPile = null;
        _isCpuCardSliding = false;
      });
    });
  }

  void _startHumanPlacementAnimation({
    required PlayingCard card,
    required CenterPile targetPile,
    required int selectedIndex,
    required int handCountBeforePlay,
  }) {
    final cardSize = _currentCardSize();
    final from = _humanHandCardOffset(
      cardIndex: selectedIndex,
      handCount: handCountBeforePlay,
      cardWidth: cardSize.width,
      cardHeight: cardSize.height,
      isSelected: true,
    );
    final to = _centerPileCardOffset(
      targetPile,
      cardWidth: cardSize.width,
      cardHeight: cardSize.height,
    );

    if (from == null || to == null) {
      return;
    }

    final animation = _CardTravelAnimation(
      id: _nextOverlayId(),
      card: card,
      from: from,
      to: to,
      duration: AppTheme.cardPlacementDuration,
      curve: Curves.easeOutCubic,
      beginOpacity: 1,
      beginScale: 1,
    );

    setState(() {
      _humanPlacementAnimations = [..._humanPlacementAnimations, animation];
    });

    _scheduleHumanPlacementCleanup(animation.id, animation.duration);
  }

  void _startHumanDrawAnimation({
    required PlayingCard card,
    required int destinationIndex,
    required int handCountAfterDraw,
  }) {
    final cardSize = _currentCardSize();
    final from = _humanDrawPileCardOffset(
      cardWidth: cardSize.width,
      cardHeight: cardSize.height,
    );
    final to = _humanHandCardOffset(
      cardIndex: destinationIndex,
      handCount: handCountAfterDraw,
      cardWidth: cardSize.width,
      cardHeight: cardSize.height,
      isSelected: false,
    );

    if (from == null || to == null) {
      return;
    }

    final animation = _CardTravelAnimation(
      id: _nextOverlayId(),
      card: card,
      from: from,
      to: to,
      duration: AppTheme.cardDrawDuration,
      curve: Curves.easeOut,
      beginOpacity: 0.55,
      beginScale: 0.92,
    );

    setState(() {
      _humanDrawAnimations = [..._humanDrawAnimations, animation];
    });

    _scheduleHumanDrawCleanup(animation.id, animation.duration);
  }

  void _startStalemateResetAnimation(List<_StalemateResetCard> cards) {
    if (_shouldReduceMotion() || cards.isEmpty) {
      return;
    }

    final cardSize = _currentCardSize();
    final additions = <_CenterArrivalAnimation>[];

    for (final entry in cards) {
      final target = _centerPileCardOffset(
        entry.targetPile,
        cardWidth: cardSize.width,
        cardHeight: cardSize.height,
      );
      if (target == null) {
        continue;
      }

      additions.add(
        _CenterArrivalAnimation(
          id: _nextOverlayId(),
          card: entry.card,
          target: target,
          duration: AppTheme.stalemateResetDuration,
        ),
      );
    }

    if (additions.isEmpty) {
      return;
    }

    setState(() {
      _stalemateArrivalAnimations = [
        ..._stalemateArrivalAnimations,
        ...additions,
      ];
    });

    final maxDuration = additions.map((entry) => entry.duration).fold(
      Duration.zero,
      (current, duration) {
        return duration > current ? duration : current;
      },
    );

    Future<void>.delayed(maxDuration, () {
      if (!mounted) {
        return;
      }

      final ids = additions.map((entry) => entry.id).toSet();
      setState(() {
        _stalemateArrivalAnimations = _stalemateArrivalAnimations
            .where((entry) => !ids.contains(entry.id))
            .toList();
      });
    });
  }

  ({double width, double height}) _currentCardSize() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (
      width: AppTheme.cardWidthForScreen(screenWidth),
      height: AppTheme.cardHeightForScreen(screenWidth),
    );
  }

  bool _shouldReduceMotion() {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  Rect? _rectFromKey(GlobalKey key) {
    final targetContext = key.currentContext;
    final stackContext = _boardStackKey.currentContext;
    if (targetContext == null || stackContext == null) {
      return null;
    }

    final targetRender = targetContext.findRenderObject() as RenderBox?;
    final stackRender = stackContext.findRenderObject() as RenderBox?;
    if (targetRender == null || stackRender == null) {
      return null;
    }

    if (!targetRender.hasSize || !stackRender.hasSize) {
      return null;
    }

    final topLeft = targetRender.localToGlobal(
      Offset.zero,
      ancestor: stackRender,
    );
    return topLeft & targetRender.size;
  }

  Offset? _humanHandCardOffset({
    required int cardIndex,
    required int handCount,
    required double cardWidth,
    required double cardHeight,
    required bool isSelected,
  }) {
    final handRect = _rectFromKey(_humanHandKey);
    if (handRect == null || handCount <= 0) {
      return null;
    }

    final clampedIndex = cardIndex.clamp(0, handCount - 1);
    final stride = cardWidth - CardHand.overlap;
    final rawLeft = handRect.left + (clampedIndex * stride);
    final maxLeft = handRect.right - cardWidth;
    final left = rawLeft.clamp(handRect.left, maxLeft).toDouble();

    final baseTop = handRect.bottom - cardHeight;
    final top = isSelected ? baseTop - 10 : baseTop;
    return Offset(left, top);
  }

  Offset? _humanDrawPileCardOffset({
    required double cardWidth,
    required double cardHeight,
  }) {
    final drawRect = _rectFromKey(_humanDrawPileKey);
    if (drawRect == null) {
      return null;
    }

    return Offset(
      drawRect.center.dx - (cardWidth / 2),
      drawRect.center.dy - (cardHeight / 2),
    );
  }

  Offset? _centerPileCardOffset(
    CenterPile targetPile, {
    required double cardWidth,
    required double cardHeight,
  }) {
    final pileRect = _rectFromKey(
      targetPile == CenterPile.left ? _leftCenterPileKey : _rightCenterPileKey,
    );
    if (pileRect == null) {
      return null;
    }

    return Offset(
      pileRect.center.dx - (cardWidth / 2),
      pileRect.center.dy - (cardHeight / 2),
    );
  }

  int _nextOverlayId() {
    final id = _nextAnimationId;
    _nextAnimationId += 1;
    return id;
  }

  void _scheduleHumanPlacementCleanup(int id, Duration duration) {
    Future<void>.delayed(duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _humanPlacementAnimations = _humanPlacementAnimations
            .where((entry) => entry.id != id)
            .toList();
      });
    });
  }

  void _scheduleHumanDrawCleanup(int id, Duration duration) {
    Future<void>.delayed(duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _humanDrawAnimations = _humanDrawAnimations
            .where((entry) => entry.id != id)
            .toList();
      });
    });
  }

  Widget _buildStatusOverlay(GameState state, AppLocale locale) {
    if (state.phase == GamePhase.stalemate) {
      return _StatusOverlay(
        key: const ValueKey<String>('status-stalemate'),
        title: AppStrings.get(locale, 'stalemate_title'),
        buttonLabel: AppStrings.get(locale, 'stalemate_button'),
        onPressed: () {
          ref.read(gameProvider.notifier).resetStalemate();
        },
      );
    }

    if (state.phase == GamePhase.finished) {
      return _StatusOverlay(
        key: const ValueKey<String>('status-finished'),
        title: _resultText(state.result, locale),
        buttonLabel: AppStrings.get(locale, 'restart'),
        onPressed: _restartToTitle,
      );
    }

    return const SizedBox.shrink(key: ValueKey<String>('status-none'));
  }

  void _cancelCpuAnimationTimers() {
    _cpuRevealTimer?.cancel();
    _cpuRevealTimer = null;
    _cpuAnimationEndTimer?.cancel();
    _cpuAnimationEndTimer = null;
  }

  void _cancelCpuAnimation() {
    _cancelCpuAnimationTimers();
    _animatedCpuCard = null;
    _animatedCpuTargetPile = null;
    _isCpuCardSliding = false;
  }

  void _restartToTitle() {
    ref.read(gameProvider.notifier).restartGame();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _CpuPlayVisual {
  const _CpuPlayVisual({required this.card, required this.targetPile});

  final PlayingCard card;
  final CenterPile targetPile;
}

class _StalemateResetCard {
  const _StalemateResetCard({required this.card, required this.targetPile});

  final PlayingCard card;
  final CenterPile targetPile;
}

class _CardTravelAnimation {
  const _CardTravelAnimation({
    required this.id,
    required this.card,
    required this.from,
    required this.to,
    required this.duration,
    required this.curve,
    required this.beginOpacity,
    required this.beginScale,
  });

  final int id;
  final PlayingCard card;
  final Offset from;
  final Offset to;
  final Duration duration;
  final Curve curve;
  final double beginOpacity;
  final double beginScale;
}

class _CenterArrivalAnimation {
  const _CenterArrivalAnimation({
    required this.id,
    required this.card,
    required this.target,
    required this.duration,
  });

  final int id;
  final PlayingCard card;
  final Offset target;
  final Duration duration;
}

class _CardTravelOverlay extends StatelessWidget {
  const _CardTravelOverlay({
    required this.animation,
    required this.cardWidth,
    required this.cardHeight,
  });

  final _CardTravelAnimation animation;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: animation.from.dx,
      top: animation.from.dy,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(animation.id),
          tween: Tween(begin: 0, end: 1),
          duration: animation.duration,
          curve: animation.curve,
          child: CardWidget(
            card: animation.card,
            isFaceUp: true,
            width: cardWidth,
            height: cardHeight,
          ),
          builder: (context, value, child) {
            final currentOffset = Offset.lerp(
              animation.from,
              animation.to,
              value,
            )!;
            final delta = currentOffset - animation.from;
            final opacity =
                animation.beginOpacity + ((1 - animation.beginOpacity) * value);
            final scale =
                animation.beginScale + ((1 - animation.beginScale) * value);

            return Transform.translate(
              offset: delta,
              child: Opacity(
                opacity: opacity.clamp(0, 1),
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CenterArrivalOverlay extends StatelessWidget {
  const _CenterArrivalOverlay({
    required this.animation,
    required this.cardWidth,
    required this.cardHeight,
  });

  final _CenterArrivalAnimation animation;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: animation.target.dx,
      top: animation.target.dy,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(animation.id),
          tween: Tween(begin: 0, end: 1),
          duration: animation.duration,
          curve: Curves.easeOutCubic,
          child: CardWidget(
            card: animation.card,
            isFaceUp: true,
            width: cardWidth,
            height: cardHeight,
          ),
          builder: (context, value, child) {
            final slideUp = (1 - value) * 14;
            final scale = 0.88 + (0.12 * value);
            return Transform.translate(
              offset: Offset(0, -slideUp),
              child: Opacity(
                opacity: value.clamp(0, 1),
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CpuPlayAnimationOverlay extends StatelessWidget {
  const _CpuPlayAnimationOverlay({
    required this.card,
    required this.targetPile,
    required this.isSliding,
    required this.cardWidth,
    required this.cardHeight,
  });

  final PlayingCard card;
  final CenterPile targetPile;
  final bool isSliding;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final orientation = MediaQuery.of(context).orientation;

          final startLeft = (width - cardWidth) / 2;
          final startTop = width >= LayoutBreakpoints.desktopMinWidth
              ? 64.0
              : 28.0;

          final centerGap = _centerPileGap(width, orientation);
          final leftPileX = (width - ((cardWidth * 2) + centerGap)) / 2;
          final rightPileX = leftPileX + cardWidth + centerGap;
          final endLeft = targetPile == CenterPile.left
              ? leftPileX
              : rightPileX;
          final endTop = (height - cardHeight) / 2;

          return SizedBox.expand(
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: _GameScreenState._cpuSlideDuration,
                  curve: Curves.easeInOutCubic,
                  left: isSliding ? endLeft : startLeft,
                  top: isSliding ? endTop : startTop,
                  width: cardWidth,
                  height: cardHeight,
                  child: RepaintBoundary(
                    child: CardWidget(
                      card: card,
                      isFaceUp: true,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _centerPileGap(double width, Orientation orientation) {
    if (width < LayoutBreakpoints.mobileMaxWidth) {
      return 16;
    }
    if (width < LayoutBreakpoints.desktopMinWidth) {
      return orientation == Orientation.landscape ? 36 : 24;
    }
    return 56;
  }
}

String _resultText(GameResult? result, AppLocale locale) {
  return switch (result) {
    GameResult.humanWin => AppStrings.get(locale, 'result_human_win'),
    GameResult.cpuWin => AppStrings.get(locale, 'result_cpu_win'),
    GameResult.draw => AppStrings.get(locale, 'result_draw'),
    null => AppStrings.get(locale, 'phase_finished'),
  };
}

bool _didHumanPlaySucceed(GameState before, GameState after) {
  return before.humanHand != after.humanHand ||
      before.humanDrawPile != after.humanDrawPile ||
      before.centerLeftPile != after.centerLeftPile ||
      before.centerRightPile != after.centerRightPile;
}
