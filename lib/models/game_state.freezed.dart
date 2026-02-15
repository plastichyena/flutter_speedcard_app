// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameState {
  GamePhase get phase => throw _privateConstructorUsedError;
  Difficulty get difficulty => throw _privateConstructorUsedError;
  List<PlayingCard> get humanHand => throw _privateConstructorUsedError;
  List<PlayingCard> get cpuHand => throw _privateConstructorUsedError;
  List<PlayingCard> get humanDrawPile => throw _privateConstructorUsedError;
  List<PlayingCard> get cpuDrawPile => throw _privateConstructorUsedError;
  List<PlayingCard> get centerLeftPile => throw _privateConstructorUsedError;
  List<PlayingCard> get centerRightPile => throw _privateConstructorUsedError;
  int? get selectedCardIndex => throw _privateConstructorUsedError;
  GameResult? get result => throw _privateConstructorUsedError;
  int get tickId => throw _privateConstructorUsedError;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateCopyWith<GameState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateCopyWith<$Res> {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) then) =
      _$GameStateCopyWithImpl<$Res, GameState>;
  @useResult
  $Res call({
    GamePhase phase,
    Difficulty difficulty,
    List<PlayingCard> humanHand,
    List<PlayingCard> cpuHand,
    List<PlayingCard> humanDrawPile,
    List<PlayingCard> cpuDrawPile,
    List<PlayingCard> centerLeftPile,
    List<PlayingCard> centerRightPile,
    int? selectedCardIndex,
    GameResult? result,
    int tickId,
  });
}

