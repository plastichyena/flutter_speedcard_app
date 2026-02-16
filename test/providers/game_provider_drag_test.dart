import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_speedcard_app/providers/cpu_timer_provider.dart';
import 'package:flutter_speedcard_app/providers/game_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_utils.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

class _FixedGameNotifier extends GameNotifier {
  _FixedGameNotifier(this._state);

  final GameState _state;

  @override
  GameState build() => _state;
}

class _FakeCpuTimerNotifier extends CpuTimerNotifier {
  int scheduleCalls = 0;
  int cancelCalls = 0;
  Difficulty? lastDifficulty;

  @override
  void build() {}

  @override
  void scheduleCpuAction(Difficulty difficulty) {
    scheduleCalls += 1;
    lastDifficulty = difficulty;
  }

  @override
  void cancelTimer() {
    cancelCalls += 1;
  }
}

ProviderContainer _createContainer(GameState state) {
  return ProviderContainer(
    overrides: [
      gameProvider.overrideWith(() => _FixedGameNotifier(state)),
      cpuTimerProvider.overrideWith(_FakeCpuTimerNotifier.new),
    ],
  );
}

void main() {
  group('GameNotifier drag-and-drop methods', () {
    test('canPlayCardAtIndexOnPile validates using current state', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
        centerRightPile: [card(Suit.heart, Rank.queen)],
      );
      final container = _createContainer(state);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      expect(notifier.canPlayCardAtIndexOnPile(0, CenterPile.left), isTrue);
      expect(notifier.canPlayCardAtIndexOnPile(0, CenterPile.right), isFalse);
    });

    test('playCardAtIndex returns true on success and restarts cpu timer', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        cpuHand: [card(Suit.heart, Rank.nine)],
        humanDrawPile: [card(Suit.diamond, Rank.three)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      );
      final container = _createContainer(state);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final timer =
          container.read(cpuTimerProvider.notifier) as _FakeCpuTimerNotifier;

      final didPlay = notifier.playCardAtIndex(0, CenterPile.left);
      final next = container.read(gameProvider);

      expect(didPlay, isTrue);
      expect(next.centerLeftPile.last.rank, Rank.eight);
      expect(next.humanHand, [card(Suit.diamond, Rank.three)]);
      expect(next.selectedCardIndex, isNull);
      expect(timer.scheduleCalls, 1);
      expect(timer.lastDifficulty, state.difficulty);
    });

    test('playCardAtIndex returns false on invalid move', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.three)],
        humanDrawPile: [card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      );
      final container = _createContainer(state);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final timer =
          container.read(cpuTimerProvider.notifier) as _FakeCpuTimerNotifier;

      final didPlay = notifier.playCardAtIndex(0, CenterPile.left);
      final next = container.read(gameProvider);

      expect(didPlay, isFalse);
      expect(next.humanHand, state.humanHand);
      expect(next.centerLeftPile, state.centerLeftPile);
      expect(next.tickId, state.tickId + 1);
      expect(timer.scheduleCalls, 0);
    });

    test(
      'playCardAtIndex returns false for non-playing phase or bad index',
      () {
        final base = createTestState(
          phase: GamePhase.finished,
          humanHand: [card(Suit.spade, Rank.eight)],
          centerLeftPile: [card(Suit.club, Rank.seven)],
        );
        final container = _createContainer(base);
        addTearDown(container.dispose);

        final notifier = container.read(gameProvider.notifier);
        final timer =
            container.read(cpuTimerProvider.notifier) as _FakeCpuTimerNotifier;

        expect(notifier.playCardAtIndex(0, CenterPile.left), isFalse);
        expect(notifier.playCardAtIndex(-1, CenterPile.left), isFalse);
        expect(notifier.playCardAtIndex(99, CenterPile.left), isFalse);
        expect(container.read(gameProvider), base);
        expect(timer.scheduleCalls, 0);
      },
    );

    test('playOnPile keeps tap flow by delegating selected index play', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight)],
        humanDrawPile: [card(Suit.diamond, Rank.five)],
        centerLeftPile: [card(Suit.club, Rank.seven)],
      ).copyWith(selectedCardIndex: 0);
      final container = _createContainer(state);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);

      notifier.playOnPile(CenterPile.left);
      final next = container.read(gameProvider);

      expect(next.centerLeftPile.last.rank, Rank.eight);
      expect(next.selectedCardIndex, isNull);
    });
  });
}
