// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_log_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealLogEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MealLogEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogEvent()';
  }
}

/// @nodoc
class $MealLogEventCopyWith<$Res> {
  $MealLogEventCopyWith(MealLogEvent _, $Res Function(MealLogEvent) __);
}

/// Adds pattern-matching-related methods to [MealLogEvent].
extension MealLogEventPatterns on MealLogEvent {
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
    TResult Function(ParseMealEvent value)? parseMeal,
    TResult Function(UpdateMealEvent value)? updateMeal,
    TResult Function(SaveMealEvent value)? saveMeal,
    TResult Function(ResetEvent value)? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent() when parseMeal != null:
        return parseMeal(_that);
      case UpdateMealEvent() when updateMeal != null:
        return updateMeal(_that);
      case SaveMealEvent() when saveMeal != null:
        return saveMeal(_that);
      case ResetEvent() when reset != null:
        return reset(_that);
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
    required TResult Function(ParseMealEvent value) parseMeal,
    required TResult Function(UpdateMealEvent value) updateMeal,
    required TResult Function(SaveMealEvent value) saveMeal,
    required TResult Function(ResetEvent value) reset,
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent():
        return parseMeal(_that);
      case UpdateMealEvent():
        return updateMeal(_that);
      case SaveMealEvent():
        return saveMeal(_that);
      case ResetEvent():
        return reset(_that);
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
    TResult? Function(ParseMealEvent value)? parseMeal,
    TResult? Function(UpdateMealEvent value)? updateMeal,
    TResult? Function(SaveMealEvent value)? saveMeal,
    TResult? Function(ResetEvent value)? reset,
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent() when parseMeal != null:
        return parseMeal(_that);
      case UpdateMealEvent() when updateMeal != null:
        return updateMeal(_that);
      case SaveMealEvent() when saveMeal != null:
        return saveMeal(_that);
      case ResetEvent() when reset != null:
        return reset(_that);
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
    TResult Function(String input, String mealType)? parseMeal,
    TResult Function(ParsedMeal meal)? updateMeal,
    TResult Function(ParsedMeal meal)? saveMeal,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent() when parseMeal != null:
        return parseMeal(_that.input, _that.mealType);
      case UpdateMealEvent() when updateMeal != null:
        return updateMeal(_that.meal);
      case SaveMealEvent() when saveMeal != null:
        return saveMeal(_that.meal);
      case ResetEvent() when reset != null:
        return reset();
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
    required TResult Function(String input, String mealType) parseMeal,
    required TResult Function(ParsedMeal meal) updateMeal,
    required TResult Function(ParsedMeal meal) saveMeal,
    required TResult Function() reset,
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent():
        return parseMeal(_that.input, _that.mealType);
      case UpdateMealEvent():
        return updateMeal(_that.meal);
      case SaveMealEvent():
        return saveMeal(_that.meal);
      case ResetEvent():
        return reset();
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
    TResult? Function(String input, String mealType)? parseMeal,
    TResult? Function(ParsedMeal meal)? updateMeal,
    TResult? Function(ParsedMeal meal)? saveMeal,
    TResult? Function()? reset,
  }) {
    final _that = this;
    switch (_that) {
      case ParseMealEvent() when parseMeal != null:
        return parseMeal(_that.input, _that.mealType);
      case UpdateMealEvent() when updateMeal != null:
        return updateMeal(_that.meal);
      case SaveMealEvent() when saveMeal != null:
        return saveMeal(_that.meal);
      case ResetEvent() when reset != null:
        return reset();
      case _:
        return null;
    }
  }
}

/// @nodoc

class ParseMealEvent implements MealLogEvent {
  const ParseMealEvent(this.input, this.mealType);

  final String input;
  final String mealType;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ParseMealEventCopyWith<ParseMealEvent> get copyWith =>
      _$ParseMealEventCopyWithImpl<ParseMealEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ParseMealEvent &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, input, mealType);

  @override
  String toString() {
    return 'MealLogEvent.parseMeal(input: $input, mealType: $mealType)';
  }
}

