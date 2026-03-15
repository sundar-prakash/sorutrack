// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingState {
  int get currentStep;
  String get name;
  int get age;
  Gender get gender;
  double get height;
  HeightUnit get heightUnit;
  double get weight;
  WeightUnit get weightUnit;
  ActivityLevel get activityLevel;
  GoalType get goal;
  double get targetWeight;
  double get weeklyGoal;
  DateTime? get targetDate;
  DietaryPreference get dietaryPreference;
  List<String> get allergies;
  List<String> get cuisines;
  DateTime? get mealReminderMorning;
  DateTime? get mealReminderAfternoon;
  DateTime? get mealReminderEvening;
  int get waterReminderIntervalMinutes;
  String get geminiApiKey;
  bool get isSubmitting;
  String? get error;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      _$OnboardingStateCopyWithImpl<OnboardingState>(
          this as OnboardingState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingState &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.heightUnit, heightUnit) ||
                other.heightUnit == heightUnit) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.weeklyGoal, weeklyGoal) ||
                other.weeklyGoal == weeklyGoal) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.dietaryPreference, dietaryPreference) ||
                other.dietaryPreference == dietaryPreference) &&
            const DeepCollectionEquality().equals(other.allergies, allergies) &&
            const DeepCollectionEquality().equals(other.cuisines, cuisines) &&
            (identical(other.mealReminderMorning, mealReminderMorning) ||
                other.mealReminderMorning == mealReminderMorning) &&
            (identical(other.mealReminderAfternoon, mealReminderAfternoon) ||
                other.mealReminderAfternoon == mealReminderAfternoon) &&
            (identical(other.mealReminderEvening, mealReminderEvening) ||
                other.mealReminderEvening == mealReminderEvening) &&
            (identical(other.waterReminderIntervalMinutes,
                    waterReminderIntervalMinutes) ||
                other.waterReminderIntervalMinutes ==
                    waterReminderIntervalMinutes) &&
            (identical(other.geminiApiKey, geminiApiKey) ||
                other.geminiApiKey == geminiApiKey) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        currentStep,
        name,
        age,
        gender,
        height,
        heightUnit,
        weight,
        weightUnit,
        activityLevel,
        goal,
        targetWeight,
        weeklyGoal,
        targetDate,
        dietaryPreference,
        const DeepCollectionEquality().hash(allergies),
        const DeepCollectionEquality().hash(cuisines),
        mealReminderMorning,
        mealReminderAfternoon,
        mealReminderEvening,
        waterReminderIntervalMinutes,
        geminiApiKey,
        isSubmitting,
        error
      ]);

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, name: $name, age: $age, gender: $gender, height: $height, heightUnit: $heightUnit, weight: $weight, weightUnit: $weightUnit, activityLevel: $activityLevel, goal: $goal, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, targetDate: $targetDate, dietaryPreference: $dietaryPreference, allergies: $allergies, cuisines: $cuisines, mealReminderMorning: $mealReminderMorning, mealReminderAfternoon: $mealReminderAfternoon, mealReminderEvening: $mealReminderEvening, waterReminderIntervalMinutes: $waterReminderIntervalMinutes, geminiApiKey: $geminiApiKey, isSubmitting: $isSubmitting, error: $error)';
  }
}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
          OnboardingState value, $Res Function(OnboardingState) _then) =
      _$OnboardingStateCopyWithImpl;
  @useResult
  $Res call(
      {int currentStep,
      String name,
      int age,
      Gender gender,
      double height,
      HeightUnit heightUnit,
      double weight,
      WeightUnit weightUnit,
      ActivityLevel activityLevel,
      GoalType goal,
      double targetWeight,
      double weeklyGoal,
      DateTime? targetDate,
      DietaryPreference dietaryPreference,
      List<String> allergies,
      List<String> cuisines,
      DateTime? mealReminderMorning,
      DateTime? mealReminderAfternoon,
      DateTime? mealReminderEvening,
      int waterReminderIntervalMinutes,
      String geminiApiKey,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? height = null,
    Object? heightUnit = null,
    Object? weight = null,
    Object? weightUnit = null,
    Object? activityLevel = null,
    Object? goal = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? targetDate = freezed,
    Object? dietaryPreference = null,
    Object? allergies = null,
    Object? cuisines = null,
    Object? mealReminderMorning = freezed,
    Object? mealReminderAfternoon = freezed,
    Object? mealReminderEvening = freezed,
    Object? waterReminderIntervalMinutes = null,
    Object? geminiApiKey = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      heightUnit: null == heightUnit
          ? _self.heightUnit
          : heightUnit // ignore: cast_nullable_to_non_nullable
              as HeightUnit,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      weightUnit: null == weightUnit
          ? _self.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      activityLevel: null == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as GoalType,
      targetWeight: null == targetWeight
          ? _self.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGoal: null == weeklyGoal
          ? _self.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: freezed == targetDate
          ? _self.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dietaryPreference: null == dietaryPreference
          ? _self.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as DietaryPreference,
      allergies: null == allergies
          ? _self.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cuisines: null == cuisines
          ? _self.cuisines
          : cuisines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mealReminderMorning: freezed == mealReminderMorning
          ? _self.mealReminderMorning
          : mealReminderMorning // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mealReminderAfternoon: freezed == mealReminderAfternoon
          ? _self.mealReminderAfternoon
          : mealReminderAfternoon // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mealReminderEvening: freezed == mealReminderEvening
          ? _self.mealReminderEvening
          : mealReminderEvening // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      waterReminderIntervalMinutes: null == waterReminderIntervalMinutes
          ? _self.waterReminderIntervalMinutes
          : waterReminderIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      geminiApiKey: null == geminiApiKey
          ? _self.geminiApiKey
          : geminiApiKey // ignore: cast_nullable_to_non_nullable
              as String,
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OnboardingState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_OnboardingState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OnboardingState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int currentStep,
            String name,
            int age,
            Gender gender,
            double height,
            HeightUnit heightUnit,
            double weight,
            WeightUnit weightUnit,
            ActivityLevel activityLevel,
            GoalType goal,
            double targetWeight,
            double weeklyGoal,
            DateTime? targetDate,
            DietaryPreference dietaryPreference,
            List<String> allergies,
            List<String> cuisines,
            DateTime? mealReminderMorning,
            DateTime? mealReminderAfternoon,
            DateTime? mealReminderEvening,
            int waterReminderIntervalMinutes,
            String geminiApiKey,
            bool isSubmitting,
            String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
        return $default(
            _that.currentStep,
            _that.name,
            _that.age,
            _that.gender,
            _that.height,
            _that.heightUnit,
            _that.weight,
            _that.weightUnit,
            _that.activityLevel,
            _that.goal,
            _that.targetWeight,
            _that.weeklyGoal,
            _that.targetDate,
            _that.dietaryPreference,
            _that.allergies,
            _that.cuisines,
            _that.mealReminderMorning,
            _that.mealReminderAfternoon,
            _that.mealReminderEvening,
            _that.waterReminderIntervalMinutes,
            _that.geminiApiKey,
            _that.isSubmitting,
            _that.error);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            int currentStep,
            String name,
            int age,
            Gender gender,
            double height,
            HeightUnit heightUnit,
            double weight,
            WeightUnit weightUnit,
            ActivityLevel activityLevel,
            GoalType goal,
            double targetWeight,
            double weeklyGoal,
            DateTime? targetDate,
            DietaryPreference dietaryPreference,
            List<String> allergies,
            List<String> cuisines,
            DateTime? mealReminderMorning,
            DateTime? mealReminderAfternoon,
            DateTime? mealReminderEvening,
            int waterReminderIntervalMinutes,
            String geminiApiKey,
            bool isSubmitting,
            String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState():
        return $default(
            _that.currentStep,
            _that.name,
            _that.age,
            _that.gender,
            _that.height,
            _that.heightUnit,
            _that.weight,
            _that.weightUnit,
            _that.activityLevel,
            _that.goal,
            _that.targetWeight,
            _that.weeklyGoal,
            _that.targetDate,
            _that.dietaryPreference,
            _that.allergies,
            _that.cuisines,
            _that.mealReminderMorning,
            _that.mealReminderAfternoon,
            _that.mealReminderEvening,
            _that.waterReminderIntervalMinutes,
            _that.geminiApiKey,
            _that.isSubmitting,
            _that.error);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int currentStep,
            String name,
            int age,
            Gender gender,
            double height,
            HeightUnit heightUnit,
            double weight,
            WeightUnit weightUnit,
            ActivityLevel activityLevel,
            GoalType goal,
            double targetWeight,
            double weeklyGoal,
            DateTime? targetDate,
            DietaryPreference dietaryPreference,
            List<String> allergies,
            List<String> cuisines,
            DateTime? mealReminderMorning,
            DateTime? mealReminderAfternoon,
            DateTime? mealReminderEvening,
            int waterReminderIntervalMinutes,
            String geminiApiKey,
            bool isSubmitting,
            String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
        return $default(
            _that.currentStep,
            _that.name,
            _that.age,
            _that.gender,
            _that.height,
            _that.heightUnit,
            _that.weight,
            _that.weightUnit,
            _that.activityLevel,
            _that.goal,
            _that.targetWeight,
            _that.weeklyGoal,
            _that.targetDate,
            _that.dietaryPreference,
            _that.allergies,
            _that.cuisines,
            _that.mealReminderMorning,
            _that.mealReminderAfternoon,
            _that.mealReminderEvening,
            _that.waterReminderIntervalMinutes,
            _that.geminiApiKey,
            _that.isSubmitting,
            _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OnboardingState implements OnboardingState {
  const _OnboardingState(
      {this.currentStep = 0,
      this.name = '',
      this.age = 25,
      this.gender = Gender.male,
      this.height = 170,
      this.heightUnit = HeightUnit.cm,
      this.weight = 70,
      this.weightUnit = WeightUnit.kg,
      this.activityLevel = ActivityLevel.sedentary,
      this.goal = GoalType.maintain,
      this.targetWeight = 70,
      this.weeklyGoal = 0.5,
      this.targetDate,
      this.dietaryPreference = DietaryPreference.nonVeg,
      final List<String> allergies = const [],
      final List<String> cuisines = const [],
      this.mealReminderMorning,
      this.mealReminderAfternoon,
      this.mealReminderEvening,
      this.waterReminderIntervalMinutes = 60,
      this.geminiApiKey = '',
      this.isSubmitting = false,
      this.error})
      : _allergies = allergies,
        _cuisines = cuisines;

  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final int age;
  @override
  @JsonKey()
  final Gender gender;
  @override
  @JsonKey()
  final double height;
  @override
  @JsonKey()
  final HeightUnit heightUnit;
  @override
  @JsonKey()
  final double weight;
  @override
  @JsonKey()
  final WeightUnit weightUnit;
  @override
  @JsonKey()
  final ActivityLevel activityLevel;
  @override
  @JsonKey()
  final GoalType goal;
  @override
  @JsonKey()
  final double targetWeight;
  @override
  @JsonKey()
  final double weeklyGoal;
  @override
  final DateTime? targetDate;
  @override
  @JsonKey()
  final DietaryPreference dietaryPreference;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _cuisines;
  @override
  @JsonKey()
  List<String> get cuisines {
    if (_cuisines is EqualUnmodifiableListView) return _cuisines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cuisines);
  }

  @override
  final DateTime? mealReminderMorning;
  @override
  final DateTime? mealReminderAfternoon;
  @override
  final DateTime? mealReminderEvening;
  @override
  @JsonKey()
  final int waterReminderIntervalMinutes;
  @override
  @JsonKey()
  final String geminiApiKey;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingStateCopyWith<_OnboardingState> get copyWith =>
      __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingState &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.heightUnit, heightUnit) ||
                other.heightUnit == heightUnit) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.weeklyGoal, weeklyGoal) ||
                other.weeklyGoal == weeklyGoal) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.dietaryPreference, dietaryPreference) ||
                other.dietaryPreference == dietaryPreference) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            const DeepCollectionEquality().equals(other._cuisines, _cuisines) &&
            (identical(other.mealReminderMorning, mealReminderMorning) ||
                other.mealReminderMorning == mealReminderMorning) &&
            (identical(other.mealReminderAfternoon, mealReminderAfternoon) ||
                other.mealReminderAfternoon == mealReminderAfternoon) &&
            (identical(other.mealReminderEvening, mealReminderEvening) ||
                other.mealReminderEvening == mealReminderEvening) &&
            (identical(other.waterReminderIntervalMinutes,
                    waterReminderIntervalMinutes) ||
                other.waterReminderIntervalMinutes ==
                    waterReminderIntervalMinutes) &&
            (identical(other.geminiApiKey, geminiApiKey) ||
                other.geminiApiKey == geminiApiKey) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        currentStep,
        name,
        age,
        gender,
        height,
        heightUnit,
        weight,
        weightUnit,
        activityLevel,
        goal,
        targetWeight,
        weeklyGoal,
        targetDate,
        dietaryPreference,
        const DeepCollectionEquality().hash(_allergies),
        const DeepCollectionEquality().hash(_cuisines),
        mealReminderMorning,
        mealReminderAfternoon,
        mealReminderEvening,
        waterReminderIntervalMinutes,
        geminiApiKey,
        isSubmitting,
        error
      ]);

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, name: $name, age: $age, gender: $gender, height: $height, heightUnit: $heightUnit, weight: $weight, weightUnit: $weightUnit, activityLevel: $activityLevel, goal: $goal, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, targetDate: $targetDate, dietaryPreference: $dietaryPreference, allergies: $allergies, cuisines: $cuisines, mealReminderMorning: $mealReminderMorning, mealReminderAfternoon: $mealReminderAfternoon, mealReminderEvening: $mealReminderEvening, waterReminderIntervalMinutes: $waterReminderIntervalMinutes, geminiApiKey: $geminiApiKey, isSubmitting: $isSubmitting, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(
          _OnboardingState value, $Res Function(_OnboardingState) _then) =
      __$OnboardingStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int currentStep,
      String name,
      int age,
      Gender gender,
      double height,
      HeightUnit heightUnit,
      double weight,
      WeightUnit weightUnit,
      ActivityLevel activityLevel,
      GoalType goal,
      double targetWeight,
      double weeklyGoal,
      DateTime? targetDate,
      DietaryPreference dietaryPreference,
      List<String> allergies,
      List<String> cuisines,
      DateTime? mealReminderMorning,
      DateTime? mealReminderAfternoon,
      DateTime? mealReminderEvening,
      int waterReminderIntervalMinutes,
      String geminiApiKey,
      bool isSubmitting,
      String? error});
}

