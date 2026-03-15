import 'package:flutter/material.dart';

class NutriSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor = theme.colorScheme.surfaceVariant;
    Color textColor = theme.colorScheme.onSurfaceVariant;
    IconData icon = Icons.info_outline;

    if (isError) {
      backgroundColor = theme.colorScheme.error;
      textColor = theme.colorScheme.onError;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = const Color(0xFF10B981); // Success Green
      textColor = Colors.white;
      icon = Icons.check_circle_outline;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      elevation: 4,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
