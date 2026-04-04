import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/features/gamification/domain/services/gamification_service.dart';
import 'package:sorutrack_pro/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/xp_rewards.dart';

import 'gamification_service_test.mocks.dart';

@GenerateMocks([GamificationRepository])
void main() {
  late GamificationService service;
  late MockGamificationRepository mockRepository;

  setUp(() {
    mockRepository = MockGamificationRepository();
    service = GamificationService(mockRepository);
  });

  const userId = 'user1';

  group('awardXP', () {
    test('should call updateXP on repository with correct amount from XPRewards', () async {
      // Arrange
      const rewardKey = 'log_meal';
      final expectedAmount = XPRewards.getReward(rewardKey);
      when(mockRepository.updateXP(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await service.awardXP(userId, rewardKey);

      // Assert
      verify(mockRepository.updateXP(userId, expectedAmount, rewardKey)).called(1);
    });

    test('should NOT call repository if reward key is invalid (0 XP)', () async {
      // Act
      await service.awardXP(userId, 'invalid_key');

      // Assert
      verifyNever(mockRepository.updateXP(any, any, any));
    });
  });

  group('processDailyLogCompletion', () {
    test('should award XP for multiple goals and update streak', () async {
      // Arrange
      when(mockRepository.updateXP(any, any, any))
          .thenAnswer((_) async => const Right(null));
      when(mockRepository.updateStreak(any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await service.processDailyLogCompletion(
        userId,
        allMealsLogged: true,
        calorieGoalHit: true,
        proteinGoalHit: false,
        waterGoalHit: true,
        perfectMacros: false,
      );

      // Assert
      verify(mockRepository.updateXP(userId, XPRewards.getReward('complete_all_meals'), 'complete_all_meals')).called(1);
      verify(mockRepository.updateXP(userId, XPRewards.getReward('hit_calorie_goal'), 'hit_calorie_goal')).called(1);
      verify(mockRepository.updateXP(userId, XPRewards.getReward('hit_water_goal'), 'hit_water_goal')).called(1);
      verify(mockRepository.updateStreak(userId, true)).called(1);
      
      // Verify NO award for false goals
      verifyNever(mockRepository.updateXP(userId, any, 'hit_protein_goal'));
      verifyNever(mockRepository.updateXP(userId, any, 'perfect_macros'));
    });
  });

  group('logMeal', () {
    test('should award XP for logging meal and additional XP if it is first meal', () async {
      // Arrange
      when(mockRepository.updateXP(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await service.logMeal(userId, true);

      // Assert
      verify(mockRepository.updateXP(userId, XPRewards.getReward('log_meal'), 'log_meal')).called(1);
      verify(mockRepository.updateXP(userId, XPRewards.getReward('first_meal'), 'first_meal')).called(1);
    });

    test('should ONLY award XP for logging meal if NOT first meal', () async {
      // Arrange
      when(mockRepository.updateXP(any, any, any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await service.logMeal(userId, false);

      // Assert
      verify(mockRepository.updateXP(userId, XPRewards.getReward('log_meal'), 'log_meal')).called(1);
      verifyNever(mockRepository.updateXP(userId, any, 'first_meal'));
    });
  });
}
