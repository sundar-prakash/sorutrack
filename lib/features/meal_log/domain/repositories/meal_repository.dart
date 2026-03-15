import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/daily_nutrition.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';

abstract class MealRepository {
  Future<Either<Failure, ParsedMeal>> parseMeal(String input, String mealType);
  Future<Either<Failure, void>> saveMeal(ParsedMeal meal);
  Future<Either<Failure, List<ParsedMeal>>> getMealsForDate(DateTime date);
  Future<Either<Failure, void>> deleteMeal(String mealId);

  // New methods for Phase 10 Tests
  Future<Either<Failure, DailyNutrition>> getTodayNutrition({required String userId, required String date});
  Future<Either<Failure, List<ReportTrendData>>> getWeeklyCalories(String userId);
  Future<Either<Failure, int>> getCurrentStreak(String userId);
  Future<Either<Failure, List<FoodLogEntry>>> searchFoodInLog(String userId, String query);
}
