// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String? get id; String get name; int get age; Gender get gender; double get height; HeightUnit get heightUnit; double get weight; WeightUnit get weightUnit; ActivityLevel get activityLevel; GoalType get goal; double get targetWeight; double get weeklyGoal; DateTime? get targetDate; DietaryPreference get dietaryPreference; List<String> get allergies; List<String> get cuisines; DateTime get mealReminderMorning; DateTime get mealReminderAfternoon; DateTime get mealReminderEvening; int get waterReminderIntervalMinutes; bool get isOnboarded; double? get bodyFatPercentage; bool get isPregnant; bool get isLactating;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.height, height) || other.height == height)&&(identical(other.heightUnit, heightUnit) || other.heightUnit == heightUnit)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.weeklyGoal, weeklyGoal) || other.weeklyGoal == weeklyGoal)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&const DeepCollectionEquality().equals(other.allergies, allergies)&&const DeepCollectionEquality().equals(other.cuisines, cuisines)&&(identical(other.mealReminderMorning, mealReminderMorning) || other.mealReminderMorning == mealReminderMorning)&&(identical(other.mealReminderAfternoon, mealReminderAfternoon) || other.mealReminderAfternoon == mealReminderAfternoon)&&(identical(other.mealReminderEvening, mealReminderEvening) || other.mealReminderEvening == mealReminderEvening)&&(identical(other.waterReminderIntervalMinutes, waterReminderIntervalMinutes) || other.waterReminderIntervalMinutes == waterReminderIntervalMinutes)&&(identical(other.isOnboarded, isOnboarded) || other.isOnboarded == isOnboarded)&&(identical(other.bodyFatPercentage, bodyFatPercentage) || other.bodyFatPercentage == bodyFatPercentage)&&(identical(other.isPregnant, isPregnant) || other.isPregnant == isPregnant)&&(identical(other.isLactating, isLactating) || other.isLactating == isLactating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,age,gender,height,heightUnit,weight,weightUnit,activityLevel,goal,targetWeight,weeklyGoal,targetDate,dietaryPreference,const DeepCollectionEquality().hash(allergies),const DeepCollectionEquality().hash(cuisines),mealReminderMorning,mealReminderAfternoon,mealReminderEvening,waterReminderIntervalMinutes,isOnboarded,bodyFatPercentage,isPregnant,isLactating]);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, age: $age, gender: $gender, height: $height, heightUnit: $heightUnit, weight: $weight, weightUnit: $weightUnit, activityLevel: $activityLevel, goal: $goal, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, targetDate: $targetDate, dietaryPreference: $dietaryPreference, allergies: $allergies, cuisines: $cuisines, mealReminderMorning: $mealReminderMorning, mealReminderAfternoon: $mealReminderAfternoon, mealReminderEvening: $mealReminderEvening, waterReminderIntervalMinutes: $waterReminderIntervalMinutes, isOnboarded: $isOnboarded, bodyFatPercentage: $bodyFatPercentage, isPregnant: $isPregnant, isLactating: $isLactating)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String? id, String name, int age, Gender gender, double height, HeightUnit heightUnit, double weight, WeightUnit weightUnit, ActivityLevel activityLevel, GoalType goal, double targetWeight, double weeklyGoal, DateTime? targetDate, DietaryPreference dietaryPreference, List<String> allergies, List<String> cuisines, DateTime mealReminderMorning, DateTime mealReminderAfternoon, DateTime mealReminderEvening, int waterReminderIntervalMinutes, bool isOnboarded, double? bodyFatPercentage, bool isPregnant, bool isLactating
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? age = null,Object? gender = null,Object? height = null,Object? heightUnit = null,Object? weight = null,Object? weightUnit = null,Object? activityLevel = null,Object? goal = null,Object? targetWeight = null,Object? weeklyGoal = null,Object? targetDate = freezed,Object? dietaryPreference = null,Object? allergies = null,Object? cuisines = null,Object? mealReminderMorning = null,Object? mealReminderAfternoon = null,Object? mealReminderEvening = null,Object? waterReminderIntervalMinutes = null,Object? isOnboarded = null,Object? bodyFatPercentage = freezed,Object? isPregnant = null,Object? isLactating = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,heightUnit: null == heightUnit ? _self.heightUnit : heightUnit // ignore: cast_nullable_to_non_nullable
as HeightUnit,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as WeightUnit,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as GoalType,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,weeklyGoal: null == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as DietaryPreference,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,cuisines: null == cuisines ? _self.cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<String>,mealReminderMorning: null == mealReminderMorning ? _self.mealReminderMorning : mealReminderMorning // ignore: cast_nullable_to_non_nullable
as DateTime,mealReminderAfternoon: null == mealReminderAfternoon ? _self.mealReminderAfternoon : mealReminderAfternoon // ignore: cast_nullable_to_non_nullable
as DateTime,mealReminderEvening: null == mealReminderEvening ? _self.mealReminderEvening : mealReminderEvening // ignore: cast_nullable_to_non_nullable
as DateTime,waterReminderIntervalMinutes: null == waterReminderIntervalMinutes ? _self.waterReminderIntervalMinutes : waterReminderIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,isOnboarded: null == isOnboarded ? _self.isOnboarded : isOnboarded // ignore: cast_nullable_to_non_nullable
as bool,bodyFatPercentage: freezed == bodyFatPercentage ? _self.bodyFatPercentage : bodyFatPercentage // ignore: cast_nullable_to_non_nullable
as double?,isPregnant: null == isPregnant ? _self.isPregnant : isPregnant // ignore: cast_nullable_to_non_nullable
as bool,isLactating: null == isLactating ? _self.isLactating : isLactating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  int age,  Gender gender,  double height,  HeightUnit heightUnit,  double weight,  WeightUnit weightUnit,  ActivityLevel activityLevel,  GoalType goal,  double targetWeight,  double weeklyGoal,  DateTime? targetDate,  DietaryPreference dietaryPreference,  List<String> allergies,  List<String> cuisines,  DateTime mealReminderMorning,  DateTime mealReminderAfternoon,  DateTime mealReminderEvening,  int waterReminderIntervalMinutes,  bool isOnboarded,  double? bodyFatPercentage,  bool isPregnant,  bool isLactating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.gender,_that.height,_that.heightUnit,_that.weight,_that.weightUnit,_that.activityLevel,_that.goal,_that.targetWeight,_that.weeklyGoal,_that.targetDate,_that.dietaryPreference,_that.allergies,_that.cuisines,_that.mealReminderMorning,_that.mealReminderAfternoon,_that.mealReminderEvening,_that.waterReminderIntervalMinutes,_that.isOnboarded,_that.bodyFatPercentage,_that.isPregnant,_that.isLactating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  int age,  Gender gender,  double height,  HeightUnit heightUnit,  double weight,  WeightUnit weightUnit,  ActivityLevel activityLevel,  GoalType goal,  double targetWeight,  double weeklyGoal,  DateTime? targetDate,  DietaryPreference dietaryPreference,  List<String> allergies,  List<String> cuisines,  DateTime mealReminderMorning,  DateTime mealReminderAfternoon,  DateTime mealReminderEvening,  int waterReminderIntervalMinutes,  bool isOnboarded,  double? bodyFatPercentage,  bool isPregnant,  bool isLactating)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.name,_that.age,_that.gender,_that.height,_that.heightUnit,_that.weight,_that.weightUnit,_that.activityLevel,_that.goal,_that.targetWeight,_that.weeklyGoal,_that.targetDate,_that.dietaryPreference,_that.allergies,_that.cuisines,_that.mealReminderMorning,_that.mealReminderAfternoon,_that.mealReminderEvening,_that.waterReminderIntervalMinutes,_that.isOnboarded,_that.bodyFatPercentage,_that.isPregnant,_that.isLactating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  int age,  Gender gender,  double height,  HeightUnit heightUnit,  double weight,  WeightUnit weightUnit,  ActivityLevel activityLevel,  GoalType goal,  double targetWeight,  double weeklyGoal,  DateTime? targetDate,  DietaryPreference dietaryPreference,  List<String> allergies,  List<String> cuisines,  DateTime mealReminderMorning,  DateTime mealReminderAfternoon,  DateTime mealReminderEvening,  int waterReminderIntervalMinutes,  bool isOnboarded,  double? bodyFatPercentage,  bool isPregnant,  bool isLactating)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.gender,_that.height,_that.heightUnit,_that.weight,_that.weightUnit,_that.activityLevel,_that.goal,_that.targetWeight,_that.weeklyGoal,_that.targetDate,_that.dietaryPreference,_that.allergies,_that.cuisines,_that.mealReminderMorning,_that.mealReminderAfternoon,_that.mealReminderEvening,_that.waterReminderIntervalMinutes,_that.isOnboarded,_that.bodyFatPercentage,_that.isPregnant,_that.isLactating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({this.id, required this.name, required this.age, required this.gender, required this.height, required this.heightUnit, required this.weight, required this.weightUnit, required this.activityLevel, required this.goal, required this.targetWeight, required this.weeklyGoal, this.targetDate, required this.dietaryPreference, final  List<String> allergies = const [], final  List<String> cuisines = const [], required this.mealReminderMorning, required this.mealReminderAfternoon, required this.mealReminderEvening, required this.waterReminderIntervalMinutes, this.isOnboarded = false, this.bodyFatPercentage, this.isPregnant = false, this.isLactating = false}): _allergies = allergies,_cuisines = cuisines;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String? id;
@override final  String name;
@override final  int age;
@override final  Gender gender;
@override final  double height;
@override final  HeightUnit heightUnit;
@override final  double weight;
@override final  WeightUnit weightUnit;
@override final  ActivityLevel activityLevel;
@override final  GoalType goal;
@override final  double targetWeight;
@override final  double weeklyGoal;
@override final  DateTime? targetDate;
@override final  DietaryPreference dietaryPreference;
 final  List<String> _allergies;
