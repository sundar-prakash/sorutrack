import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep5 extends StatelessWidget {
  final double targetWeight;
  final double weeklyGoal;
  final WeightUnit weightUnit;
  final Function(double) onTargetWeightChanged;
  final Function(double) onWeeklyGoalChanged;

  const OnboardingStep5({
    super.key,
    required this.targetWeight,
    required this.weeklyGoal,
    required this.weightUnit,
    required this.onTargetWeightChanged,
    required this.onWeeklyGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your Targets',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Define your weight and pace.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text('Target Weight (${weightUnit.name})', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: targetWeight.clamp(0, 300),
              min: 0,
              max: 300,
              divisions: 300,
              label: '${targetWeight.toStringAsFixed(1)} ${weightUnit.name}',
              onChanged: onTargetWeightChanged,
            ),
            Center(child: Text('${targetWeight.toStringAsFixed(1)} ${weightUnit.name}', 
                style: Theme.of(context).textTheme.headlineSmall)),
            
            const SizedBox(height: 32),
            const Text('Weekly Goal (kg/week)', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [0.25, 0.5, 0.75, 1.0].map((val) {
                final isSelected = weeklyGoal == val;
                return ChoiceChip(
                  label: Text('$val kg'),
                  selected: isSelected,
                  onSelected: (selected) => onWeeklyGoalChanged(val),
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              _getPaceDescription(weeklyGoal),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaceDescription(double val) {
    if (val <= 0.25) return "Pace: Slow & Steady (Most sustainable)";
    if (val <= 0.5) return "Pace: Moderate (Recommended)";
    if (val <= 0.75) return "Pace: Fast (Requires discipline)";
    return "Pace: Aggressive (Talk to a professional)";
  }
}
