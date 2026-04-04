import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/auth/domain/repositories/user_repository.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';
import 'package:sorutrack_pro/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

import 'dashboard_repository_test.mocks.dart';

@GenerateMocks([DatabaseHelper, UserRepository])
void main() {
  late DashboardRepositoryImpl repository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockUserRepository mockUserRepository;

  final sampleProfile = UserProfile(
    id: 'user1',
    name: 'John Doe',
    age: 30,
    gender: Gender.male,
    height: 175,
    heightUnit: HeightUnit.cm,
    weight: 70,
    weightUnit: WeightUnit.kg,
    activityLevel: ActivityLevel.sedentary,
    goal: GoalType.maintain,
    targetWeight: 68,
    weeklyGoal: 0.5,
    dietaryPreference: DietaryPreference.nonVeg,
    mealReminderMorning: DateTime(2024, 1, 1, 8, 0),
    mealReminderAfternoon: DateTime(2024, 1, 1, 13, 0),
    mealReminderEvening: DateTime(2024, 1, 1, 19, 0),
    waterReminderIntervalMinutes: 60,
    isOnboarded: true,
  );

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockUserRepository = MockUserRepository();
    repository = DashboardRepositoryImpl(mockDatabaseHelper, mockUserRepository);
  });

  group('getDashboardData', () {
    final testDate = DateTime(2024, 4, 4);
    const userId = 'user1';

    test('should return DashboardData when all data fetching is successful', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId))
          .thenAnswer((_) async => Right(sampleProfile));
      when(mockDatabaseHelper.getTodayNutrition(any, any))
          .thenAnswer((_) async => {'calories': 1500.0, 'protein': 100.0, 'carbs': 200.0, 'fat': 50.0, 'fiber': 20.0});
      when(mockDatabaseHelper.getMealsByDate(any, any))
          .thenAnswer((_) async => [
                {'id': 'meal1', 'name': 'Breakfast', 'meal_time': '2024-04-04T08:00:00', 'total_calories': 500.0, 'item_count': 2}
              ]);
      when(mockDatabaseHelper.getMealItemsByMealId('meal1'))
          .thenAnswer((_) async => [
                {'name': 'Egg', 'calories': 70.0},
                {'name': 'Toast', 'calories': 100.0}
              ]);
      when(mockDatabaseHelper.getWaterByDate(any, any)).thenAnswer((_) async => 2000);
      when(mockDatabaseHelper.getCurrentStreak(any)).thenAnswer((_) async => 5);
      when(mockDatabaseHelper.getWeeklyCalories(any)).thenAnswer((_) async => [
            {'date': '2024-04-03', 'total_calories': 1800.0},
            {'date': '2024-04-04', 'total_calories': 1500.0}
          ]);
      when(mockDatabaseHelper.getExerciseCaloriesByDate(any, any)).thenAnswer((_) async => 300.0);

      // Act
      final result = await repository.getDashboardData(userId, testDate);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not return failure'),
        (r) {
          expect(r.nutritionSummary.consumedCalories, 1500.0);
          expect(r.nutritionSummary.burnedCalories, 300.0);
          expect(r.meals.length, 1);
          expect(r.meals[0].name, 'Breakfast');
          expect(r.currentStreak, 5);
          expect(r.waterIntakeMl, 2000);
        },
      );
      verify(mockUserRepository.getUserProfile(userId));
      verify(mockDatabaseHelper.getTodayNutrition(userId, '2024-04-04'));
    });

    test('should return failure when user profile fetching fails', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId))
          .thenAnswer((_) async => const Left(DatabaseFailure('User not found')));

      // Act
      final result = await repository.getDashboardData(userId, testDate);

      // Assert
      expect(result.isLeft(), true);
      verify(mockUserRepository.getUserProfile(userId));
      verifyNever(mockDatabaseHelper.getTodayNutrition(any, any));
    });

    test('should return DatabaseFailure when database throws an exception', () async {
      // Arrange
      when(mockUserRepository.getUserProfile(userId))
          .thenAnswer((_) async => Right(sampleProfile));
      when(mockDatabaseHelper.getTodayNutrition(any, any)).thenThrow(Exception('DB Error'));

      // Act
      final result = await repository.getDashboardData(userId, testDate);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<DatabaseFailure>()),
        (r) => fail('Should return failure'),
      );
    });
  group('logWater', () {
    test('should call logWater on DatabaseHelper', () async {
      // Arrange
      when(mockDatabaseHelper.logWater(any, any, any)).thenAnswer((_) async => 1);

      // Act
      final result = await repository.logWater(userId, testDate, 250);

      // Assert
      expect(result.isRight(), true);
      verify(mockDatabaseHelper.logWater(userId, '2024-04-04', 250.0));
    });
  });
});
}
