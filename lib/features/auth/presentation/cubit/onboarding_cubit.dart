import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/auth_enums.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/usecases/profile_use_cases.dart';
import '../../../core/services/gemini_key_service.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final SaveUserProfile _saveUserProfile;
  final GeminiKeyService _geminiKeyService;

  OnboardingCubit(this._saveUserProfile, this._geminiKeyService) : super(const OnboardingState());

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateGeminiApiKey(String key) => emit(state.copyWith(geminiApiKey: key));
  void updateAge(int age) => emit(state.copyWith(age: age));
  void updateGender(Gender gender) => emit(state.copyWith(gender: gender));
  void updateHeight(double height, HeightUnit unit) => 
      emit(state.copyWith(height: height, heightUnit: unit));
  void updateWeight(double weight, WeightUnit unit) => 
      emit(state.copyWith(weight: weight, weightUnit: unit));
  void updateActivityLevel(ActivityLevel level) => 
      emit(state.copyWith(activityLevel: level));
  void updateGoal(GoalType goal) => emit(state.copyWith(goal: goal));
  void updateTargetWeight(double weight) => 
      emit(state.copyWith(targetWeight: weight));
  void updateWeeklyGoal(double kgPerWeek) => 
      emit(state.copyWith(weeklyGoal: kgPerWeek));
  void updateDietaryPreference(DietaryPreference pref) => 
      emit(state.copyWith(dietaryPreference: pref));
  void updateAllergies(List<String> allergies) => 
      emit(state.copyWith(allergies: allergies));
  void updateCuisines(List<String> cuisines) => 
      emit(state.copyWith(cuisines: cuisines));
  
  void nextStep() => emit(state.copyWith(currentStep: state.currentStep + 1));
  void previousStep() => emit(state.copyWith(currentStep: state.currentStep - 1));

  Future<void> submit() async {
    emit(state.copyWith(isSubmitting: true, error: null));

    final profile = UserProfile(
      id: 'default_user',
      name: state.name,
      age: state.age,
      gender: state.gender,
      height: state.height,
      heightUnit: state.heightUnit,
      weight: state.weight,
      weightUnit: state.weightUnit,
      activityLevel: state.activityLevel,
      goal: state.goal,
      targetWeight: state.targetWeight,
      weeklyGoal: state.weeklyGoal,
      dietaryPreference: state.dietaryPreference,
      allergies: state.allergies,
      cuisines: state.cuisines,
      mealReminderMorning: state.mealReminderMorning ?? DateTime(2026, 1, 1, 8),
      mealReminderAfternoon: state.mealReminderAfternoon ?? DateTime(2026, 1, 1, 13),
      mealReminderEvening: state.mealReminderEvening ?? DateTime(2026, 1, 1, 20),
      waterReminderIntervalMinutes: state.waterReminderIntervalMinutes,
      isOnboarded: true,
    );

    if (state.geminiApiKey.isNotEmpty) {
      try {
        await _geminiKeyService.saveKey(state.geminiApiKey);
      } catch (e) {
        emit(state.copyWith(isSubmitting: false, error: 'Failed to save API Key: ${e.toString()}'));
        return;
      }
    }

    final result = await _saveUserProfile(profile);

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }
}
