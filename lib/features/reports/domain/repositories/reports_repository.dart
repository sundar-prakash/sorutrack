import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

abstract class ReportsRepository {
  Future<List<ReportTrendData>> getCalorieTrend(String userId, DateTime startDate, DateTime endDate);
  Future<List<MacroDistribution>> getMacroTrend(String userId, DateTime startDate, DateTime endDate);
  Future<List<TopFood>> getTopFoods(String userId, {int limit = 10, DateTime? startDate, DateTime? endDate});
  Future<List<MealTimingData>> getMealTimingData(String userId);
  Future<List<ReportTrendData>> getWeightTrend(String userId, DateTime startDate, DateTime endDate);
  Future<List<GoalAdherenceData>> getGoalAdherence(String userId, DateTime startDate, DateTime endDate);
  Future<MicronutrientData> getMicronutrientAverages(String userId, DateTime startDate, DateTime endDate);
  Future<List<FoodLogEntry>> searchFoodEntries(
    String userId, 
    {String query = '', 
    DateTime? startDate, 
    DateTime? endDate, 
    List<String>? mealTypes, 
    double? minCalories, 
    double? maxCalories}
  );
  Future<int> getCurrentStreak(String userId);
}
