import 'package:flutter/material.dart';
import '../../../../shared/widgets/meal_type_chip.dart';
import '../../domain/models/dashboard_data.dart';

class MealSectionWidget extends StatelessWidget {
  final List<MealSummary> meals;

  const MealSectionWidget({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final mealTypes = [
      'Breakfast',
      'Morning Snack',
      'Lunch',
      'Afternoon Snack',
      'Dinner',
      'Late Night'
    ];

    return Column(
      children: mealTypes.map((type) {
        final meal = meals.firstWhere(
          (m) => m.name == type,
          orElse: () => MealSummary(
            id: '',
            name: type,
            time: DateTime.now(),
            totalCalories: 0,
            itemCount: 0,
          ),
        );

        return _buildMealCard(context, meal);
      }).toList(),
    );
  }

  MealType _getMealTypeEnum(String name) {
    switch (name.toLowerCase()) {
      case 'breakfast':
      case 'morning snack':
        return MealType.breakfast;
      case 'lunch':
      case 'afternoon snack':
      case 'late night':
        return MealType.snack; // Using snack as a fallback for secondary meals
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.lunch;
    }
  }

  Widget _buildMealCard(BuildContext context, MealSummary meal) {
    final theme = Theme.of(context);
    final hasItems = meal.itemCount > 0;
    
    // Map existing string types to the chip's subset
    final enumType = _getMealTypeEnum(meal.name);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: MealTypeChip(type: enumType),
        title: Text(
          meal.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasItems)
              Text(
                '${meal.totalCalories.toInt()} kcal',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Icon(Icons.expand_more, size: 20),
          ],
        ),
        subtitle: Text(
          hasItems ? '${meal.itemCount} items' : 'No food logged',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        children: [
          if (hasItems)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ...meal.itemPreviews.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: theme.colorScheme.primary.withOpacity(0.5)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (meal.itemCount > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 18),
                      child: Text(
                        'and ${meal.itemCount - 3} more...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  // Navigation will be handled by GoRouter
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Food'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
