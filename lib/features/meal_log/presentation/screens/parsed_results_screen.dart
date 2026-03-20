import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../bloc/meal_log_bloc.dart';
import '../bloc/meal_log_event.dart';
import '../bloc/meal_log_state.dart';
import '../../domain/models/parsed_meal.dart';

class ParsedResultsScreen extends StatefulWidget {
  final ParsedMeal meal;

  const ParsedResultsScreen({super.key, required this.meal});

  @override
  State<ParsedResultsScreen> createState() => _ParsedResultsScreenState();
}

class _ParsedResultsScreenState extends State<ParsedResultsScreen> {
  late ParsedMeal _currentMeal;

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.meal;
  }

  void _onSave() {
    context.read<MealLogBloc>().add(MealLogEvent.saveMeal(_currentMeal));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MealLogBloc, MealLogState>(
      listener: (context, state) {
        state.maybeWhen(
          success: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meal logged successfully!')),
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Meal'),
          actions: [
            if (_currentMeal.confidenceScore < 0.8)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.warning_amber_rounded, color: Colors.orange),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInDown(
                    child: Text(
                      _currentMeal.mealName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Confidence: ${(_currentMeal.confidenceScore * 100).toInt()}%'),
                  const SizedBox(height: 24),
                  ..._currentMeal.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildFoodItemCard(item, index);
                  }),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      // Add custom item dialog
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add custom item'),
                  ),
                  if (_currentMeal.warnings.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Warnings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    ..._currentMeal.warnings.map((w) => Text('• $w',
                        style: const TextStyle(color: Colors.red))),
                  ],
                  if (_currentMeal.alternativesSuggested.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Suggestions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    ..._currentMeal.alternativesSuggested.map((s) => Text(
                        '• $s',
                        style: const TextStyle(color: Colors.blue))),
                  ],
                ],
              ),
            ),
            _buildSummaryBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(ParsedMealItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Text('🥗'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item.servingDescription,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${item.calories.toInt()} cal',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroPill(
                    'P', '${item.proteinG.toStringAsFixed(1)}g', Colors.blue),
                _buildMacroPill(
                    'C', '${item.carbsG.toStringAsFixed(1)}g', Colors.orange),
                _buildMacroPill(
                    'F', '${item.fatG.toStringAsFixed(1)}g', Colors.red),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          // Update quantity logic
                        }),
                    Text('${item.quantity} ${item.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          // Update quantity logic
                        }),
                  ],
                ),
                TextButton(onPressed: () {}, child: const Text('Edit inline')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text('$label: $value',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                  'Calories', '${_currentMeal.totalCalories.toInt()}', 'kcal'),
              _buildSummaryItem(
                  'Protein', '${_currentMeal.totalProteinG.toInt()}', 'g'),
              _buildSummaryItem(
                  'Carbs', '${_currentMeal.totalCarbsG.toInt()}', 'g'),
              _buildSummaryItem(
                  'Fat', '${_currentMeal.totalFatG.toInt()}', 'g'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('SAVE TO LOG',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Looks wrong? Re-parse meal',
                style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(width: 2),
            Text(unit,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
