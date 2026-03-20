import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Duolingo-style animated streak card.
/// Reads and writes streak to SharedPreferences.
class StreakCardWidget extends StatefulWidget {
  const StreakCardWidget({super.key});

  @override
  State<StreakCardWidget> createState() => _StreakCardWidgetState();

  /// Call this when user logs a meal to credit the streak.
  static Future<void> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogStr = prefs.getString('streakLastLogDate');
    final today = _dateOnly(DateTime.now());

    int newStreak = 1;
    if (lastLogStr != null) {
      final lastLog = _dateOnly(DateTime.parse(lastLogStr));
      final diff = today.difference(lastLog).inDays;
      if (diff == 0) {
        // Already logged today — keep current streak
        newStreak = prefs.getInt('currentStreak') ?? 1;
      } else if (diff == 1) {
        // Yesterday → extend streak
        newStreak = (prefs.getInt('currentStreak') ?? 0) + 1;
      }
      // diff > 1 → reset to 1 (new streak starts today)
    }

    await prefs.setInt('currentStreak', newStreak);
    await prefs.setString('streakLastLogDate', today.toIso8601String());
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}

class _StreakCardWidgetState extends State<StreakCardWidget>
    with SingleTickerProviderStateMixin {
  int _streak = 0;
  bool _loggedToday = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1)
            .chain(CurveTween(curve: Curves.elasticIn)),
        weight: 50,
      ),
    ]).animate(_animController);

    _loadStreak();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogStr = prefs.getString('streakLastLogDate');
    final streak = prefs.getInt('currentStreak') ?? 0;
    final today = StreakCardWidget._dateOnly(DateTime.now());

    if (lastLogStr != null) {
      final lastLog = StreakCardWidget._dateOnly(DateTime.parse(lastLogStr));
      final diff = today.difference(lastLog).inDays;

      if (diff == 0) {
        // Already logged today
        setState(() {
          _streak = streak;
          _loggedToday = true;
        });
      } else if (diff == 1) {
        // Logged yesterday — streak alive but not yet logged today
        setState(() {
          _streak = streak;
          _loggedToday = false;
        });
      } else {
        // Missed a day — reset streak
        await prefs.setInt('currentStreak', 0);
        setState(() {
          _streak = 0;
          _loggedToday = false;
        });
      }
    } else {
      setState(() {
        _streak = 0;
        _loggedToday = false;
      });
    }
  }

  Color get _flameColor {
    if (_streak >= 30) return const Color(0xFFFF4500); // Red hot
    if (_streak >= 7) return const Color(0xFFFF8C00);  // Deep orange
    if (_streak >= 3) return const Color(0xFFFFA500);  // Orange
    return const Color(0xFFFFD700);                     // Gold starter
  }

  String get _streakLabel {
    if (_streak == 0) return 'Start your streak today!';
    if (_streak == 1) return '1 day — keep it up!';
    if (_streak < 7) return '$_streak day streak 🔥';
    if (_streak < 30) return '$_streak days — you\'re on fire! 🔥';
    return '$_streak days — legend! 🏆';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _streak > 0
                ? [
                    _flameColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    _flameColor.withValues(alpha: isDark ? 0.10 : 0.05),
                  ]
                : [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest,
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _streak > 0
                ? _flameColor.withValues(alpha: 0.4)
                : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            // Animated flame
            _FlameIcon(streak: _streak, color: _flameColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _streak == 0 ? '0' : '$_streak',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _streak > 0 ? _flameColor : theme.disabledColor,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    _streakLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            // Logged today badge
            if (_loggedToday)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text('Logged',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              )
            else if (_streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.alarm, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text('Log today!',
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Flame icon widget ─────────────────────────────────────────────────────────

class _FlameIcon extends StatefulWidget {
  final int streak;
  final Color color;

  const _FlameIcon({required this.streak, required this.color});

  @override
  State<_FlameIcon> createState() => _FlameIconState();
}

class _FlameIconState extends State<_FlameIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flicker;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _flicker = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streak == 0) {
      return Icon(Icons.local_fire_department_outlined,
          size: 44, color: Colors.grey.shade400);
    }
    return AnimatedBuilder(
      animation: _flicker,
      builder: (context, child) => Transform.scale(
        scale: _flicker.value,
        child: child,
      ),
      child: Icon(
        Icons.local_fire_department,
        size: 48,
        color: widget.color,
        shadows: [
          Shadow(
            blurRadius: 12,
            color: widget.color.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
