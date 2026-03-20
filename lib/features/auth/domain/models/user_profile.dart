import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_enums.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    String? id,
    required String name,
    required int age,
    required Gender gender,
    required double height,
    required HeightUnit heightUnit,
    required double weight,
    required WeightUnit weightUnit,
    required ActivityLevel activityLevel,
    required GoalType goal,
    required double targetWeight,
    required double weeklyGoal,
    DateTime? targetDate,
    required DietaryPreference dietaryPreference,
    @Default([]) List<String> allergies,
    @Default([]) List<String> cuisines,
    required DateTime mealReminderMorning,
    required DateTime mealReminderAfternoon,
    required DateTime mealReminderEvening,
    required int waterReminderIntervalMinutes,
    @Default(false) bool isOnboarded,
    double? bodyFatPercentage,
    @Default(false) bool isPregnant,
    @Default(false) bool isLactating,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
