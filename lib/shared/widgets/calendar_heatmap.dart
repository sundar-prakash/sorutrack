import 'package:flutter/material.dart';

class CalendarHeatmap extends StatelessWidget {
  final Map<DateTime, int>
      data; // Date to value mapping (e.g. calories met, XP earned)
  final int maxValue;
  final Color baseColor;

  const CalendarHeatmap({
    super.key,
    required this.data,
    required this.maxValue,
    this.baseColor = const Color(0xFF2D6A4F), // Primary Green
  });

  @override
  Widget build(BuildContext context) {
    // Generate last 7 weeks (49 days)
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 48));

    // Group by weeks
    List<List<DateTime>> weeks = [];
    List<DateTime> currentWeek = [];

    for (int i = 0; i < 49; i++) {
      currentWeek.add(startDate.add(Duration(days: i)));
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Align to the right
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: weeks.map((week) {
          return Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: week.map((date) {
                // Remove time part for accurate map lookup
                final dateKey = DateTime(date.year, date.month, date.day);
                final value = data[dateKey] ?? 0;

                // Calculate opacity based on max value
                double opacity =
                    value == 0 ? 0.1 : (value / maxValue).clamp(0.2, 1.0);

                return Tooltip(
                  message: '${date.month}/${date.day}: $value',
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: value > 0
                          ? baseColor.withValues(alpha: opacity)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
