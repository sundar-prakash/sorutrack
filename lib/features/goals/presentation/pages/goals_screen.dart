import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/goal-settings'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (profile, bmr, tdee, target, macros, bmi, bmiStatus) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Objective',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _GoalCard(
                      title: 'Goal Type',
                      value: profile.goal.name.toUpperCase(),
                      icon: Icons.track_changes,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _GoalCard(
                            title: 'Current Weight',
                            value: '${profile.weight} ${profile.weightUnit.name}',
                            icon: Icons.monitor_weight_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GoalCard(
                            title: 'Target Weight',
                            value: '${profile.targetWeight} ${profile.weightUnit.name}',
                            icon: Icons.flag,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _GoalCard(
                      title: 'Weekly Rate',
                      value: '${profile.weeklyGoal} ${profile.weightUnit.name} / week',
                      icon: Icons.speed,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Daily Nutrition Targets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _GoalCard(
                      title: 'Calories',
                      value: '${target.round()} kcal',
                      icon: Icons.local_fire_department,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _GoalCard(
                            title: 'Protein',
                            value: '${macros['protein']?.round()}g',
                            icon: Icons.fitness_center,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GoalCard(
                            title: 'Carbs',
                            value: '${macros['carbs']?.round()}g',
                            icon: Icons.bakery_dining,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GoalCard(
                            title: 'Fat',
                            value: '${macros['fat']?.round()}g',
                            icon: Icons.water_drop,
                            color: Colors.yellow.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _GoalCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
