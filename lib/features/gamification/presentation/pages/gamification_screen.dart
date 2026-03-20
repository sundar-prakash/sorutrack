import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sorutrack_pro/features/gamification/presentation/bloc/gamification_bloc.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/level_system.dart';
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart' as models;
import 'package:sorutrack_pro/features/gamification/presentation/widgets/level_progress_ring.dart';
import 'package:sorutrack_pro/features/gamification/presentation/widgets/streak_flame.dart';
import 'package:sorutrack_pro/features/gamification/presentation/widgets/badge_item.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<GamificationBloc>()..add(LoadGamificationData('default_user')),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
          actions: [
            BlocBuilder<GamificationBloc, GamificationState>(
              builder: (context, state) {
                if (state is GamificationLoaded) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: StreakFlame(
                      streak: state.data.currentStreak,
                      isActiveToday: true,
                      size: 30,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<GamificationBloc, GamificationState>(
          builder: (context, state) {
            if (state is GamificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GamificationError) {
              return Center(child: Text(state.message));
            }
            if (state is GamificationLoaded) {
              final range = LevelSystem.getXPForLevel(state.data.level);
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GamificationBloc>().add(RefreshGamificationData('default_user'));
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Level Progress Ring
                      LevelProgressRing(
                        currentXP: state.data.xp,
                        minXP: range.$1,
                        maxXP: range.$2,
                        level: state.data.level,
                      ),
                      const SizedBox(height: 12),
                      Chip(
                        label: Text(LevelSystem.getTierName(LevelSystem.getTier(state.data.level))),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      const SizedBox(height: 32),

                      // Badge Grid
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Badge Collection',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: state.badges.length,
                        itemBuilder: (context, index) {
                          final badge = state.badges[index];
                          final isUnlocked = state.achievements.any((a) => a.badgeId == badge.id);
                          return BadgeItem(badge: badge, isUnlocked: isUnlocked);
                        },
                      ),

                      const SizedBox(height: 32),
                      // Challenges Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Weekly Challenges',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.activeChallenges.map((challenge) {
                        final userChallenge = state.userChallenges.firstWhere(
                          (uc) => uc.challengeId == challenge.id,
                          orElse: () => models.UserChallenge(
                            id: '',
                            userId: '',
                            challengeId: '',
                            currentValue: 0,
                            isCompleted: false,
                            startedAt: DateTime.now(),
                          ),
                        );
                        return _ChallengeCard(challenge: challenge, userChallenge: userChallenge);
                      }),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final models.Challenge challenge;
  final models.UserChallenge userChallenge;

  const _ChallengeCard({required this.challenge, required this.userChallenge});

  @override
  Widget build(BuildContext context) {
    final progress = userChallenge.currentValue / challenge.targetValue;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Reward: ${challenge.rewardXp} XP',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${userChallenge.currentValue.toInt()} / ${challenge.targetValue.toInt()}',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
