import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/nutrition/nutrition_engine.dart';
import '../../../auth/domain/repositories/user_repository.dart';
import '../../domain/models/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DatabaseHelper _dbHelper;
  final UserRepository _userRepository;

  DashboardRepositoryImpl(this._dbHelper, this._userRepository);

  @override
  Future<Either<Failure, DashboardData>> getDashboardData(String userId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      // 1. Get User Profile for targets
      final userResult = await _userRepository.getUserProfile(userId);
      return await userResult.fold(
        (failure) => Left(failure),
        (profile) async {
          // 2. Calculate Targets
          final bmr = NutritionEngine.calculateBMRMifflin(
            profile.weight,
            profile.height,
            profile.age,
            profile.gender,
          );
          final tdee = NutritionEngine.calculateTDEE(bmr, profile.activityLevel);
          final targetCalories = NutritionEngine.calculateCalorieTarget(
            tdee,
            profile.goal,
            profile.weeklyGoal,
            profile.gender,
            profile.isPregnant,
            profile.isLactating,
          );
          final macros = NutritionEngine.calculateMacros(targetCalories, profile.weight, profile.goal);
          final waterTarget = NutritionEngine.calculateWaterTarget(profile.weight);
          final fiberTarget = NutritionEngine.calculateFiberTarget(profile.age);

          // 3. Fetch Data from DB
          final nutritionMap = await _dbHelper.getTodayNutrition(userId, dateStr);
          final mealsData = await _dbHelper.getMealsByDate(userId, dateStr);
          final waterIntake = await _dbHelper.getWaterByDate(userId, dateStr);
          final streak = await _dbHelper.getCurrentStreak(userId);
          final weeklyCalData = await getWeeklyCalories(userId);
          final burnedCals = await _dbHelper.getExerciseCaloriesByDate(userId, dateStr);

          // 4. Map Meals
          final List<MealSummary> meals = [];
          for (final mealMap in mealsData) {
            final mealId = mealMap['id'] as String;
            final items = await _dbHelper.getMealItemsByMealId(mealId);
            // In a real app, we'd fetch item names, but for now we'll use previews if available
            // This is a simplified preview logic
            meals.add(MealSummary(
              id: mealId,
              name: mealMap['name'] as String,
              time: DateTime.parse(mealMap['meal_time'] as String),
              totalCalories: (mealMap['total_calories'] as num?)?.toDouble() ?? 0.0,
              itemCount: mealMap['item_count'] as int,
              itemPreviews: items.take(3).map((e) => e['name'] as String? ?? "Item").toList(),
            ));
          }

          // 5. Greeting
          final hour = DateTime.now().hour;
          String greeting;
          if (hour < 12) {
            greeting = "Good morning";
          } else if (hour < 17) {
            greeting = "Good afternoon";
          } else {
            greeting = "Good evening";
          }
          greeting = "$greeting, ${profile.name}! 🌅";

          final dashboardData = DashboardData(
            nutritionSummary: DailyNutritionSummary(
              consumedCalories: (nutritionMap['calories'] as num?)?.toDouble() ?? 0.0,
              targetCalories: targetCalories,
              burnedCalories: burnedCals,
              proteinG: (nutritionMap['protein'] as num?)?.toDouble() ?? 0.0,
              proteinTargetG: macros['protein']!,
              carbsG: (nutritionMap['carbs'] as num?)?.toDouble() ?? 0.0,
              carbsTargetG: macros['carbs']!,
              fatG: (nutritionMap['fat'] as num?)?.toDouble() ?? 0.0,
              fatTargetG: macros['fat']!,
              fiberG: (nutritionMap['fiber'] as num?)?.toDouble() ?? 0.0,
              fiberTargetG: fiberTarget,
            ),
            meals: meals,
            waterIntakeMl: waterIntake,
            waterTargetMl: waterTarget,
            currentStreak: streak,
            greeting: greeting,
            weeklyCalories: weeklyCalData.getOrElse(() => []),
            dailyInsight: "You're doing great! Keep it up.", // Gemini placeholder
          );

          return Right(dashboardData);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WeeklyCalorieData>>> getWeeklyCalories(String userId) async {
    try {
      final data = await _dbHelper.getWeeklyCalories(userId);
      
      // Get user profile for target (simplified, assumes target is same for all 7 days)
      final userResult = await _userRepository.getUserProfile(userId);
      return userResult.fold(
        (failure) => Left(failure),
        (profile) {
          final bmr = NutritionEngine.calculateBMRMifflin(
            profile.weight,
            profile.height,
            profile.age,
            profile.gender,
          );
          final tdee = NutritionEngine.calculateTDEE(bmr, profile.activityLevel);
          final targetCalories = NutritionEngine.calculateCalorieTarget(
            tdee,
            profile.goal,
            profile.weeklyGoal,
            profile.gender,
            profile.isPregnant,
            profile.isLactating,
          );

          final result = data.map((m) => WeeklyCalorieData(
            date: DateTime.parse(m['date'] as String),
            calories: (m['total_calories'] as num).toDouble(),
            targetCalories: targetCalories,
          )).toList();

          return Right(result);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logWater(String userId, DateTime date, int mlToAdd) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      await _dbHelper.logWater(userId, dateStr, mlToAdd.toDouble());
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

