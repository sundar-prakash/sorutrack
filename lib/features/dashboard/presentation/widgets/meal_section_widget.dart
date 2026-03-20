import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/meal_type_chip.dart';
import '../../../../features/auth/presentation/cubit/profile_cubit.dart';
import '../../../../features/auth/domain/models/auth_enums.dart';
import '../../../../core/utils/unit_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/dashboard_data.dart';

class MealSectionWidget extends StatelessWidget {
  final List<MealSummary> meals;

  const MealSectionWidget({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    final displayedTypes = [
      'Breakfast',
      'Morning Snack',
      'Lunch',
      'Afternoon Snack',
      'Dinner',
      'Late Night'
    ];

    final usedIds = <String>{};
    final sections = displayedTypes.map((type) {
      final matchingMeals = meals.where((m) {
        final mealName = m.name.toLowerCase().trim();
        final targetType = type.toLowerCase().trim();
        return mealName == targetType || 
               mealName.startsWith('$targetType ') || 
               mealName.startsWith('$targetType -');
      }).toList();

      for (var m in matchingMeals) {
        if (m.id.isNotEmpty) usedIds.add(m.id);
      }

      final MealSummary aggregatedMeal;
      if (matchingMeals.isEmpty) {
        aggregatedMeal = MealSummary(
          id: '',
          name: type,
          time: DateTime.now(),
          totalCalories: 0,
          itemCount: 0,
        );
      } else {
        aggregatedMeal = MealSummary(
          id: matchingMeals.first.id,
          name: type,
          time: matchingMeals.first.time,
          totalCalories: matchingMeals.fold(0, (sum, m) => sum + m.totalCalories),
          itemCount: matchingMeals.fold(0, (sum, m) => sum + m.itemCount),
          itemPreviews: matchingMeals.expand((m) => m.itemPreviews).toList(),
        );
      }
      return _buildMealCard(context, aggregatedMeal);
    }).toList();

    // Catch-all for other meals
    final otherMeals = meals.where((m) => !usedIds.contains(m.id)).toList();
    if (otherMeals.isNotEmpty) {
      final aggregatedOther = MealSummary(
        id: otherMeals.first.id,
        name: 'Other',
        time: otherMeals.first.time,
        totalCalories: otherMeals.fold(0, (sum, m) => sum + m.totalCalories),
        itemCount: otherMeals.fold(0, (sum, m) => sum + m.itemCount),
        itemPreviews: otherMeals.expand((m) => m.itemPreviews).toList(),
      );
      sections.add(_buildMealCard(context, aggregatedOther));
    }

    return Column(children: sections);
  }

  MealType _getMealTypeEnum(String name) {
    switch (name.toLowerCase()) {
      case 'breakfast':
      case 'morning snack':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'afternoon snack':
      case 'late night':
      case 'other':
        return MealType.snack;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.snack;
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
        trailing: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final useMetric = profileState.maybeWhen(
              loaded: (p, _, __, ___, ____, _____, ______) => p.weightUnit == WeightUnit.kg,
              orElse: () => true,
            );
            final unitHelper = UnitHelper(useMetric: useMetric);
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasItems)
                  Text(
                    '${meal.totalCalories.toInt()} ${unitHelper.energyUnit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Icon(Icons.expand_more, size: 20),
              ],
            );
          },
        ),
        subtitle: Text(
          hasItems ? '${meal.itemCount} items' : 'No food logged',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                            Icon(Icons.circle,
                                size: 6,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.5)),
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
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
                  context.push('/quick-add', extra: meal.name);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Food'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
