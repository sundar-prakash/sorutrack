import 'package:flutter/material.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealTypeChip extends StatelessWidget {
  final MealType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const MealTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color getBaseColor() {
      switch (type) {
        case MealType.breakfast:
          return const Color(0xFFF39C12); // Orange-ish
        case MealType.lunch:
          return const Color(0xFF2E86C1); // Blue-ish
        case MealType.dinner:
          return const Color(0xFF8E44AD); // Purple-ish
        case MealType.snack:
          return const Color(0xFF27AE60); // Green-ish
      }
    }

    String getIcon() {
      switch (type) {
        case MealType.breakfast:
          return '🌅';
        case MealType.lunch:
          return '☀️';
        case MealType.dinner:
          return '🌙';
        case MealType.snack:
          return '🍎';
      }
    }
    
    final baseColor = getBaseColor();
    final bgColor = isSelected ? baseColor : baseColor.withOpacity(0.1);
    final textColor = isSelected ? Colors.white : baseColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Meal type ${type.name}',
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(getIcon(), style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  type.name[0].toUpperCase() + type.name.substring(1),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
