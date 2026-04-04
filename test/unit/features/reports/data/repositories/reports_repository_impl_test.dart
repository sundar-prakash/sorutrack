import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/reports/data/repositories/reports_repository_impl.dart';

import 'reports_repository_impl_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late ReportsRepositoryImpl repository;

  final startDate = DateTime(2023, 1, 1);
  final endDate = DateTime(2023, 1, 31);
  const userId = 'user123';

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    repository = ReportsRepositoryImpl(mockDbHelper);
  });

  group('ReportsRepositoryImpl', () {
    test('getCalorieTrend returns list of ReportTrendData', () async {
      when(mockDbHelper.getCalorieTrend(any, any, any)).thenAnswer((_) async => [
        {'date': '2023-01-01', 'calories': 2000.0},
        {'date': '2023-01-02', 'calories': 2100.0},
      ]);

      final result = await repository.getCalorieTrend(userId, startDate, endDate);

      expect(result.length, 2);
      expect(result.first.value, 2000.0);
      verify(mockDbHelper.getCalorieTrend(userId, '2023-01-01', '2023-01-31')).called(1);
    });

    test('getMacroTrend returns list of MacroDistribution', () async {
      when(mockDbHelper.getMacroTrend(any, any, any)).thenAnswer((_) async => [
        {'date': '2023-01-01', 'protein': 100.0, 'carbs': 200.0, 'fat': 70.0},
      ]);

      final result = await repository.getMacroTrend(userId, startDate, endDate);

      expect(result.length, 1);
      expect(result.first.protein, 100.0);
    });

    test('getTopFoods returns list of TopFood', () async {
      when(mockDbHelper.getTopFoods(any, any, any, any)).thenAnswer((_) async => [
        {'name': 'Apple', 'frequency': 5, 'total_calories': 475.0},
      ]);

      final result = await repository.getTopFoods(userId, limit: 5, startDate: startDate, endDate: endDate);

      expect(result.length, 1);
      expect(result.first.name, 'Apple');
    });

    test('getMealTimingData returns list of MealTimingData', () async {
      when(mockDbHelper.getMealTimingData(any)).thenAnswer((_) async => [
        {'hour': '08', 'count': 10},
      ]);

      final result = await repository.getMealTimingData(userId);

      expect(result.length, 1);
      expect(result.first.hour, 8);
    });

    test('getWeightTrend returns list of ReportTrendData', () async {
      when(mockDbHelper.getWeightTrend(any, any, any)).thenAnswer((_) async => [
        {'date': '2023-01-01', 'weight': 75.0},
      ]);

      final result = await repository.getWeightTrend(userId, startDate, endDate);

      expect(result.length, 1);
      expect(result.first.value, 75.0);
    });

    test('getGoalAdherence returns list of GoalAdherenceData', () async {
      when(mockDbHelper.getGoalAdherence(any, any, any)).thenAnswer((_) async => [
        {'date': '2023-01-01', 'total_calories': 1900.0, 'goal_calories': 2000.0, 'is_on_track': 1},
      ]);

      final result = await repository.getGoalAdherence(userId, startDate, endDate);

      expect(result.length, 1);
      expect(result.first.isOnTrack, true);
    });

    test('getMicronutrientAverages returns MicronutrientData', () async {
      when(mockDbHelper.getMicronutrientAverages(any, any, any)).thenAnswer((_) async => {
        'avg_fiber': 25.0,
        'avg_sodium': 2300.0,
        'avg_sugar': 50.0,
        'avg_potassium': 3500.0,
      });

      final result = await repository.getMicronutrientAverages(userId, startDate, endDate);

      expect(result.fiber, 25.0);
    });

    test('searchFoodEntries returns list of FoodLogEntry', () async {
      when(mockDbHelper.searchFoodInLog(any, any, 
          startDate: anyNamed('startDate'), 
          endDate: anyNamed('endDate'),
          mealTypes: anyNamed('mealTypes'),
          minCalories: anyNamed('minCalories'),
          maxCalories: anyNamed('maxCalories')
      )).thenAnswer((_) async => [
        {'meal_time': '2023-01-01T08:00:00', 'meal_type': 'Breakfast', 'food_name': 'Oats', 'calories': 300.0, 'protein': 10.0, 'carbs': 50.0, 'fat': 5.0},
      ]);

      final result = await repository.searchFoodEntries(userId, query: 'Oats', startDate: startDate, endDate: endDate);

      expect(result.length, 1);
      expect(result.first.foodName, 'Oats');
    });

    test('getCurrentStreak returns int', () async {
      when(mockDbHelper.getCurrentStreak(any)).thenAnswer((_) async => 7);

      final result = await repository.getCurrentStreak(userId);

      expect(result, 7);
    });
  });
}
