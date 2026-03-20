import 'package:flutter/material.dart' hide Badge;
import 'package:sorutrack_pro/features/gamification/domain/models/gamification_models.dart';

class BadgeItem extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;

  const BadgeItem({
    super.key,
    required this.badge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isUnlocked ? badge.description : 'Locked: ${badge.name}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getColorIcon(),
              size: 40,
              color: isUnlocked
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isUnlocked ? null : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  IconData getColorIcon() {
    return switch (badge.category) {
      'streak' => Icons.whatshot,
      'nutrition' => Icons.restaurant,
      'milestone' => Icons.emoji_events,
      _ => Icons.stars,
    };
  }
}
