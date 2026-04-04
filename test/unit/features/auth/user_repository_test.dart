import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/auth/data/repositories/user_repository_impl.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/models/auth_enums.dart';
import 'package:dartz/dartz.dart';

void main() {
  late DatabaseHelper dbHelper;
  late UserRepositoryImpl repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    await dbHelper.openTestDatabase();
    repository = UserRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
  });

  final tUserProfile = UserProfile(
    id: 'test_user',
    name: 'John Doe',
    age: 30,
    gender: Gender.male,
    height: 180,
    heightUnit: HeightUnit.cm,
    weight: 80,
    weightUnit: WeightUnit.kg,
    activityLevel: ActivityLevel.lightlyActive,
    goal: GoalType.maintain,
    targetWeight: 80,
    weeklyGoal: 0,
    dietaryPreference: DietaryPreference.nonVeg,
    allergies: ['Peanuts'],
    cuisines: ['Italian'],
    mealReminderMorning: DateTime(2026, 1, 1, 8),
    mealReminderAfternoon: DateTime(2026, 1, 1, 13),
    mealReminderEvening: DateTime(2026, 1, 1, 20),
    waterReminderIntervalMinutes: 60,
    isOnboarded: true,
  );

  group('getUserProfile', () {
    test('should return UserProfile when user exists in database', () async {
      // Arrange
      await repository.saveUserProfile(tUserProfile);

      // Act
      final result = await repository.getUserProfile('test_user');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not return failure'),
        (r) {
          expect(r.id, tUserProfile.id);
          expect(r.name, tUserProfile.name);
          expect(r.gender, tUserProfile.gender);
          expect(r.isOnboarded, true);
        },
      );
    });

    test('should return Left(DatabaseFailure) when user does not exist', () async {
      // Act
      final result = await repository.getUserProfile('non_existent');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('saveUserProfile', () {
    test('should successfully save user profile', () async {
      // Act
      final result = await repository.saveUserProfile(tUserProfile);

      // Assert
      expect(result.isRight(), true);
      
      // Verify in DB
      final dbResult = await repository.getUserProfile('test_user');
      expect(dbResult.isRight(), true);
    });

    test('should handle updates (upsert) correctly', () async {
      // Arrange
      await repository.saveUserProfile(tUserProfile);
      final updatedProfile = tUserProfile.copyWith(name: 'Updated Name');

      // Act
      await repository.saveUserProfile(updatedProfile);
      final result = await repository.getUserProfile('test_user');

      // Assert
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.name, 'Updated Name'),
      );
    });
  });

  group('isOnboarded', () {
    test('should return true if user is onboarded', () async {
      // Arrange
      await repository.saveUserProfile(tUserProfile);

      // Act
      final result = await repository.isOnboarded('test_user');

      // Assert
      expect(result, const Right(true));
    });

    test('should return false if user is not in database', () async {
      // Act
      final result = await repository.isOnboarded('unknown');

      // Assert
      expect(result, const Right(false));
    });
  });

  group('updateUserGoals', () {
    test('should update specific fields correctly', () async {
      // Arrange
      await repository.saveUserProfile(tUserProfile);

      // Act
      await repository.updateUserGoals('test_user', {'target_weight': 75.0});
      final result = await repository.getUserProfile('test_user');

      // Assert
      result.fold(
        (l) => fail('Should be right'),
        (r) => expect(r.targetWeight, 75.0),
      );
    });
  });
}