@override@JsonKey() List<String> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

 final  List<String> _cuisines;
@override@JsonKey() List<String> get cuisines {
  if (_cuisines is EqualUnmodifiableListView) return _cuisines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisines);
}

@override final  DateTime mealReminderMorning;
@override final  DateTime mealReminderAfternoon;
@override final  DateTime mealReminderEvening;
@override final  int waterReminderIntervalMinutes;
@override@JsonKey() final  bool isOnboarded;
@override final  double? bodyFatPercentage;
@override@JsonKey() final  bool isPregnant;
@override@JsonKey() final  bool isLactating;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.height, height) || other.height == height)&&(identical(other.heightUnit, heightUnit) || other.heightUnit == heightUnit)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.weightUnit, weightUnit) || other.weightUnit == weightUnit)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.weeklyGoal, weeklyGoal) || other.weeklyGoal == weeklyGoal)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&const DeepCollectionEquality().equals(other._allergies, _allergies)&&const DeepCollectionEquality().equals(other._cuisines, _cuisines)&&(identical(other.mealReminderMorning, mealReminderMorning) || other.mealReminderMorning == mealReminderMorning)&&(identical(other.mealReminderAfternoon, mealReminderAfternoon) || other.mealReminderAfternoon == mealReminderAfternoon)&&(identical(other.mealReminderEvening, mealReminderEvening) || other.mealReminderEvening == mealReminderEvening)&&(identical(other.waterReminderIntervalMinutes, waterReminderIntervalMinutes) || other.waterReminderIntervalMinutes == waterReminderIntervalMinutes)&&(identical(other.isOnboarded, isOnboarded) || other.isOnboarded == isOnboarded)&&(identical(other.bodyFatPercentage, bodyFatPercentage) || other.bodyFatPercentage == bodyFatPercentage)&&(identical(other.isPregnant, isPregnant) || other.isPregnant == isPregnant)&&(identical(other.isLactating, isLactating) || other.isLactating == isLactating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,age,gender,height,heightUnit,weight,weightUnit,activityLevel,goal,targetWeight,weeklyGoal,targetDate,dietaryPreference,const DeepCollectionEquality().hash(_allergies),const DeepCollectionEquality().hash(_cuisines),mealReminderMorning,mealReminderAfternoon,mealReminderEvening,waterReminderIntervalMinutes,isOnboarded,bodyFatPercentage,isPregnant,isLactating]);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, age: $age, gender: $gender, height: $height, heightUnit: $heightUnit, weight: $weight, weightUnit: $weightUnit, activityLevel: $activityLevel, goal: $goal, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, targetDate: $targetDate, dietaryPreference: $dietaryPreference, allergies: $allergies, cuisines: $cuisines, mealReminderMorning: $mealReminderMorning, mealReminderAfternoon: $mealReminderAfternoon, mealReminderEvening: $mealReminderEvening, waterReminderIntervalMinutes: $waterReminderIntervalMinutes, isOnboarded: $isOnboarded, bodyFatPercentage: $bodyFatPercentage, isPregnant: $isPregnant, isLactating: $isLactating)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, int age, Gender gender, double height, HeightUnit heightUnit, double weight, WeightUnit weightUnit, ActivityLevel activityLevel, GoalType goal, double targetWeight, double weeklyGoal, DateTime? targetDate, DietaryPreference dietaryPreference, List<String> allergies, List<String> cuisines, DateTime mealReminderMorning, DateTime mealReminderAfternoon, DateTime mealReminderEvening, int waterReminderIntervalMinutes, bool isOnboarded, double? bodyFatPercentage, bool isPregnant, bool isLactating
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? age = null,Object? gender = null,Object? height = null,Object? heightUnit = null,Object? weight = null,Object? weightUnit = null,Object? activityLevel = null,Object? goal = null,Object? targetWeight = null,Object? weeklyGoal = null,Object? targetDate = freezed,Object? dietaryPreference = null,Object? allergies = null,Object? cuisines = null,Object? mealReminderMorning = null,Object? mealReminderAfternoon = null,Object? mealReminderEvening = null,Object? waterReminderIntervalMinutes = null,Object? isOnboarded = null,Object? bodyFatPercentage = freezed,Object? isPregnant = null,Object? isLactating = null,}) {
  return _then(_UserProfile(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,heightUnit: null == heightUnit ? _self.heightUnit : heightUnit // ignore: cast_nullable_to_non_nullable
as HeightUnit,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,weightUnit: null == weightUnit ? _self.weightUnit : weightUnit // ignore: cast_nullable_to_non_nullable
as WeightUnit,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as ActivityLevel,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as GoalType,targetWeight: null == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double,weeklyGoal: null == weeklyGoal ? _self.weeklyGoal : weeklyGoal // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dietaryPreference: null == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as DietaryPreference,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,cuisines: null == cuisines ? _self._cuisines : cuisines // ignore: cast_nullable_to_non_nullable
as List<String>,mealReminderMorning: null == mealReminderMorning ? _self.mealReminderMorning : mealReminderMorning // ignore: cast_nullable_to_non_nullable
as DateTime,mealReminderAfternoon: null == mealReminderAfternoon ? _self.mealReminderAfternoon : mealReminderAfternoon // ignore: cast_nullable_to_non_nullable
as DateTime,mealReminderEvening: null == mealReminderEvening ? _self.mealReminderEvening : mealReminderEvening // ignore: cast_nullable_to_non_nullable
as DateTime,waterReminderIntervalMinutes: null == waterReminderIntervalMinutes ? _self.waterReminderIntervalMinutes : waterReminderIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,isOnboarded: null == isOnboarded ? _self.isOnboarded : isOnboarded // ignore: cast_nullable_to_non_nullable
as bool,bodyFatPercentage: freezed == bodyFatPercentage ? _self.bodyFatPercentage : bodyFatPercentage // ignore: cast_nullable_to_non_nullable
as double?,isPregnant: null == isPregnant ? _self.isPregnant : isPregnant // ignore: cast_nullable_to_non_nullable
as bool,isLactating: null == isLactating ? _self.isLactating : isLactating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
