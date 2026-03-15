import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep2 extends StatelessWidget {
  final double height;
  final HeightUnit heightUnit;
  final double weight;
  final WeightUnit weightUnit;
  final Function(double, HeightUnit) onHeightChanged;
  final Function(double, WeightUnit) onWeightChanged;

  const OnboardingStep2({
    super.key,
    required this.height,
    required this.heightUnit,
    required this.weight,
    required this.weightUnit,
    required this.onHeightChanged,
    required this.onWeightChanged,
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
              'Body Metrics',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Help us calculate your calorie needs accurately.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _MetricInput(
              label: 'Height',
              value: height,
              unit: heightUnit.name,
              onChanged: (val) => onHeightChanged(val, heightUnit),
              onUnitToggle: () => onHeightChanged(
                  height, heightUnit == HeightUnit.cm ? HeightUnit.ft : HeightUnit.cm),
            ),
            const SizedBox(height: 24),
            _MetricInput(
              label: 'Weight',
              value: weight,
              unit: weightUnit.name,
              onChanged: (val) => onWeightChanged(val, weightUnit),
              onUnitToggle: () => onWeightChanged(
                  weight, weightUnit == WeightUnit.kg ? WeightUnit.lbs : WeightUnit.kg),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricInput extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Function(double) onChanged;
  final VoidCallback onUnitToggle;

  const _MetricInput({
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    required this.onUnitToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(0, 300),
                min: 0,
                max: 300,
                divisions: 300,
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
            TextButton(
              onPressed: onUnitToggle,
              child: Text(unit.toUpperCase()),
            ),
          ],
        ),
        Center(
          child: Text(
            '${value.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}
