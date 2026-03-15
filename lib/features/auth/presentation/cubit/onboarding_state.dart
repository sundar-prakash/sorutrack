import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/auth_enums.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default('') String name,
    @Default(25) int age,
    @Default(Gender.male) Gender gender,
    @Default(170) double height,
    @Default(HeightUnit.cm) HeightUnit heightUnit,
    @Default(70) double weight,
    @Default(WeightUnit.kg) WeightUnit weightUnit,
    @Default(ActivityLevel.sedentary) ActivityLevel activityLevel,
    @Default(GoalType.maintain) GoalType goal,
    @Default(70) double targetWeight,
    @Default(0.5) double weeklyGoal,
    DateTime? targetDate,
    @Default(DietaryPreference.nonVeg) DietaryPreference dietaryPreference,
    @Default([]) List<String> allergies,
    @Default([]) List<String> cuisines,
    DateTime? mealReminderMorning,
    DateTime? mealReminderAfternoon,
    DateTime? mealReminderEvening,
    @Default(60) int waterReminderIntervalMinutes,
    @Default('') String geminiApiKey,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _OnboardingState;
}