/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentStep = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? height = null,
    Object? heightUnit = null,
    Object? weight = null,
    Object? weightUnit = null,
    Object? activityLevel = null,
    Object? goal = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? targetDate = freezed,
    Object? dietaryPreference = null,
    Object? allergies = null,
    Object? cuisines = null,
    Object? mealReminderMorning = freezed,
    Object? mealReminderAfternoon = freezed,
    Object? mealReminderEvening = freezed,
    Object? waterReminderIntervalMinutes = null,
    Object? geminiApiKey = null,
    Object? isSubmitting = null,
    Object? error = freezed,
  }) {
    return _then(_OnboardingState(
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _self.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      heightUnit: null == heightUnit
          ? _self.heightUnit
          : heightUnit // ignore: cast_nullable_to_non_nullable
              as HeightUnit,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      weightUnit: null == weightUnit
          ? _self.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as WeightUnit,
      activityLevel: null == activityLevel
          ? _self.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      goal: null == goal
          ? _self.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as GoalType,
      targetWeight: null == targetWeight
          ? _self.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGoal: null == weeklyGoal
          ? _self.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: freezed == targetDate
          ? _self.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dietaryPreference: null == dietaryPreference
          ? _self.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as DietaryPreference,
      allergies: null == allergies
          ? _self._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      cuisines: null == cuisines
          ? _self._cuisines
          : cuisines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mealReminderMorning: freezed == mealReminderMorning
          ? _self.mealReminderMorning
          : mealReminderMorning // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mealReminderAfternoon: freezed == mealReminderAfternoon
          ? _self.mealReminderAfternoon
          : mealReminderAfternoon // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mealReminderEvening: freezed == mealReminderEvening
          ? _self.mealReminderEvening
          : mealReminderEvening // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      waterReminderIntervalMinutes: null == waterReminderIntervalMinutes
          ? _self.waterReminderIntervalMinutes
          : waterReminderIntervalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      geminiApiKey: null == geminiApiKey
          ? _self.geminiApiKey
          : geminiApiKey // ignore: cast_nullable_to_non_nullable
              as String,
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
