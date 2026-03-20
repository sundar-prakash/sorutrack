import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep3 extends StatelessWidget {
  final ActivityLevel selectedLevel;
  final Function(ActivityLevel) onLevelChanged;

  const OnboardingStep3({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Level',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "How active is your daily lifestyle?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ...ActivityLevel.values.map((level) {
                final isSelected = selectedLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () => onLevelChanged(level),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
// ...
                        color: isSelected
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForLevel(level),
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level.name
                                      .toUpperCase()
                                      .replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                Text(
                                  _getDescriptionForLevel(level),
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForLevel(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => Icons.chair_alt,
      ActivityLevel.lightlyActive => Icons.directions_walk,
      ActivityLevel.moderatelyActive => Icons.fitness_center,
      ActivityLevel.veryActive => Icons.directions_run,
      ActivityLevel.extraActive => Icons.sports_gymnastics,
    };
  }

  String _getDescriptionForLevel(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => "Little to no exercise, desk job",
      ActivityLevel.lightlyActive => "Light exercise 1-3 days/week",
      ActivityLevel.moderatelyActive => "Moderate exercise 3-5 days/week",
      ActivityLevel.veryActive => "Hard exercise 6-7 days/week",
      ActivityLevel.extraActive =>
        "Very hard exercise, physical job or 2x training",
    };
  }
}
