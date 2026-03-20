import 'package:flutter/material.dart';

class WaterTrackerWidget extends StatelessWidget {
  final double currentMl;
  final double targetMl;
  final VoidCallback? onAddWater;

  const WaterTrackerWidget({
    super.key,
    required this.currentMl,
    required this.targetMl,
    this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentMl / targetMl).clamp(0.0, 1.0);
    final glasses = (currentMl / 250).floor(); // Assuming 250ml per glass
    final targetGlasses = (targetMl / 250).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_drink, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Water Tracker',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${currentMl.toInt()} / ${targetMl.toInt()} ml',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(targetGlasses, (index) {
              return Icon(
                index < glasses ? Icons.local_drink : Icons.local_drink_outlined,
                color: index < glasses ? Colors.blue.shade600 : Colors.blue.shade200,
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddWater,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('+ Add 250ml'),
            ),
          ),
        ],
      ),
    );
  }
}
