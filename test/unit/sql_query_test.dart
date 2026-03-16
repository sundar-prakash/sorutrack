import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/meal_log/data/meal_repository_impl.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/features/gamification/domain/services/gamification_service.dart';
import 'package:uuid/uuid.dart';

import 'sql_query_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GeminiMealService>(), MockSpec<GamificationService>()])
void main() {
  late DatabaseHelper dbHelper;
  late MealRepositoryImpl repository;
  late MockGeminiMealService mockGeminiService;
  late MockGamificationService mockGamificationService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.openTestDatabase();
    mockGeminiService = MockGeminiMealService();
    mockGamificationService = MockGamificationService();
    repository = MealRepositoryImpl(dbHelper, mockGeminiService, mockGamificationService);
    
    // Seed default user for foreign key constraints
    await db.insert('users', {
      'id': 'default_user',
      'name': 'Test User',
      'is_onboarded': 1,
    });
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
  });

  group('SQL Query Tests', () {
    final today = DateTime.now().toIso8601String().split('T')[0];

    test('getTodayNutrition returns 0 for empty day', () async {
      final result = await repository.getTodayNutrition(userId: 'default_user', date: today);
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.totalCalories, 0),
      );
    });

    test('getTodayNutrition sums correctly across meals', () async {
      final db = await dbHelper.database;
      final mealId = const Uuid().v4();
      
      await db.insert('meals', {
        'id': mealId,
        'user_id': 'default_user',
        'name': 'Breakfast',
        'meal_time': DateTime.now().toIso8601String(),
      });

      await db.insert('food_items', {
        'id': 'food1',
        'name': 'Food 1',
        'calories': 200.0,
      });

      await db.insert('food_items', {
        'id': 'food2',
        'name': 'Food 2',
        'calories': 300.0,
      });

      await db.insert('meal_items', {
        'id': const Uuid().v4(),
        'meal_id': mealId,
        'food_item_id': 'food1',
        'quantity': 1.0,
        'unit': 'piece',
        'calories': 200.0,
      });

      await db.insert('meal_items', {
        'id': const Uuid().v4(),
        'meal_id': mealId,
        'food_item_id': 'food2',
        'quantity': 1.0,
        'unit': 'piece',
        'calories': 300.0,
      });

      final result = await repository.getTodayNutrition(userId: 'default_user', date: today);
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.totalCalories, 500.0),
      );
    });

    test('getWeeklyCalories returns 7 rows even for days with no data', () async {
      final result = await repository.getWeeklyCalories('default_user');
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.length, 7),
      );
    });

    test('getCurrentStreak - 0 if no logs', () async {
       final result = await repository.getCurrentStreak('default_user');
       expect(result.getOrElse(() => -1), 0);
    });

    test('getMealsByDate - soft deleted items excluded', () async {
      final db = await dbHelper.database;
      final date = DateTime.now().toIso8601String().split('T')[0];
      
      // Insert one active meal
      await db.insert('meals', {
        'id': 'meal1',
        'user_id': 'default_user',
        'name': 'Active Meal',
        'meal_time': DateTime.now().toIso8601String(),
      });

      // Insert one "deleted" meal
      await db.insert('meals', {
        'id': 'meal2',
        'user_id': 'default_user',
        'name': 'Deleted Meal',
        'meal_time': DateTime.now().toIso8601String(),
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final results = await dbHelper.getMealsByDate('default_user', date);
      expect(results.length, 1);
      expect(results.first['name'], 'Active Meal');
    });

    test('searchFoodInLog - FTS5 search works', () async {
      final db = await dbHelper.database;
      
      await db.insert('food_items', {
        'id': 'apple1',
        'name': 'Green Apple',
        'calories': 52.0,
      });

      await db.insert('food_items', {
        'id': 'banana1',
        'name': 'Yellow Banana',
        'calories': 89.0,
      });

      // Insert them into meals so they show up in searchFoodInLog
      final mealId = 'search_meal';
      await db.insert('meals', {
        'id': mealId,
        'user_id': 'default_user',
        'name': 'Snack',
        'meal_time': DateTime.now().toIso8601String(),
      });

      await db.insert('meal_items', {
        'id': 'mi1',
        'meal_id': mealId,
        'food_item_id': 'apple1',
        'quantity': 1,
        'unit': 'piece',
        'calories': 52,
      });

      final result = await repository.searchFoodInLog('default_user', 'Apple');
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.first.foodName, contains('Apple')),
      );
    });
  });
}
