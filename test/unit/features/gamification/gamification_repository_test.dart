import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/gamification/data/repositories/gamification_repository_impl.dart';

void main() {
  late DatabaseHelper dbHelper;
  late GamificationRepositoryImpl repository;

  const userId = 'test_user';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.openTestDatabase();
    // Insert dummy user to satisfy foreign key constraint
    await db.insert('users', {
      'id': userId,
      'name': 'Test User',
      'is_onboarded': 1,
    });
    repository = GamificationRepositoryImpl(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
  });


  group('getGamificationData', () {
    test('should return initialized data when user exists for the first time', () async {
      // Act
      final result = await repository.getGamificationData(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.userId, userId);
          expect(r.xp, 0);
          expect(r.level, 1);
        },
      );
    });

    test('should return existing data from DB', () async {
      // Arrange
      final db = await dbHelper.database;
      await db.insert('gamification_data', {
        'user_id': userId,
        'xp': 100,
        'level': 2,
        'current_streak': 3,
        'highest_streak': 5,
        'streak_freeze_count': 1,
      });

      // Act
      final result = await repository.getGamificationData(userId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.xp, 100);
          expect(r.level, 2);
          expect(r.currentStreak, 3);
        },
      );
    });
  });

  group('updateXP', () {
    test('should increment XP and update level correctly', () async {
      // Arrange
      await repository.getGamificationData(userId); // Initialize

      // Act
      final result = await repository.updateXP(userId, 150, 'Daily Log');

      // Assert
      expect(result.isRight(), true);
      
      // Verify in DB
      final dataResult = await repository.getGamificationData(userId);
      dataResult.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.xp, 150);
          expect(r.level, 2); // Assuming Level 2 starts at 100 XP
        },
      );
    });
  });

  group('updateStreak', () {
    test('should increment streak and highest streak', () async {
      // Arrange
      await repository.getGamificationData(userId);

      // Act
      await repository.updateStreak(userId, true);

      // Assert
      final dataResult = await repository.getGamificationData(userId);
      dataResult.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.currentStreak, 1);
          expect(r.highestStreak, 1);
        },
      );
    });

    test('should reset streak when increment is false and no freezes available', () async {
      // Arrange
      final db = await dbHelper.database;
      await db.insert('gamification_data', {
        'user_id': userId,
        'xp': 0,
        'level': 1,
        'current_streak': 5,
        'highest_streak': 5,
        'streak_freeze_count': 0,
      });

      // Act
      await repository.updateStreak(userId, false);

      // Assert
      final dataResult = await repository.getGamificationData(userId);
      dataResult.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.currentStreak, 0);
          expect(r.highestStreak, 5);
        },
      );
    });

    test('should use streak freeze when increment is false', () async {
      // Arrange
      final db = await dbHelper.database;
      await db.insert('gamification_data', {
        'user_id': userId,
        'xp': 0,
        'level': 1,
        'current_streak': 5,
        'highest_streak': 5,
        'streak_freeze_count': 1,
      });

      // Act
      await repository.updateStreak(userId, false);

      // Assert
      final dataResult = await repository.getGamificationData(userId);
      dataResult.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.currentStreak, 5); // Protected
          expect(r.streakFreezeCount, 0); // Freeze consumed
        },
      );
    });
  });

  group('unlockBadge', () {
    test('should successfully unlock badge for user', () async {
      // Arrange
      final db = await dbHelper.database;
      await db.insert('badges', {
        'id': 'badge_1',
        'name': 'Test Badge',
        'category': 'streak',
      });
      const badgeId = 'badge_1';

      // Act
      final result = await repository.unlockBadge(userId, badgeId);

      // Assert
      expect(result.isRight(), true);
      
      // Verify
      final achievementsResult = await repository.getUserAchievements(userId);
      achievementsResult.fold(
        (l) => fail('Should be right'),
        (r) {
          expect(r.length, 1);
          expect(r[0].badgeId, badgeId);
        },
      );
    });
  });
}
