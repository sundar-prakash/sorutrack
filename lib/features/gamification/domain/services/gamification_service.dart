import 'package:injectable/injectable.dart';
import '../repositories/gamification_repository.dart';
import '../models/xp_rewards.dart';
import '../../../../core/services/home_widget_service.dart';

@lazySingleton
class GamificationService {
  final GamificationRepository _repository;
  final HomeWidgetService _homeWidgetService;

  GamificationService(this._repository, this._homeWidgetService);

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