/// @nodoc
class _$GameStateCopyWithImpl<$Res, $Val extends GameState>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? difficulty = null,
    Object? humanHand = null,
    Object? cpuHand = null,
    Object? humanDrawPile = null,
    Object? cpuDrawPile = null,
    Object? centerLeftPile = null,
    Object? centerRightPile = null,
    Object? selectedCardIndex = freezed,
    Object? result = freezed,
    Object? tickId = null,
  }) {
    return _then(
      _value.copyWith(
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as GamePhase,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as Difficulty,
            humanHand: null == humanHand
                ? _value.humanHand
                : humanHand // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            cpuHand: null == cpuHand
                ? _value.cpuHand
                : cpuHand // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            humanDrawPile: null == humanDrawPile
                ? _value.humanDrawPile
                : humanDrawPile // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            cpuDrawPile: null == cpuDrawPile
                ? _value.cpuDrawPile
                : cpuDrawPile // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            centerLeftPile: null == centerLeftPile
                ? _value.centerLeftPile
                : centerLeftPile // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            centerRightPile: null == centerRightPile
                ? _value.centerRightPile
                : centerRightPile // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            selectedCardIndex: freezed == selectedCardIndex
                ? _value.selectedCardIndex
                : selectedCardIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as GameResult?,
            tickId: null == tickId
                ? _value.tickId
                : tickId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStateImplCopyWith<$Res>
    implements $GameStateCopyWith<$Res> {
  factory _$$GameStateImplCopyWith(
    _$GameStateImpl value,
    $Res Function(_$GameStateImpl) then,
  ) = __$$GameStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GamePhase phase,
    Difficulty difficulty,
    List<PlayingCard> humanHand,
    List<PlayingCard> cpuHand,
    List<PlayingCard> humanDrawPile,
    List<PlayingCard> cpuDrawPile,
    List<PlayingCard> centerLeftPile,
    List<PlayingCard> centerRightPile,
    int? selectedCardIndex,
    GameResult? result,
    int tickId,
  });
}

/// @nodoc
class __$$GameStateImplCopyWithImpl<$Res>
    extends _$GameStateCopyWithImpl<$Res, _$GameStateImpl>
    implements _$$GameStateImplCopyWith<$Res> {
  __$$GameStateImplCopyWithImpl(
    _$GameStateImpl _value,
    $Res Function(_$GameStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? difficulty = null,
    Object? humanHand = null,
    Object? cpuHand = null,
    Object? humanDrawPile = null,
    Object? cpuDrawPile = null,
    Object? centerLeftPile = null,
    Object? centerRightPile = null,
    Object? selectedCardIndex = freezed,
    Object? result = freezed,
    Object? tickId = null,
  }) {
    return _then(
      _$GameStateImpl(
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as GamePhase,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as Difficulty,
        humanHand: null == humanHand
            ? _value._humanHand
            : humanHand // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        cpuHand: null == cpuHand
            ? _value._cpuHand
            : cpuHand // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        humanDrawPile: null == humanDrawPile
            ? _value._humanDrawPile
            : humanDrawPile // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        cpuDrawPile: null == cpuDrawPile
            ? _value._cpuDrawPile
            : cpuDrawPile // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        centerLeftPile: null == centerLeftPile
            ? _value._centerLeftPile
            : centerLeftPile // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        centerRightPile: null == centerRightPile
            ? _value._centerRightPile
            : centerRightPile // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        selectedCardIndex: freezed == selectedCardIndex
            ? _value.selectedCardIndex
            : selectedCardIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as GameResult?,
        tickId: null == tickId
            ? _value.tickId
            : tickId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$GameStateImpl implements _GameState {
  const _$GameStateImpl({
    required this.phase,
    required this.difficulty,
    required final List<PlayingCard> humanHand,
    required final List<PlayingCard> cpuHand,
    required final List<PlayingCard> humanDrawPile,
    required final List<PlayingCard> cpuDrawPile,
    required final List<PlayingCard> centerLeftPile,
    required final List<PlayingCard> centerRightPile,
    this.selectedCardIndex,
    this.result,
    this.tickId = 0,
  }) : _humanHand = humanHand,
       _cpuHand = cpuHand,
       _humanDrawPile = humanDrawPile,
       _cpuDrawPile = cpuDrawPile,
       _centerLeftPile = centerLeftPile,
       _centerRightPile = centerRightPile;

  @override
  final GamePhase phase;
  @override
  final Difficulty difficulty;
  final List<PlayingCard> _humanHand;
  @override
  List<PlayingCard> get humanHand {
    if (_humanHand is EqualUnmodifiableListView) return _humanHand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_humanHand);
  }

  final List<PlayingCard> _cpuHand;
  @override
  List<PlayingCard> get cpuHand {
    if (_cpuHand is EqualUnmodifiableListView) return _cpuHand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cpuHand);
  }

  final List<PlayingCard> _humanDrawPile;
  @override
  List<PlayingCard> get humanDrawPile {
    if (_humanDrawPile is EqualUnmodifiableListView) return _humanDrawPile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_humanDrawPile);
  }

  final List<PlayingCard> _cpuDrawPile;
  @override
  List<PlayingCard> get cpuDrawPile {
    if (_cpuDrawPile is EqualUnmodifiableListView) return _cpuDrawPile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cpuDrawPile);
  }

  final List<PlayingCard> _centerLeftPile;
  @override
  List<PlayingCard> get centerLeftPile {
    if (_centerLeftPile is EqualUnmodifiableListView) return _centerLeftPile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_centerLeftPile);
  }

  final List<PlayingCard> _centerRightPile;
  @override
  List<PlayingCard> get centerRightPile {
    if (_centerRightPile is EqualUnmodifiableListView) return _centerRightPile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_centerRightPile);
  }

  @override
  final int? selectedCardIndex;
  @override
  final GameResult? result;
  @override
  @JsonKey()
  final int tickId;

  @override
  String toString() {
    return 'GameState(phase: $phase, difficulty: $difficulty, humanHand: $humanHand, cpuHand: $cpuHand, humanDrawPile: $humanDrawPile, cpuDrawPile: $cpuDrawPile, centerLeftPile: $centerLeftPile, centerRightPile: $centerRightPile, selectedCardIndex: $selectedCardIndex, result: $result, tickId: $tickId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(
              other._humanHand,
              _humanHand,
            ) &&
            const DeepCollectionEquality().equals(other._cpuHand, _cpuHand) &&
            const DeepCollectionEquality().equals(
              other._humanDrawPile,
              _humanDrawPile,
            ) &&
            const DeepCollectionEquality().equals(
              other._cpuDrawPile,
              _cpuDrawPile,
            ) &&
            const DeepCollectionEquality().equals(
              other._centerLeftPile,
              _centerLeftPile,
            ) &&
            const DeepCollectionEquality().equals(
              other._centerRightPile,
              _centerRightPile,
            ) &&
            (identical(other.selectedCardIndex, selectedCardIndex) ||
                other.selectedCardIndex == selectedCardIndex) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.tickId, tickId) || other.tickId == tickId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    phase,
    difficulty,
    const DeepCollectionEquality().hash(_humanHand),
    const DeepCollectionEquality().hash(_cpuHand),
    const DeepCollectionEquality().hash(_humanDrawPile),
    const DeepCollectionEquality().hash(_cpuDrawPile),
    const DeepCollectionEquality().hash(_centerLeftPile),
    const DeepCollectionEquality().hash(_centerRightPile),
    selectedCardIndex,
    result,
    tickId,
  );

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      __$$GameStateImplCopyWithImpl<_$GameStateImpl>(this, _$identity);
}

abstract class _GameState implements GameState {
  const factory _GameState({
    required final GamePhase phase,
    required final Difficulty difficulty,
    required final List<PlayingCard> humanHand,
    required final List<PlayingCard> cpuHand,
    required final List<PlayingCard> humanDrawPile,
    required final List<PlayingCard> cpuDrawPile,
    required final List<PlayingCard> centerLeftPile,
    required final List<PlayingCard> centerRightPile,
    final int? selectedCardIndex,
    final GameResult? result,
    final int tickId,
  }) = _$GameStateImpl;

  @override
  GamePhase get phase;
  @override
  Difficulty get difficulty;
  @override
  List<PlayingCard> get humanHand;
  @override
  List<PlayingCard> get cpuHand;
  @override
  List<PlayingCard> get humanDrawPile;
  @override
  List<PlayingCard> get cpuDrawPile;
  @override
  List<PlayingCard> get centerLeftPile;
  @override
  List<PlayingCard> get centerRightPile;
  @override
  int? get selectedCardIndex;
  @override
  GameResult? get result;
  @override
  int get tickId;

  /// Create a copy of GameState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateImplCopyWith<_$GameStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
