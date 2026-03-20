import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/level_system.dart';
import 'package:sorutrack_pro/features/gamification/domain/repositories/gamification_repository.dart';

@LazySingleton(as: GamificationRepository)
class GamificationRepositoryImpl implements GamificationRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  GamificationRepositoryImpl(this._dbHelper);

  @override
  Future<Either<Failure, GamificationData>> getGamificationData(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'gamification_data',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (results.isEmpty) {
        // Initialize if not exists
        final newData = {
          'user_id': userId,
          'xp': 0,
          'level': 1,
          'current_streak': 0,
          'highest_streak': 0,
          'streak_freeze_count': 0,
          'last_check_in': null,
        };
        await db.insert('gamification_data', newData);
        return Right(GamificationData.fromJson(newData));
      }

      return Right(GamificationData.fromJson(results.first));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateXP(String userId, int amount, String reason) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        // 1. Get current XP
        final results = await txn.query('gamification_data', where: 'user_id = ?', whereArgs: [userId]);
        int currentXP = 0;
        if (results.isNotEmpty) {
          currentXP = results.first['xp'] as int;
        }

        final newXP = currentXP + amount;
        final newLevel = LevelSystem.calculateLevel(newXP);

        // 2. Update gamification_data
        await txn.update(
          'gamification_data',
          {
            'xp': newXP,
            'level': newLevel,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // 3. Log XP history
        await txn.insert('xp_history', {
          'id': _uuid.v4(),
          'user_id': userId,
          'amount': amount,
          'reason': reason,
          'created_at': DateTime.now().toIso8601String(),
        });
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStreak(String userId, bool increment) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        final results = await txn.query('gamification_data', where: 'user_id = ?', whereArgs: [userId]);
        if (results.isEmpty) return;

        final currentStreak = results.first['current_streak'] as int;
        final highestStreak = results.first['highest_streak'] as int;
        final streakFreezeCount = results.first['streak_freeze_count'] as int? ?? 0;
        
        int newStreak;
        int newFreezeCount = streakFreezeCount;

        if (increment) {
          newStreak = currentStreak + 1;
        } else {
          if (streakFreezeCount > 0) {
            newStreak = currentStreak; // Protected by freeze
            newFreezeCount--;
          } else {
            newStreak = 0;
          }
        }

        final newHighest = newStreak > highestStreak ? newStreak : highestStreak;

        await txn.update(
          'gamification_data',
          {
            'current_streak': newStreak,
            'highest_streak': newHighest,
            'streak_freeze_count': newFreezeCount,
            'last_check_in': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Badge>>> getBadges() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('badges');
      return Right(results.map((e) => Badge(
        id: e['id'] as String,
        name: e['name'] as String,
        description: e['description'] as String,
        imageUrl: e['image_url'] as String,
        category: e['category'] as String,
        criteria: e['criteria'] as String,
      )).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getUserAchievements(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('achievements', where: 'user_id = ?', whereArgs: [userId]);
      return Right(results.map((e) => Achievement(
        id: e['id'] as String,
        userId: e['user_id'] as String,
        badgeId: e['badge_id'] as String,
        unlockedAt: DateTime.parse(e['unlocked_at'] as String),
      )).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlockBadge(String userId, String badgeId) async {
    try {
      final db = await _dbHelper.database;
      // Check for duplicate
      final existing = await db.query(
        'achievements',
        where: 'user_id = ? AND badge_id = ?',
        whereArgs: [userId, badgeId],
      );
      
      if (existing.isNotEmpty) {
        return const Right(null); // Already unlocked
      }

      await db.insert('achievements', {
        'id': _uuid.v4(),
        'user_id': userId,
        'badge_id': badgeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Challenge>>> getActiveChallenges() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('challenges');
      return Right(results.map((e) => Challenge(
        id: e['id'] as String,
        title: e['title'] as String,
        description: e['description'] as String,
        rewardXp: e['reward_xp'] as int,
        type: e['type'] as String,
        targetValue: (e['target_value'] as num).toDouble(),
        durationDays: e['duration_days'] as int,
      )).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserChallenge>>> getUserChallenges(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('user_challenges', where: 'user_id = ?', whereArgs: [userId]);
      return Right(results.map((e) => UserChallenge(
        id: e['id'] as String,
        userId: e['user_id'] as String,
        challengeId: e['challenge_id'] as String,
        currentValue: (e['current_value'] as num).toDouble(),
        isCompleted: (e['is_completed'] as int) == 1,
        startedAt: DateTime.parse(e['started_at'] as String),
        completedAt: e['completed_at'] != null ? DateTime.parse(e['completed_at'] as String) : null,
      )).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChallengeProgress(String userId, String challengeId, double progress) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'user_challenges',
        {
          'current_value': progress,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ? AND challenge_id = ?',
        whereArgs: [userId, challengeId],
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
