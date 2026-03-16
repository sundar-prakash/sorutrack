import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep5 extends StatelessWidget {
  final double currentWeight;
  final GoalType goal;
  final double targetWeight;
  final double weeklyGoal;
  final WeightUnit weightUnit;
  final String? error;
  final Function(double) onTargetWeightChanged;
  final Function(double) onWeeklyGoalChanged;

  const OnboardingStep5({
    super.key,
    required this.currentWeight,
    required this.goal,
    required this.targetWeight,
    required this.weeklyGoal,
    required this.weightUnit,
    this.error,
    required this.onTargetWeightChanged,
    required this.onWeeklyGoalChanged,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Target Weight (${weightUnit.name})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  _TargetWeightInput(
                    value: targetWeight,
                    unit: weightUnit.name,
                    onChanged: onTargetWeightChanged,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: targetWeight.clamp(_getMinTargetWeight(), _getMaxTargetWeight()),
                min: _getMinTargetWeight(),
                max: _getMaxTargetWeight(),
                divisions: ((_getMaxTargetWeight() - _getMinTargetWeight()) * 2).toInt(),
                label: '${targetWeight.toStringAsFixed(1)} ${weightUnit.name}',
                onChanged: onTargetWeightChanged,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
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
                    selectedColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
      ),
    );
  }

  double _getMinTargetWeight() {
    if (goal == GoalType.loseWeight) return 20.0;
    if (goal == GoalType.gainMuscle) return currentWeight;
    return 20.0;
  }

  double _getMaxTargetWeight() {
    if (goal == GoalType.loseWeight) return currentWeight;
    if (goal == GoalType.gainMuscle) return 300.0;
    return 300.0;
  }

  String _getPaceDescription(double val) {
    if (val <= 0.25) return "Pace: Slow & Steady (Most sustainable)";
    if (val <= 0.5) return "Pace: Moderate (Recommended)";
    if (val <= 0.75) return "Pace: Fast (Requires discipline)";
    return "Pace: Aggressive (Talk to a professional)";
  }
}

class _TargetWeightInput extends StatefulWidget {
  final double value;
  final String unit;
  final Function(double) onChanged;

  const _TargetWeightInput({
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<_TargetWeightInput> createState() => _TargetWeightInputState();
}

class _TargetWeightInputState extends State<_TargetWeightInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(_TargetWeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && 
        double.tryParse(_controller.text) != widget.value) {
      _controller.text = widget.value.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          suffixText: " ${widget.unit}",
        ),
        onChanged: (val) {
          final parsed = double.tryParse(val);
          if (parsed != null) widget.onChanged(parsed);
        },
      ),
    );
  }
}
