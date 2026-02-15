import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'card.freezed.dart';

@freezed
class PlayingCard with _$PlayingCard {
  const factory PlayingCard({required Suit suit, required Rank rank}) =
      _PlayingCard;
}
