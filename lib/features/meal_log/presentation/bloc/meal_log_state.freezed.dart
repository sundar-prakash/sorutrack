// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_log_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealLogState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MealLogState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogState()';
  }
}

/// @nodoc
class $MealLogStateCopyWith<$Res> {
  $MealLogStateCopyWith(MealLogState _, $Res Function(MealLogState) __);
}

/// Adds pattern-matching-related methods to [MealLogState].
extension MealLogStatePatterns on MealLogState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Analyzing value)? analyzing,
    TResult Function(_Reviewing value)? reviewing,
    TResult Function(_Saving value)? saving,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Analyzing() when analyzing != null:
        return analyzing(_that);
      case _Reviewing() when reviewing != null:
        return reviewing(_that);
      case _Saving() when saving != null:
        return saving(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Analyzing value) analyzing,
    required TResult Function(_Reviewing value) reviewing,
    required TResult Function(_Saving value) saving,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Analyzing():
        return analyzing(_that);
      case _Reviewing():
        return reviewing(_that);
      case _Saving():
        return saving(_that);
      case _Success():
        return success(_that);
      case _Error():
        return error(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Analyzing value)? analyzing,
    TResult? Function(_Reviewing value)? reviewing,
    TResult? Function(_Saving value)? saving,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Analyzing() when analyzing != null:
        return analyzing(_that);
      case _Reviewing() when reviewing != null:
        return reviewing(_that);
      case _Saving() when saving != null:
        return saving(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? analyzing,
    TResult Function(ParsedMeal meal)? reviewing,
    TResult Function()? saving,
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Analyzing() when analyzing != null:
        return analyzing();
      case _Reviewing() when reviewing != null:
        return reviewing(_that.meal);
      case _Saving() when saving != null:
        return saving();
      case _Success() when success != null:
        return success();
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() analyzing,
    required TResult Function(ParsedMeal meal) reviewing,
    required TResult Function() saving,
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Analyzing():
        return analyzing();
      case _Reviewing():
        return reviewing(_that.meal);
      case _Saving():
        return saving();
      case _Success():
        return success();
      case _Error():
        return error(_that.message);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? analyzing,
    TResult? Function(ParsedMeal meal)? reviewing,
    TResult? Function()? saving,
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Analyzing() when analyzing != null:
        return analyzing();
      case _Reviewing() when reviewing != null:
        return reviewing(_that.meal);
      case _Saving() when saving != null:
        return saving();
      case _Success() when success != null:
        return success();
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements MealLogState {
  const _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogState.initial()';
  }
}

/// @nodoc

class _Analyzing implements MealLogState {
  const _Analyzing();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Analyzing);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogState.analyzing()';
  }
}

/// @nodoc

class _Reviewing implements MealLogState {
  const _Reviewing(this.meal);

  final ParsedMeal meal;

  /// Create a copy of MealLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReviewingCopyWith<_Reviewing> get copyWith =>
      __$ReviewingCopyWithImpl<_Reviewing>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Reviewing &&
            (identical(other.meal, meal) || other.meal == meal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meal);

  @override
  String toString() {
    return 'MealLogState.reviewing(meal: $meal)';
  }
}

/// @nodoc
abstract mixin class _$ReviewingCopyWith<$Res>
    implements $MealLogStateCopyWith<$Res> {
  factory _$ReviewingCopyWith(
          _Reviewing value, $Res Function(_Reviewing) _then) =
      __$ReviewingCopyWithImpl;
  @useResult
  $Res call({ParsedMeal meal});
}

/// @nodoc
class __$ReviewingCopyWithImpl<$Res> implements _$ReviewingCopyWith<$Res> {
  __$ReviewingCopyWithImpl(this._self, this._then);

  final _Reviewing _self;
  final $Res Function(_Reviewing) _then;

  /// Create a copy of MealLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? meal = null,
  }) {
    return _then(_Reviewing(
      null == meal
          ? _self.meal
          : meal // ignore: cast_nullable_to_non_nullable
              as ParsedMeal,
    ));
  }
}

/// @nodoc

class _Saving implements MealLogState {
  const _Saving();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Saving);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogState.saving()';
  }
}

/// @nodoc

class _Success implements MealLogState {
  const _Success();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Success);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogState.success()';
  }
}

/// @nodoc

class _Error implements MealLogState {
  const _Error(this.message);

  final String message;

  /// Create a copy of MealLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ErrorCopyWith<_Error> get copyWith =>
      __$ErrorCopyWithImpl<_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'MealLogState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $MealLogStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) =
      __$ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$ErrorCopyWithImpl<$Res> implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

  /// Create a copy of MealLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_Error(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
