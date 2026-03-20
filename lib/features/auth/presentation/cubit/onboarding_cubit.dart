import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/usecases/profile_use_cases.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final SaveUserProfile _saveUserProfile;
  final GeminiKeyService _geminiKeyService;

  OnboardingCubit(this._saveUserProfile, this._geminiKeyService) : super(const OnboardingState());

  void updateName(String name) => emit(state.copyWith(name: name, error: null));
  void updateDateOfBirth(DateTime dob) => emit(state.copyWith(dateOfBirth: dob, error: null));
  void updateGender(Gender gender) => emit(state.copyWith(gender: gender));
  void updateHeight(double height, HeightUnit unit) => 
      emit(state.copyWith(height: height, heightUnit: unit));
  void updateWeight(double weight, WeightUnit unit) {
    emit(state.copyWith(weight: weight, weightUnit: unit));
    _enforceWeightConstraints();
  }
  void updateActivityLevel(ActivityLevel level) => 
      emit(state.copyWith(activityLevel: level));
  void updateGoal(GoalType goal) {
    emit(state.copyWith(goal: goal));
    _enforceWeightConstraints();
  }
  void updateTargetWeight(double weight) {
    double validatedWeight = weight;
    // Enforce minimum weight of 20kg (roughly 44lbs)
    const minWeight = 20.0;
    if (validatedWeight < minWeight) validatedWeight = minWeight;

    emit(state.copyWith(targetWeight: validatedWeight));
  }
  void updateWeeklyGoal(double kgPerWeek) => 
      emit(state.copyWith(weeklyGoal: kgPerWeek));
  void updateDietaryPreference(DietaryPreference pref) => 
      emit(state.copyWith(dietaryPreference: pref));
  void updateAllergies(List<String> allergies) => 
      emit(state.copyWith(allergies: allergies));
  void updateCuisines(List<String> cuisines) => 
      emit(state.copyWith(cuisines: cuisines));
  void updateGeminiApiKey(String key) => emit(state.copyWith(geminiApiKey: key, error: null));
  
  void _enforceWeightConstraints() {
    double newTarget = state.targetWeight;
    if (state.goal == GoalType.loseWeight && state.targetWeight >= state.weight) {
      newTarget = state.weight - 1.0;
    } else if (state.goal == GoalType.gainMuscle && state.targetWeight <= state.weight) {
      newTarget = state.weight + 1.0;
    } else if (state.goal == GoalType.maintain) {
      newTarget = state.weight;
    }
    
    // Final clamp to 20kg min
    if (newTarget < 20.0) newTarget = 20.0;
    
    if (newTarget != state.targetWeight) {
      emit(state.copyWith(targetWeight: newTarget));
    }
  }

  bool nextStep() {
    final error = _validateCurrentStep();
    if (error != null) {
      emit(state.copyWith(error: error));
      return false;
    }
    emit(state.copyWith(currentStep: state.currentStep + 1, error: null));
    return true;
  }

  void previousStep() {
    emit(state.copyWith(currentStep: state.currentStep - 1, error: null));
  }

  String? _validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        if (state.name.trim().isEmpty) return 'Please enter your full name';
        if (state.name.trim().split(' ').length < 2) return 'Please enter your full name (first and last name)';
        if (state.dateOfBirth == null) return 'Please select your date of birth';
        
        final age = _calculateAge(state.dateOfBirth!);
        if (age < 13) return 'You must be at least 13 years old to use SoruTrack';
        if (age > 120) return 'Please enter a valid date of birth';
        break;
      case 1:
        if (state.height < 50 || state.height > 300) return 'Height must be between 50cm and 300cm';
        if (state.weight < 20 || state.weight > 500) return 'Weight must be between 20kg and 500kg';
        break;
      case 4:
        if (state.goal == GoalType.loseWeight && state.targetWeight >= state.weight) {
          return 'Target weight must be less than current weight to lose weight';
        }
        if (state.goal == GoalType.gainMuscle && state.targetWeight <= state.weight) {
          return 'Target weight must be greater than current weight to gain muscle';
        }
        break;
      case 6:
        if (state.geminiApiKey.isEmpty) return 'Please provide a Gemini API Key to continue (it is free!)';
        break;
    }
    return null;
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> submit() async {
    emit(state.copyWith(isSubmitting: true, error: null));

    final profile = UserProfile(
      id: 'default_user',
      name: state.name,
      age: _calculateAge(state.dateOfBirth!),
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
