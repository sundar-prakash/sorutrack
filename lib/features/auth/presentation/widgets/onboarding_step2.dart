import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/models/auth_enums.dart';

class OnboardingStep2 extends StatelessWidget {
  final double height;
  final HeightUnit heightUnit;
  final double weight;
  final WeightUnit weightUnit;
  final String? error;
  final Function(double, HeightUnit) onHeightChanged;
  final Function(double, WeightUnit) onWeightChanged;

  const OnboardingStep2({
    super.key,
    required this.height,
    required this.heightUnit,
    required this.weight,
    required this.weightUnit,
    this.error,
    required this.onHeightChanged,
    required this.onWeightChanged,
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
                error: error,
                onChanged: (val) => onHeightChanged(val, heightUnit),
                onUnitToggle: () => onHeightChanged(
                    height, heightUnit == HeightUnit.cm ? HeightUnit.ft : HeightUnit.cm),
              ),
              const SizedBox(height: 24),
              _MetricInput(
                label: 'Weight',
                value: weight,
                unit: weightUnit.name,
                error: error,
                onChanged: (val) => onWeightChanged(val, weightUnit),
                onUnitToggle: () => onWeightChanged(
                    weight, weightUnit == WeightUnit.kg ? WeightUnit.lbs : WeightUnit.kg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricInput extends StatefulWidget {
  final String label;
  final double value;
  final String unit;
  final String? error;
  final Function(double) onChanged;
  final VoidCallback onUnitToggle;

  const _MetricInput({
    required this.label,
    required this.value,
    required this.unit,
    this.error,
    required this.onChanged,
    required this.onUnitToggle,
  });

  @override
  State<_MetricInput> createState() => _MetricInputState();
}

class _MetricInputState extends State<_MetricInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(_MetricInput oldWidget) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              width: 80,
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
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: widget.value.clamp(0, 300),
                min: 0,
                max: 300,
                divisions: 600,
                label: widget.value.toStringAsFixed(1),
                onChanged: widget.onChanged,
              ),
            ),
            TextButton(
              onPressed: widget.onUnitToggle,
              child: Text(widget.unit.toUpperCase()),
            ),
          ],
        ),
        if (widget.error != null && widget.error!.toLowerCase().contains(widget.label.toLowerCase()))
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
