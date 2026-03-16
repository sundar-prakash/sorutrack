import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/xp_rewards.dart';

@lazySingleton
class GamificationService {
  final GamificationRepository _repository;

  GamificationService(this._repository);

  Future<void> awardXP(String userId, String rewardKey) async {
    final amount = XPRewards.getReward(rewardKey);
    if (amount > 0) {
      await _repository.updateXP(userId, amount, rewardKey);
    }
  }

  Future<void> processDailyLogCompletion(String userId, {
    required bool allMealsLogged,
    required bool calorieGoalHit,
    required bool proteinGoalHit,
    required bool waterGoalHit,
    required bool perfectMacros,
  }) async {
    if (allMealsLogged) await awardXP(userId, 'complete_all_meals');
    if (calorieGoalHit) await awardXP(userId, 'hit_calorie_goal');
    if (proteinGoalHit) await awardXP(userId, 'hit_protein_goal');
    if (waterGoalHit) await awardXP(userId, 'hit_water_goal');
    if (perfectMacros) await awardXP(userId, 'perfect_macros');
    
    // Update streak every day a meal is logged (simplified logic)
    await _repository.updateStreak(userId, true);
  }

  Future<void> logMeal(String userId, bool isFirstMeal) async {
    await awardXP(userId, 'log_meal');
    if (isFirstMeal) {
      await awardXP(userId, 'first_meal');
    }
  }
}
