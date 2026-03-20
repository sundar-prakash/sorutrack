import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class StreakFlame extends StatelessWidget {
  final int streak;
  final bool isActiveToday;
  final double size;

  const StreakFlame({
    super.key,
    required this.streak,
    required this.isActiveToday,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActiveToday)
          Pulse(
            infinite: true,
            duration: const Duration(seconds: 2),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: size,
            ),
          )
        else
          Icon(
            Icons.local_fire_department,
            color: Colors.grey,
            size: size,
          ),
        Text(
          '$streak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActiveToday ? Colors.orange : Colors.grey,
            fontSize: size * 0.6,
          ),
        ),
      ],
    );
  }
}
