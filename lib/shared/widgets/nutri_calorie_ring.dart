import 'package:flutter/material.dart';
import 'dart:math';

class NutriCalorieRing extends StatefulWidget {
  final int consumedCalories;
  final int targetCalories;
  final double size;
  final double strokeWidth;
  final Color baseColor;
  final Color progressColor;
  final bool animate;

  const NutriCalorieRing({
    super.key,
    required this.consumedCalories,
    required this.targetCalories,
    this.size = 200,
    this.strokeWidth = 16,
    this.baseColor = const Color(0x332D6A4F), // Light primary
    this.progressColor = const Color(0xFF2D6A4F), // Primary
    this.animate = true,
  });

  @override
  State<NutriCalorieRing> createState() => _NutriCalorieRingState();
}

class _NutriCalorieRingState extends State<NutriCalorieRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final double targetPercentage = widget.targetCalories > 0
        ? (widget.consumedCalories / widget.targetCalories).clamp(0.0, 1.0)
        : 0.0;

    _animation = Tween<double>(begin: 0, end: targetPercentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant NutriCalorieRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumedCalories != widget.consumedCalories ||
        oldWidget.targetCalories != widget.targetCalories) {
      final double targetPercentage = widget.targetCalories > 0
          ? (widget.consumedCalories / widget.targetCalories).clamp(0.0, 1.0)
          : 0.0;

      _animation = Tween<double>(
        begin: _animation.value,
        end: targetPercentage,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Daily Calories',
      value:
          '${(widget.consumedCalories)}. of ${widget.targetCalories} kcal consumed',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: _animation.value,
                    strokeWidth: widget.strokeWidth,
                    baseColor: widget.baseColor,
                    progressColor: widget.progressColor,
                  ),
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final displayValue =
                        (_animation.value * widget.targetCalories).round();
                    return Text(
                      displayValue.toString(),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${widget.targetCalories} kcal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color baseColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.baseColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw base ring
    canvas.drawCircle(center, radius, basePaint);

    // Draw progress ring (Start from top: -pi/2)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor;
  }
}
