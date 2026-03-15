import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/daily_nutrition.dart';
import 'package:sorutrack_pro/features/meal_log/domain/repositories/meal_repository.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/features/gamification/domain/services/gamification_service.dart';

@LazySingleton(as: MealRepository)
class MealRepositoryImpl implements MealRepository {
  final DatabaseHelper _dbHelper;
  final GeminiMealService _geminiService;
  final GamificationService _gamificationService;
  final _uuid = const Uuid();

  MealRepositoryImpl(this._dbHelper, this._geminiService, this._gamificationService);

  @override
  Future<Either<Failure, ParsedMeal>> parseMeal(String input, String mealType) async {
    // 1. Check Cache
    final cachedResult = await _checkCache(input);
    if (cachedResult != null) {
      return Right(cachedResult);
    }

    // 2. Call Gemini
    final result = await _geminiService.parseNaturalLanguageMeal(input, mealType);

    // 3. Save to cache on success
    return result.fold(
      (failure) => Left(failure),
      (meal) async {
        await _saveToCache(input, meal);
        await _trackApiUsage();
        return Right(meal);
      },
    );
  }

  @override
  Future<Either<Failure, void>> saveMeal(ParsedMeal meal) async {
    try {
      final db = await _dbHelper.database;
      final mealId = _uuid.v4();

      await db.transaction((txn) async {
        // Insert into meals table
        await txn.insert('meals', {
          'id': mealId,
          'user_id': 'default_user', // Simplified for now
          'name': meal.mealName,
          'meal_time': DateTime.now().toIso8601String(),
        });

        // Insert into meal_items table
        for (final item in meal.items) {
          final foodItemId = _uuid.v4();
          
          // Check if food item exists or insert new one
          await txn.insert('food_items', {
            'id': foodItemId,
            'name': item.name,
            'calories': item.calories,
            'protein': item.proteinG,
            'carbs': item.carbsG,
            'fat': item.fatG,
            'serving_size': item.quantity,
            'serving_unit': item.unit,
          });

          await txn.insert('meal_items', {
            'id': _uuid.v4(),
            'meal_id': mealId,
            'food_item_id': foodItemId,
            'quantity': item.quantity,
            'unit': item.unit,
            'calories': item.calories,
            'protein': item.proteinG,
            'carbs': item.carbsG,
            'fat': item.fatG,
          });
        }
      });

      // Award XP
      await _gamificationService.logMeal('default_user', false); // TODO: Replace with real user ID and check if first meal

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save meal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ParsedMeal>>> getMealsForDate(DateTime date) async {
    // Basic implementation to fetch meals
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
        final db = await _dbHelper.database;
        await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
        return const Right(null);
    } catch (e) {
        return Left(DatabaseFailure('Failed to delete meal: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DailyNutrition>> getTodayNutrition({required String userId, required String date}) async {
    try {
      final result = await _dbHelper.getTodayNutrition(userId, date);
      return Right(DailyNutrition.fromJson(result));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportTrendData>>> getWeeklyCalories(String userId) async {
    try {
      final now = DateTime.now();
      final results = await _dbHelper.getWeeklyCalories(userId);
      
      // Pad results to always return 7 days
      final Map<String, double> calorieMap = {
        for (var i = 0; i < 7; i++)
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i)).toIso8601String().split('T')[0]: 0.0
      };

      for (final row in results) {
        final date = row['date'] as String;
        if (calorieMap.containsKey(date)) {
          calorieMap[date] = (row['total_calories'] as num).toDouble();
        }
      }

      final sortedList = calorieMap.entries.map((e) => ReportTrendData(date: e.key, value: e.value)).toList();
      sortedList.sort((a, b) => a.date.compareTo(b.date));

      return Right(sortedList);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentStreak(String userId) async {
    try {
      final streak = await _dbHelper.getCurrentStreak(userId);
      return Right(streak);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodLogEntry>>> searchFoodInLog(String userId, String query) async {
    try {
      final results = await _dbHelper.searchFoodInLog(userId, query);
      return Right(results.map((e) => FoodLogEntry.fromJson(e)).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  Future<ParsedMeal?> _checkCache(String input) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('food_cache');
      
      for (final row in results) {
        final cachedInput = row['input_text'] as String;
        if (_calculateSimilarity(input.toLowerCase(), cachedInput.toLowerCase()) >= 0.8) {
          // Update use count
          await db.update(
            'food_cache',
            {
              'use_count': (row['use_count'] as int) + 1,
              'last_used': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [row['id']],
          );
          return ParsedMeal.fromJson(jsonDecode(row['parsed_json'] as String));
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(String input, ParsedMeal meal) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'food_cache',
        {
          'id': _uuid.v4(),
          'input_text': input,
          'parsed_json': jsonEncode(meal.toJson()),
          'use_count': 1,
          'last_used': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  Future<void> _trackApiUsage() async {
    try {
      final db = await _dbHelper.database;
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final result = await db.query('api_usage', where: 'date = ?', whereArgs: [today]);
      
      if (result.isEmpty) {
        await db.insert('api_usage', {
          'date': today,
          'call_count': 1,
          'token_estimate': 500, // Approximate
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        await db.update(
          'api_usage',
          {
            'call_count': (result.first['call_count'] as int) + 1,
            'token_estimate': (result.first['token_estimate'] as int) + 500,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'date = ?',
          whereArgs: [today],
        );
      }
    } catch (_) {}
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    int longerLength = s1.length > s2.length ? s1.length : s2.length;
    int editDistance = _levenshteinDistance(s1, s2);
    
    return (longerLength - editDistance) / longerLength;
  }

  int _levenshteinDistance(String s1, String s2) {
    List<int> costs = List.filled(s2.length + 1, 0);
    for (int i = 0; i <= s1.length; i++) {
        int lastValue = i;
        for (int j = 0; j <= s2.length; j++) {
            if (i == 0) {
                costs[j] = j;
            } else if (j > 0) {
                int newValue = costs[j - 1];
                if (s1[i - 1] != s2[j - 1]) {
                    newValue = (newValue < lastValue ? newValue : lastValue);
                    newValue = (newValue < costs[j] ? newValue : costs[j]) + 1;
                }
                costs[j - 1] = lastValue;
                lastValue = newValue;
            }
        }
        if (i > 0) costs[s2.length] = lastValue;
    }
    return costs[s2.length];
  }
}
