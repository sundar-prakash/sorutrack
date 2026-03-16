import 'package:flutter/material.dart';

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int targetXP;
  final int currentLevel;
  final Color color;
  final double height;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.targetXP,
    required this.currentLevel,
    this.color = const Color(0xFFF4A261), // Accent color
    this.height = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage =
        targetXP > 0 ? (currentXP / targetXP).clamp(0.0, 1.0) : 0.0;

    return Semantics(
      label: 'Level $currentLevel, $currentXP out of $targetXP XP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '$currentXP / $targetXP XP',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: percentage),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Container(
                          width: constraints.maxWidth * value,
                          height: height,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(height / 2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: -1,
                                offset: const Offset(0, 0), // Glow effect
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
