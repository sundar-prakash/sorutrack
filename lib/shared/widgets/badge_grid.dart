import 'package:flutter/material.dart';

class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String iconDetails; // Emoji or asset path
  final bool isUnlocked;

  BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconDetails,
    required this.isUnlocked,
  });
}

class BadgeGrid extends StatelessWidget {
  final List<BadgeItem> badges;

  const BadgeGrid({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _BadgeCard(badge: badge);
      },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeItem badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Badge: ${badge.title}',
      hint: badge.isUnlocked
          ? 'Unlocked. ${badge.description}'
          : 'Locked. ${badge.description}',
      child: Tooltip(
        message: '${badge.title}\n${badge.description}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show badge details dialog
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badge.isUnlocked
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: badge.isUnlocked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.5),
                        width: badge.isUnlocked ? 2 : 1,
                      ),
                      boxShadow: badge.isUnlocked
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Opacity(
                      opacity: badge.isUnlocked ? 1.0 : 0.3,
                      child: Text(
                        badge.iconDetails, // E.g., '🏆', '🔥'
                        style: const TextStyle(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: badge.isUnlocked
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: badge.isUnlocked
                          ? null
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
