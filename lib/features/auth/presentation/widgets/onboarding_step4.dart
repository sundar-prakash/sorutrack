import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep4 extends StatelessWidget {
  final GoalType selectedGoal;
  final Function(GoalType) onGoalChanged;

  const OnboardingStep4({
    super.key,
    required this.selectedGoal,
    required this.onGoalChanged,
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
              'What is your Goal?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "We will tailor your plan based on this.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ...GoalType.values.map((goal) {
              final isSelected = selectedGoal == goal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RadioListTile<GoalType>(
                  value: goal,
                  groupValue: selectedGoal,
                  onChanged: (val) => onGoalChanged(val!),
                  title: Text(
                    goal.name.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                    ),
                  ),
                  subtitle: Text(_getDescriptionForGoal(goal)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getDescriptionForGoal(GoalType goal) {
    return switch (goal) {
      GoalType.loseWeight => "Lose body fat and get leaner",
      GoalType.maintain => "Keep your current weight and stay healthy",
      GoalType.gainMuscle => "Build strength and muscle mass",
      GoalType.improveHealth => "Generic health and wellness focus",
      GoalType.custom => "Set your own specific targets",
    };
  }
}
