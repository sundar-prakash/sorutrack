import 'package:flutter/material.dart';
import '../../../../shared/widgets/macro_progress_bar.dart';
import '../../domain/models/dashboard_data.dart';

class MacroBarsWidget extends StatelessWidget {
  final DailyNutritionSummary summary;

  const MacroBarsWidget({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MacroProgressBar(
          label: 'Protein',
          currentAmount: summary.proteinG.toInt(),
          targetAmount: summary.proteinTargetG.toInt(),
          color: Colors.red.shade400,
        ),
        MacroProgressBar(
          label: 'Carbs',
          currentAmount: summary.carbsG.toInt(),
          targetAmount: summary.carbsTargetG.toInt(),
          color: Colors.blue.shade400,
        ),
        MacroProgressBar(
          label: 'Fat',
          currentAmount: summary.fatG.toInt(),
          targetAmount: summary.fatTargetG.toInt(),
          color: Colors.orange.shade400,
        ),
        MacroProgressBar(
          label: 'Fiber',
          currentAmount: summary.fiberG.toInt(),
          targetAmount: summary.fiberTargetG.toInt(),
          color: Colors.green.shade400,
        ),
      ],
    );
  }
}
