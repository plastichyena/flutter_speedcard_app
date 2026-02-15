import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/layouts/desktop_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/mobile_game_layout.dart';
import 'package:flutter_speedcard_app/layouts/tablet_game_layout.dart';
import 'package:flutter_speedcard_app/l10n/app_strings.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

GameState testState() {
  return GameState(
    phase: GamePhase.ready,
    difficulty: Difficulty.normal,
    humanHand: [card(Suit.spade, Rank.eight)],
    cpuHand: [card(Suit.heart, Rank.five)],
    humanDrawPile: [card(Suit.club, Rank.ace)],
    cpuDrawPile: [card(Suit.diamond, Rank.queen)],
    centerLeftPile: [card(Suit.club, Rank.seven)],
    centerRightPile: [card(Suit.heart, Rank.nine)],
  );
}

Widget buildLayoutTestApp(Widget child, GameState state) {
  return ProviderScope(
    overrides: [gameProvider.overrideWith(() => _FixedGameNotifier(state))],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void _noop(CenterPile _) {}

void main() {
  final locale = AppLocale.en;
  final cpuDrawLabel = AppStrings.get(locale, 'cpu_draw');
  final yourDrawLabel = AppStrings.get(locale, 'your_draw');
  final phaseReady = AppStrings.get(locale, 'phase_ready');

  testWidgets('mobile layout renders localized labels', (tester) async {
    await tester.pumpWidget(
      buildLayoutTestApp(
        MobileGameLayout(
          locale: locale,
          cpuDrawLabel: cpuDrawLabel,
          yourDrawLabel: yourDrawLabel,
          onCenterPileTap: _noop,
        ),
        testState(),
      ),
    );

    expect(find.text(cpuDrawLabel), findsOneWidget);
    expect(find.text(yourDrawLabel), findsOneWidget);
    expect(find.text(phaseReady), findsOneWidget);
  });

  testWidgets('tablet layout renders localized labels', (tester) async {
    await tester.pumpWidget(
      buildLayoutTestApp(
        TabletGameLayout(
          locale: locale,
          cpuDrawLabel: cpuDrawLabel,
          yourDrawLabel: yourDrawLabel,
          onCenterPileTap: _noop,
        ),
        testState(),
      ),
    );

    expect(find.text(cpuDrawLabel), findsOneWidget);
    expect(find.text(yourDrawLabel), findsOneWidget);
    expect(find.text(phaseReady), findsOneWidget);
  });

  testWidgets('desktop layout renders localized labels', (tester) async {
    await tester.pumpWidget(
      buildLayoutTestApp(
        DesktopGameLayout(
          locale: locale,
          cpuDrawLabel: cpuDrawLabel,
          yourDrawLabel: yourDrawLabel,
          onCenterPileTap: _noop,
        ),
        testState(),
      ),
    );

    expect(find.text(cpuDrawLabel), findsOneWidget);
    expect(find.text(yourDrawLabel), findsOneWidget);
    expect(find.text(phaseReady), findsOneWidget);
  });
}
