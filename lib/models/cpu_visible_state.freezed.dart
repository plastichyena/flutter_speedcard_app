// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cpu_visible_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CpuVisibleState {
  List<PlayingCard> get cpuHand => throw _privateConstructorUsedError;
  PlayingCard get centerLeftFieldCard => throw _privateConstructorUsedError;
  PlayingCard get centerRightFieldCard => throw _privateConstructorUsedError;

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CpuVisibleStateCopyWith<CpuVisibleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CpuVisibleStateCopyWith<$Res> {
  factory $CpuVisibleStateCopyWith(
    CpuVisibleState value,
    $Res Function(CpuVisibleState) then,
  ) = _$CpuVisibleStateCopyWithImpl<$Res, CpuVisibleState>;
  @useResult
  $Res call({
    List<PlayingCard> cpuHand,
    PlayingCard centerLeftFieldCard,
    PlayingCard centerRightFieldCard,
  });

  $PlayingCardCopyWith<$Res> get centerLeftFieldCard;
  $PlayingCardCopyWith<$Res> get centerRightFieldCard;
}

/// @nodoc
class _$CpuVisibleStateCopyWithImpl<$Res, $Val extends CpuVisibleState>
    implements $CpuVisibleStateCopyWith<$Res> {
  _$CpuVisibleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuHand = null,
    Object? centerLeftFieldCard = null,
    Object? centerRightFieldCard = null,
  }) {
    return _then(
      _value.copyWith(
            cpuHand: null == cpuHand
                ? _value.cpuHand
                : cpuHand // ignore: cast_nullable_to_non_nullable
                      as List<PlayingCard>,
            centerLeftFieldCard: null == centerLeftFieldCard
                ? _value.centerLeftFieldCard
                : centerLeftFieldCard // ignore: cast_nullable_to_non_nullable
                      as PlayingCard,
            centerRightFieldCard: null == centerRightFieldCard
                ? _value.centerRightFieldCard
                : centerRightFieldCard // ignore: cast_nullable_to_non_nullable
                      as PlayingCard,
          )
          as $Val,
    );
  }

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayingCardCopyWith<$Res> get centerLeftFieldCard {
    return $PlayingCardCopyWith<$Res>(_value.centerLeftFieldCard, (value) {
      return _then(_value.copyWith(centerLeftFieldCard: value) as $Val);
    });
  }

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayingCardCopyWith<$Res> get centerRightFieldCard {
    return $PlayingCardCopyWith<$Res>(_value.centerRightFieldCard, (value) {
      return _then(_value.copyWith(centerRightFieldCard: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CpuVisibleStateImplCopyWith<$Res>
    implements $CpuVisibleStateCopyWith<$Res> {
  factory _$$CpuVisibleStateImplCopyWith(
    _$CpuVisibleStateImpl value,
    $Res Function(_$CpuVisibleStateImpl) then,
  ) = __$$CpuVisibleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PlayingCard> cpuHand,
    PlayingCard centerLeftFieldCard,
    PlayingCard centerRightFieldCard,
  });

  @override
  $PlayingCardCopyWith<$Res> get centerLeftFieldCard;
  @override
  $PlayingCardCopyWith<$Res> get centerRightFieldCard;
}

/// @nodoc
class __$$CpuVisibleStateImplCopyWithImpl<$Res>
    extends _$CpuVisibleStateCopyWithImpl<$Res, _$CpuVisibleStateImpl>
    implements _$$CpuVisibleStateImplCopyWith<$Res> {
  __$$CpuVisibleStateImplCopyWithImpl(
    _$CpuVisibleStateImpl _value,
    $Res Function(_$CpuVisibleStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuHand = null,
    Object? centerLeftFieldCard = null,
    Object? centerRightFieldCard = null,
  }) {
    return _then(
      _$CpuVisibleStateImpl(
        cpuHand: null == cpuHand
            ? _value._cpuHand
            : cpuHand // ignore: cast_nullable_to_non_nullable
                  as List<PlayingCard>,
        centerLeftFieldCard: null == centerLeftFieldCard
            ? _value.centerLeftFieldCard
            : centerLeftFieldCard // ignore: cast_nullable_to_non_nullable
                  as PlayingCard,
        centerRightFieldCard: null == centerRightFieldCard
            ? _value.centerRightFieldCard
            : centerRightFieldCard // ignore: cast_nullable_to_non_nullable
                  as PlayingCard,
      ),
    );
  }
}

/// @nodoc

class _$CpuVisibleStateImpl implements _CpuVisibleState {
  const _$CpuVisibleStateImpl({
    required final List<PlayingCard> cpuHand,
    required this.centerLeftFieldCard,
    required this.centerRightFieldCard,
  }) : _cpuHand = cpuHand;

  final List<PlayingCard> _cpuHand;
  @override
  List<PlayingCard> get cpuHand {
    if (_cpuHand is EqualUnmodifiableListView) return _cpuHand;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cpuHand);
  }

  @override
  final PlayingCard centerLeftFieldCard;
  @override
  final PlayingCard centerRightFieldCard;

  @override
  String toString() {
    return 'CpuVisibleState(cpuHand: $cpuHand, centerLeftFieldCard: $centerLeftFieldCard, centerRightFieldCard: $centerRightFieldCard)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CpuVisibleStateImpl &&
            const DeepCollectionEquality().equals(other._cpuHand, _cpuHand) &&
            (identical(other.centerLeftFieldCard, centerLeftFieldCard) ||
                other.centerLeftFieldCard == centerLeftFieldCard) &&
            (identical(other.centerRightFieldCard, centerRightFieldCard) ||
                other.centerRightFieldCard == centerRightFieldCard));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cpuHand),
    centerLeftFieldCard,
    centerRightFieldCard,
  );

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CpuVisibleStateImplCopyWith<_$CpuVisibleStateImpl> get copyWith =>
      __$$CpuVisibleStateImplCopyWithImpl<_$CpuVisibleStateImpl>(
        this,
        _$identity,
      );
}

abstract class _CpuVisibleState implements CpuVisibleState {
  const factory _CpuVisibleState({
    required final List<PlayingCard> cpuHand,
    required final PlayingCard centerLeftFieldCard,
    required final PlayingCard centerRightFieldCard,
  }) = _$CpuVisibleStateImpl;

  @override
  List<PlayingCard> get cpuHand;
  @override
  PlayingCard get centerLeftFieldCard;
  @override
  PlayingCard get centerRightFieldCard;

  /// Create a copy of CpuVisibleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CpuVisibleStateImplCopyWith<_$CpuVisibleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
