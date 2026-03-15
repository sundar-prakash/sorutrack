import 'package:equatable/equatable.dart';

class GamificationData extends Equatable {
  final String userId;
  final int xp;
  final int level;
  final int currentStreak;
  final int highestStreak;
  final int streakFreezeCount;
  final DateTime? lastCheckIn;

  const GamificationData({
    required this.userId,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.highestStreak,
    required this.streakFreezeCount,
    this.lastCheckIn,
  });

  factory GamificationData.fromJson(Map<String, dynamic> json) {
    return GamificationData(
      userId: json['user_id'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['current_streak'] ?? 0,
      highestStreak: json['highest_streak'] ?? 0,
      streakFreezeCount: json['streak_freeze_count'] ?? 0,
      lastCheckIn: json['last_check_in'] != null ? DateTime.parse(json['last_check_in']) : null,
    );
  }

  @override
  List<Object?> get props => [userId, xp, level, currentStreak, highestStreak, streakFreezeCount, lastCheckIn];
}

class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String criteria;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.criteria,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, category, criteria];
}

class Achievement extends Equatable {
  final String id;
  final String userId;
  final String badgeId;
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, userId, badgeId, unlockedAt];
}

class Challenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final int rewardXp;
  final String type;
  final double targetValue;
  final int durationDays;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.type,
    required this.targetValue,
    required this.durationDays,
  });

  @override
  List<Object?> get props => [id, title, description, rewardXp, type, targetValue, durationDays];
}

class UserChallenge extends Equatable {
  final String id;
  final String userId;
  final String challengeId;
  final double currentValue;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;

  const UserChallenge({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.currentValue,
    required this.isCompleted,
    required this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [id, userId, challengeId, currentValue, isCompleted, startedAt, completedAt];
}
