import 'package:freezed_annotation/freezed_annotation.dart';

import 'card.dart';

part 'cpu_visible_state.freezed.dart';

@freezed
class CpuVisibleState with _$CpuVisibleState {
  const factory CpuVisibleState({
    required List<PlayingCard> cpuHand,
    required PlayingCard centerLeftFieldCard,
    required PlayingCard centerRightFieldCard,
  }) = _CpuVisibleState;
}
