import 'package:flutter/material.dart';
import '../../../../shared/widgets/nutri_calorie_ring.dart';
import '../../domain/models/dashboard_data.dart';

class CalorieRingWidget extends StatelessWidget {
  final DailyNutritionSummary summary;

  const CalorieRingWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return NutriCalorieRing(
      consumedCalories: summary.consumedCalories.toInt(),
      targetCalories: summary.targetCalories.toInt(),
      // Assuming burnedCalories can't be passed or doesn't exist on standard NutriCalorieRing if not supported
    );
  }
}
