import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';
import 'package:sorutrack_pro/features/auth/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final DatabaseHelper _dbHelper;

  UserRepositoryImpl(this._dbHelper);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final map = Map<String, dynamic>.from(maps.first);
        
        // Convert table fields to JSON compatible with UserProfile
        final profileJson = {
          'id': map['id'],
          'name': map['name'],
          'age': map['age'],
          'gender': map['gender'],
          'height': map['height'],
          'heightUnit': map['height_unit'] ?? 'cm',
          'weight': map['weight'],
          'weightUnit': map['weight_unit'] ?? 'kg',
          'activityLevel': map['activity_level'] ?? 'sedentary',
          'goal': map['goal'] ?? 'maintain',
          'targetWeight': map['target_weight'] ?? map['weight'],
          'weeklyGoal': map['weekly_goal'] ?? 0.0,
          'targetDate': map['target_date'],
          'dietaryPreference': map['dietary_preference'] ?? 'nonVeg',
          'allergies': (map['allergies'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
          'cuisines': (map['cuisines'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
          'mealReminderMorning': map['meal_reminder_morning'] ?? '2026-01-01T08:00:00Z',
          'mealReminderAfternoon': map['meal_reminder_afternoon'] ?? '2026-01-01T13:00:00Z',
          'mealReminderEvening': map['meal_reminder_evening'] ?? '2026-01-01T20:00:00Z',
          'waterReminderIntervalMinutes': map['water_reminder_interval'] ?? 60,
          'isOnboarded': map['is_onboarded'] == 1,
          'bodyFatPercentage': map['body_fat_percentage'],
          'isPregnant': map['is_pregnant'] == 1,
          'isLactating': map['is_lactating'] == 1,
        };

        return Right(UserProfile.fromJson(profileJson));
      } else {
        return Left(DatabaseFailure('User not found'));
      }
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveUserProfile(UserProfile profile) async {
    try {
      final db = await _dbHelper.database;
      final values = {
        'id': profile.id ?? 'default_user',
        'name': profile.name,
        'age': profile.age,
        'gender': profile.gender.name,
        'height': profile.height,
        'height_unit': profile.heightUnit.name,
        'weight': profile.weight,
        'weight_unit': profile.weightUnit.name,
        'activity_level': profile.activityLevel.name,
        'goal': profile.goal.name,
        'target_weight': profile.targetWeight,
        'weekly_goal': profile.weeklyGoal,
        'target_date': profile.targetDate?.toIso8601String(),
        'dietary_preference': profile.dietaryPreference.name,
        'allergies': profile.allergies.join(','),
        'cuisines': profile.cuisines.join(','),
        'meal_reminder_morning': profile.mealReminderMorning.toIso8601String(),
        'meal_reminder_afternoon': profile.mealReminderAfternoon.toIso8601String(),
        'meal_reminder_evening': profile.mealReminderEvening.toIso8601String(),
        'water_reminder_interval': profile.waterReminderIntervalMinutes,
        'is_onboarded': profile.isOnboarded ? 1 : 0,
        'body_fat_percentage': profile.bodyFatPercentage,
        'is_pregnant': profile.isPregnant ? 1 : 0,
        'is_lactating': profile.isLactating ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.insert(
        'users',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserGoals(String userId, Map<String, dynamic> goals) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {...goals, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboarded(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'users',
        columns: ['is_onboarded'],
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (results.isNotEmpty) {
        return Right(results.first['is_onboarded'] == 1);
      }
      return const Right(false);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
