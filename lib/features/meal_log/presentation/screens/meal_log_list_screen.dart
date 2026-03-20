import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:sorutrack_pro/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:sorutrack_pro/features/dashboard/domain/models/dashboard_data.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_bloc.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_event.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/bloc/meal_log_state.dart';
import 'package:sorutrack_pro/features/meal_log/presentation/screens/parsed_results_screen.dart';

class MealLogListScreen extends StatelessWidget {
  const MealLogListScreen({super.key});

  Map<String, List<MealSummary>> _groupMeals(List<MealSummary> meals) {
    final Map<String, List<MealSummary>> grouped = {};
    final standardTypes = [
      'Breakfast',
      'Morning Snack',
      'Lunch',
      'Afternoon Snack',
      'Dinner',
      'Late Night'
    ];

    for (final meal in meals) {
      String category = 'Other';
      final mealName = meal.name.toLowerCase().trim();

      for (final type in standardTypes) {
        final targetType = type.toLowerCase();
        if (mealName == targetType ||
            mealName.startsWith('$targetType ') ||
            mealName.startsWith('$targetType -')) {
          category = type;
          break;
        }
      }

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(meal);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealLogBloc, MealLogState>(
      listener: (context, state) {
        state.maybeWhen(
          reviewing: (meal) {
            // When a meal is fetched for editing
            final bloc = context.read<MealLogBloc>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: ParsedResultsScreen(meal: meal),
                ),
              ),
            );
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, mealLogState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Log'),
          ),
          body: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (data, selectedDate, isRefreshing) {
                  if (data.meals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No meals logged for ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedMeals = _groupMeals(data.meals);
                  final categories = groupedMeals.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: categories.length,
                    itemBuilder: (context, catIndex) {
                      final category = categories[catIndex];
                      final meals = groupedMeals[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.2,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ...meals.map((meal) => FadeInLeft(
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${meal.itemCount} items: ${meal.itemPreviews.join(", ")}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${meal.totalCalories.toStringAsFixed(0)} cal',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(meal.time),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Trigger fetch for editing
                                  context.read<MealLogBloc>().add(
                                    MealLogEvent.fetchMealDetails(selectedDate, meal.id),
                                  );
                                },
                              ),
                            ),
                          )),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
                error: (message) => Center(child: Text(message)),
              );
            },
          ),
        );
      },
    );
  }
}
