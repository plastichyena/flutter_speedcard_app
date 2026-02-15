import 'package:flutter_speedcard_app/logic/cpu_strategy.dart';
import 'package:flutter_speedcard_app/logic/game_engine.dart';
import 'package:flutter_speedcard_app/models/card.dart';
import 'package:flutter_speedcard_app/models/enums.dart';
import 'package:flutter_speedcard_app/models/game_event.dart';
import 'package:flutter_speedcard_app/models/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_utils.dart';

PlayingCard card(Suit suit, Rank rank) => PlayingCard(suit: suit, rank: rank);

void main() {
  group('simultaneous play resolution', () {
    test('same-tick conflict: both valid and both succeed', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight), card(Suit.heart, Rank.two)],
        cpuHand: [card(Suit.club, Rank.nine), card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.heart, Rank.seven)],
        centerRightPile: [card(Suit.club, Rank.jack)],
      );

      final next = resolveTick(state, const [
        PlayCard(Player.cpu, 0, CenterPile.left),
        PlayCard(Player.human, 0, CenterPile.left),
      ]);

      expect(next.tickId, state.tickId + 1);
      expect(next.centerLeftPile.last.rank, Rank.nine);
      expect(next.humanHand.length, 1);
      expect(next.cpuHand.length, 1);
    });

    test('same-tick conflict: human invalidates CPU move, CPU rejected', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight), card(Suit.heart, Rank.king)],
        cpuHand: [card(Suit.club, Rank.six), card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.heart, Rank.seven)],
        centerRightPile: [card(Suit.club, Rank.jack)],
      );

      final next = resolveTick(state, const [
        PlayCard(Player.cpu, 0, CenterPile.left),
        PlayCard(Player.human, 0, CenterPile.left),
      ]);

      expect(next.tickId, state.tickId + 1);
      expect(next.centerLeftPile.last.rank, Rank.eight);
      expect(next.cpuHand.length, 2);
      expect(next.cpuHand.first.rank, Rank.six);
    });

    test('CPU can find a new valid move on next evaluation', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight), card(Suit.heart, Rank.king)],
        cpuHand: [card(Suit.club, Rank.six), card(Suit.diamond, Rank.seven)],
        centerLeftPile: [card(Suit.heart, Rank.seven)],
        centerRightPile: [card(Suit.club, Rank.jack)],
      );

      final afterTick = resolveTick(state, const [
        PlayCard(Player.cpu, 0, CenterPile.left),
        PlayCard(Player.human, 0, CenterPile.left),
      ]);

      final nextCpuMove = findCpuMove(afterTick.toCpuVisible());

      expect(nextCpuMove, isNotNull);
      expect(nextCpuMove!.cardIndex, 1);
      expect(nextCpuMove.targetPile, CenterPile.left);
    });

    test('sequential plays across different ticks', () {
      final state = createTestState(
        humanHand: [card(Suit.spade, Rank.eight), card(Suit.heart, Rank.two)],
        cpuHand: [card(Suit.club, Rank.nine), card(Suit.diamond, Rank.four)],
        centerLeftPile: [card(Suit.heart, Rank.seven)],
        centerRightPile: [card(Suit.club, Rank.jack)],
      );

      final afterHuman = reduce(
        state,
        const PlayCard(Player.human, 0, CenterPile.left),
      );
      final afterCpu = reduce(
        afterHuman,
        const PlayCard(Player.cpu, 0, CenterPile.left),
      );

      expect(afterHuman.tickId, state.tickId + 1);
      expect(afterCpu.tickId, state.tickId + 2);
      expect(afterCpu.centerLeftPile.last.rank, Rank.nine);
      expect(afterCpu.humanHand.length, 1);
      expect(afterCpu.cpuHand.length, 1);
    });
  });
}
