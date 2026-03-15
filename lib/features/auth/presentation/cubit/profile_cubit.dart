import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../core/nutrition/nutrition_engine.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/usecases/profile_use_cases.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded({
    required UserProfile profile,
    required double bmr,
    required double tdee,
    required double calorieTarget,
    required Map<String, double> macros,
    required double bmi,
    required String bmiStatus,
  }) = _Loaded;
  const factory ProfileState.error(String message) = _Error;
}

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfile _getUserProfile;
  final SaveUserProfile _saveUserProfile;

  ProfileCubit(this._getUserProfile, this._saveUserProfile) : super(const ProfileState.initial());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileState.loading());
    final result = await _getUserProfile(userId);

    result.fold(
      (failure) => emit(ProfileState.error(failure.message)),
      (profile) {
        _calculateAndEmit(profile);
      },
    );
  }

  void _calculateAndEmit(UserProfile profile) {
    // Height conversion for calculation (always uses CM internally for standard formulas if needed, or handles internally)
    final heightCm = profile.heightUnit == HeightUnit.cm 
        ? profile.height 
        : NutritionEngine.ftToCm(profile.height);
    
    final weightKg = profile.weightUnit == WeightUnit.kg 
        ? profile.weight 
        : NutritionEngine.lbsToKg(profile.weight);

    final bmr = NutritionEngine.calculateBMRMifflin(
      weightKg,
      heightCm,
      profile.age,
      profile.gender,
    );

    final tdee = NutritionEngine.calculateTDEE(bmr, profile.activityLevel);

    final target = NutritionEngine.calculateCalorieTarget(
      tdee,
      profile.goal,
      profile.weeklyGoal,
      profile.gender,
      profile.isPregnant,
      profile.isLactating,
    );

    final macros = NutritionEngine.calculateMacros(target, weightKg, profile.goal);
    
    final bmi = NutritionEngine.calculateBMI(weightKg, heightCm);
    final bmiStatus = _getBMIStatus(bmi);

    emit(ProfileState.loaded(
      profile: profile,
      bmr: bmr,
      tdee: tdee,
      calorieTarget: target,
      macros: macros,
      bmi: bmi,
      bmiStatus: bmiStatus,
    ));
  }

  String _getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Future<void> updateWeight(double newWeight) async {
    if (state is _Loaded) {
      final currentProfile = (state as _Loaded).profile;
      final updatedProfile = currentProfile.copyWith(weight: newWeight);
      final result = await _saveUserProfile(updatedProfile);
      
      result.fold(
        (failure) => emit(ProfileState.error(failure.message)),
        (_) => _calculateAndEmit(updatedProfile),
      );
    }
  }
}
