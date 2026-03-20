// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
      id: json['id'] as String?,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      height: (json['height'] as num).toDouble(),
      heightUnit: $enumDecode(_$HeightUnitEnumMap, json['heightUnit']),
      weight: (json['weight'] as num).toDouble(),
      weightUnit: $enumDecode(_$WeightUnitEnumMap, json['weightUnit']),
      activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
      goal: $enumDecode(_$GoalTypeEnumMap, json['goal']),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weeklyGoal: (json['weeklyGoal'] as num).toDouble(),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      dietaryPreference:
          $enumDecode(_$DietaryPreferenceEnumMap, json['dietaryPreference']),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cuisines: (json['cuisines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mealReminderMorning:
          DateTime.parse(json['mealReminderMorning'] as String),
      mealReminderAfternoon:
          DateTime.parse(json['mealReminderAfternoon'] as String),
      mealReminderEvening:
          DateTime.parse(json['mealReminderEvening'] as String),
      waterReminderIntervalMinutes:
          (json['waterReminderIntervalMinutes'] as num).toInt(),
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
      isPregnant: json['isPregnant'] as bool? ?? false,
      isLactating: json['isLactating'] as bool? ?? false,
    );

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'height': instance.height,
      'heightUnit': _$HeightUnitEnumMap[instance.heightUnit]!,
      'weight': instance.weight,
      'weightUnit': _$WeightUnitEnumMap[instance.weightUnit]!,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'goal': _$GoalTypeEnumMap[instance.goal]!,
      'targetWeight': instance.targetWeight,
      'weeklyGoal': instance.weeklyGoal,
      'targetDate': instance.targetDate?.toIso8601String(),
      'dietaryPreference':
          _$DietaryPreferenceEnumMap[instance.dietaryPreference]!,
      'allergies': instance.allergies,
      'cuisines': instance.cuisines,
      'mealReminderMorning': instance.mealReminderMorning.toIso8601String(),
      'mealReminderAfternoon': instance.mealReminderAfternoon.toIso8601String(),
      'mealReminderEvening': instance.mealReminderEvening.toIso8601String(),
      'waterReminderIntervalMinutes': instance.waterReminderIntervalMinutes,
      'isOnboarded': instance.isOnboarded,
      'bodyFatPercentage': instance.bodyFatPercentage,
      'isPregnant': instance.isPregnant,
      'isLactating': instance.isLactating,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

const _$HeightUnitEnumMap = {
  HeightUnit.cm: 'cm',
  HeightUnit.ft: 'ft',
};

const _$WeightUnitEnumMap = {
  WeightUnit.kg: 'kg',
  WeightUnit.lbs: 'lbs',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.lightlyActive: 'lightlyActive',
  ActivityLevel.moderatelyActive: 'moderatelyActive',
  ActivityLevel.veryActive: 'veryActive',
  ActivityLevel.extraActive: 'extraActive',
};

const _$GoalTypeEnumMap = {
  GoalType.loseWeight: 'loseWeight',
  GoalType.maintain: 'maintain',
  GoalType.gainMuscle: 'gainMuscle',
  GoalType.improveHealth: 'improveHealth',
  GoalType.custom: 'custom',
};

const _$DietaryPreferenceEnumMap = {
  DietaryPreference.vegetarian: 'vegetarian',
  DietaryPreference.vegan: 'vegan',
  DietaryPreference.nonVeg: 'nonVeg',
  DietaryPreference.pescatarian: 'pescatarian',
};
