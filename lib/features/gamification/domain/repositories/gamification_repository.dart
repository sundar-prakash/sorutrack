import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart';

abstract class GamificationRepository {
  Future<Either<Failure, GamificationData>> getGamificationData(String userId);
  Future<Either<Failure, void>> updateXP(String userId, int amount, String reason);
  Future<Either<Failure, void>> updateStreak(String userId, bool increment);
  Future<Either<Failure, List<Badge>>> getBadges();
  Future<Either<Failure, List<Achievement>>> getUserAchievements(String userId);
  Future<Either<Failure, void>> unlockBadge(String userId, String badgeId);
  Future<Either<Failure, List<Challenge>>> getActiveChallenges();
  Future<Either<Failure, List<UserChallenge>>> getUserChallenges(String userId);
  Future<Either<Failure, void>> updateChallengeProgress(String userId, String challengeId, double progress);
}
