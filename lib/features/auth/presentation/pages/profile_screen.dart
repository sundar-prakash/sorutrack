import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:sorutrack_pro/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:sorutrack_pro/features/auth/domain/models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit-profile');
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (profile, bmr, tdee, calorieTarget, macros, bmi, bmiStatus) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _ProfileHeader(profile: profile, bmi: bmi, bmiStatus: bmiStatus),
                    const SizedBox(height: 24),

                    // Calorie & TDEE Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Daily Target',
                            value: '${calorieTarget.round()}',
                            unit: 'kcal',
                            icon: Icons.track_changes,
                            color: Colors.orange,
                            delay: 100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'TDEE',
                            value: '${tdee.round()}',
                            unit: 'kcal',
                            icon: Icons.flash_on,
                            color: Colors.blue,
                            delay: 200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'BMR',
                            value: '${bmr.round()}',
                            unit: 'kcal',
                            icon: Icons.favorite,
                            color: Colors.red,
                            delay: 300,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: const SizedBox()), // Placeholder
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Macro Breakdown
                    Text(
                      'Macro Targets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _MacroRow(macros: macros),
                    const SizedBox(height: 32),

                    // Weight History Chart
                    Text(
                      'Weight History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _WeightChart(profile: profile),
                    const SizedBox(height: 32),
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

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final double bmi;
  final String bmiStatus;

  const _ProfileHeader({required this.profile, required this.bmi, required this.bmiStatus});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                profile.name[0].toUpperCase(),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${profile.age} years • ${profile.gender.name.toUpperCase()}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'BMI: ${bmi.toStringAsFixed(1)} ($bmiStatus)',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(unit, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final Map<String, double> macros;

  const _MacroRow({required this.macros});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MacroItem(label: 'Protein', value: macros['protein'] ?? 0, color: Colors.blue),
        _MacroItem(label: 'Carbs', value: macros['carbs'] ?? 0, color: Colors.green),
        _MacroItem(label: 'Fat', value: macros['fat'] ?? 0, color: Colors.red),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.2), width: 4),
          ),
          child: Center(
            child: Text(
              '${value.round()}g',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final UserProfile profile;

  const _WeightChart({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 75),
                const FlSpot(1, 74.5),
                const FlSpot(2, 74.8),
                const FlSpot(3, 74.2),
                const FlSpot(4, 73.5),
                FlSpot(5, profile.weight),
              ],
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
