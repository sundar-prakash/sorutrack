import 'package:flutter/material.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final int currentAmount;
  final int targetAmount;
  final Color color;
  final double height;
  final Duration animationDuration;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.currentAmount,
    required this.targetAmount,
    required this.color,
    this.height = 8.0,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage = targetAmount > 0 
        ? (currentAmount / targetAmount).clamp(0.0, 1.0) 
        : 0.0;

    return Semantics(
      label: '$label progress',
      value: '$currentAmount of ${targetAmount}g',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$currentAmount / ${targetAmount}g',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2), // Base color
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: percentage),
                      duration: animationDuration,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Container(
                          width: constraints.maxWidth * value,
                          height: height,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(height / 2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