/// @nodoc
abstract mixin class $ParseMealEventCopyWith<$Res>
    implements $MealLogEventCopyWith<$Res> {
  factory $ParseMealEventCopyWith(
          ParseMealEvent value, $Res Function(ParseMealEvent) _then) =
      _$ParseMealEventCopyWithImpl;
  @useResult
  $Res call({String input, String mealType});
}

/// @nodoc
class _$ParseMealEventCopyWithImpl<$Res>
    implements $ParseMealEventCopyWith<$Res> {
  _$ParseMealEventCopyWithImpl(this._self, this._then);

  final ParseMealEvent _self;
  final $Res Function(ParseMealEvent) _then;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? input = null,
    Object? mealType = null,
  }) {
    return _then(ParseMealEvent(
      null == input
          ? _self.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      null == mealType
          ? _self.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UpdateMealEvent implements MealLogEvent {
  const UpdateMealEvent(this.meal);

  final ParsedMeal meal;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateMealEventCopyWith<UpdateMealEvent> get copyWith =>
      _$UpdateMealEventCopyWithImpl<UpdateMealEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateMealEvent &&
            (identical(other.meal, meal) || other.meal == meal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meal);

  @override
  String toString() {
    return 'MealLogEvent.updateMeal(meal: $meal)';
  }
}

/// @nodoc
abstract mixin class $UpdateMealEventCopyWith<$Res>
    implements $MealLogEventCopyWith<$Res> {
  factory $UpdateMealEventCopyWith(
          UpdateMealEvent value, $Res Function(UpdateMealEvent) _then) =
      _$UpdateMealEventCopyWithImpl;
  @useResult
  $Res call({ParsedMeal meal});
}

/// @nodoc
class _$UpdateMealEventCopyWithImpl<$Res>
    implements $UpdateMealEventCopyWith<$Res> {
  _$UpdateMealEventCopyWithImpl(this._self, this._then);

  final UpdateMealEvent _self;
  final $Res Function(UpdateMealEvent) _then;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? meal = null,
  }) {
    return _then(UpdateMealEvent(
      null == meal
          ? _self.meal
          : meal // ignore: cast_nullable_to_non_nullable
              as ParsedMeal,
    ));
  }
}

/// @nodoc

class SaveMealEvent implements MealLogEvent {
  const SaveMealEvent(this.meal);

  final ParsedMeal meal;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SaveMealEventCopyWith<SaveMealEvent> get copyWith =>
      _$SaveMealEventCopyWithImpl<SaveMealEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SaveMealEvent &&
            (identical(other.meal, meal) || other.meal == meal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, meal);

  @override
  String toString() {
    return 'MealLogEvent.saveMeal(meal: $meal)';
  }
}

/// @nodoc
abstract mixin class $SaveMealEventCopyWith<$Res>
    implements $MealLogEventCopyWith<$Res> {
  factory $SaveMealEventCopyWith(
          SaveMealEvent value, $Res Function(SaveMealEvent) _then) =
      _$SaveMealEventCopyWithImpl;
  @useResult
  $Res call({ParsedMeal meal});
}

/// @nodoc
class _$SaveMealEventCopyWithImpl<$Res>
    implements $SaveMealEventCopyWith<$Res> {
  _$SaveMealEventCopyWithImpl(this._self, this._then);

  final SaveMealEvent _self;
  final $Res Function(SaveMealEvent) _then;

  /// Create a copy of MealLogEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? meal = null,
  }) {
    return _then(SaveMealEvent(
      null == meal
          ? _self.meal
          : meal // ignore: cast_nullable_to_non_nullable
              as ParsedMeal,
    ));
  }
}

/// @nodoc

class ResetEvent implements MealLogEvent {
  const ResetEvent();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ResetEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MealLogEvent.reset()';
  }
}

// dart format on
