import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/meal_log/data/meal_repository_impl.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/features/gamification/domain/services/gamification_service.dart';
import 'package:sorutrack_pro/features/meal_log/domain/models/parsed_meal.dart';

import 'meal_repository_test.mocks.dart';

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
    await dbHelper.openTestDatabase();
    mockGeminiService = MockGeminiMealService();
    mockGamificationService = MockGamificationService();
    repository = MealRepositoryImpl(dbHelper, mockGeminiService, mockGamificationService);

    // Seed default user
    final db = await dbHelper.database;
    await db.insert('users', {'id': 'default_user', 'name': 'Test User', 'is_onboarded': 1});
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
  });

  final tParsedMeal = ParsedMeal(
    mealName: 'Apple',
    mealTime: '08:00',
    mealType: 'breakfast',
    confidenceScore: 0.9,
    totalCalories: 95,
    totalProteinG: 0.5,
    totalCarbsG: 25,
    totalFatG: 0.3,
    items: [
      const ParsedMealItem(
        name: 'Apple',
        quantity: 1,
        unit: 'piece',
        weightG: 150,
        calories: 95,
        proteinG: 0.5,
        carbsG: 25,
        fatG: 0.3,
        servingDescription: '1 medium apple',
      ),
    ],
  );

  group('parseMeal', () {
    test('should return meal from Gemini and save to cache if not cached', () async {
      // Arrange
      const input = 'I ate an apple';
      when(mockGeminiService.parseNaturalLanguageMeal(any, any))
          .thenAnswer((_) async => Right(tParsedMeal));

      // Act
      final result = await repository.parseMeal(input, 'breakfast');

      // Assert
      expect(result.getOrElse(() => throw Exception()), tParsedMeal);
      verify(mockGeminiService.parseNaturalLanguageMeal(input, 'breakfast')).called(1);
      
      // Verify cache
      final db = await dbHelper.database;
      final cacheResults = await db.query('food_cache');
      expect(cacheResults.length, 1);
      expect(cacheResults.first['input_text'], input);
    });

    test('should return cached meal if similarity is high', () async {
      // Arrange
      const cachedInput = 'I ate an apple';
      const newInput = 'i ate an apple'; // Case difference
      
      final db = await dbHelper.database;
      await db.insert('food_cache', {
        'id': 'cache1',
        'input_text': cachedInput,
        'parsed_json': jsonEncode(tParsedMeal.toJson()),
        'use_count': 1,
        'last_used': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Act
      final result = await repository.parseMeal(newInput, 'breakfast');

      // Assert
      expect(result.getOrElse(() => throw Exception()), tParsedMeal);
      verifyNever(mockGeminiService.parseNaturalLanguageMeal(any, any));
      
      // Check use count updated
      final updatedCache = await db.query('food_cache');
      expect(updatedCache.first['use_count'], 2);
    });
  });

  group('saveMeal', () {
    test('should insert meal and meal_items into database', () async {
      // Act
      await repository.saveMeal(tParsedMeal);

      // Assert
      final db = await dbHelper.database;
      final meals = await db.query('meals');
      final mealItems = await db.query('meal_items');
      
      expect(meals.length, 1);
      expect(mealItems.length, 1);
      expect(meals.first['name'], 'Breakfast - Apple'); // Normalized name
      
      verify(mockGamificationService.logMeal(any, any)).called(1);
    });

    test('should handle updates correctly', () async {
      // Arrange
      await repository.saveMeal(tParsedMeal);
      final mealId = (await (await dbHelper.database).query('meals')).first['id'] as String;
      
      final updatedMeal = tParsedMeal.copyWith(mealId: mealId, mealName: 'Big Apple');

      // Act
      await repository.saveMeal(updatedMeal);

      // Assert
      final db = await dbHelper.database;
      final meals = await db.query('meals');
      expect(meals.length, 1);
      expect(meals.first['name'], 'Breakfast - Big Apple');
    });
  });

  group('deleteMeal', () {
     test('should remove meal from database', () async {
        // Arrange
        await repository.saveMeal(tParsedMeal);
        final mealId = (await (await dbHelper.database).query('meals')).first['id'] as String;

        // Act
        await repository.deleteMeal(mealId);

        // Assert
        final meals = await (await dbHelper.database).query('meals');
        expect(meals.isEmpty, true);
     });
  });
}
