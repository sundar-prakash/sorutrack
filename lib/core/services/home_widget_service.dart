import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HomeWidgetService {
  static const String _androidWidgetName = 'SoruTrackWidgetProvider';

  /// Updates the home screen widget with the latest data.
  Future<void> updateWidget({
    required int streak,
    double? caloriesConsumed,
    double? calorieTarget,
    String? remainingCalories,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>('currentStreak', streak);
      
      final displayCalories = remainingCalories ?? 
          ((calorieTarget ?? 2000) - (caloriesConsumed ?? 0)).toStringAsFixed(0);
      
      await HomeWidget.saveWidgetData<String>('remainingCalories', displayCalories);
      
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
      );
      debugPrint('Home widget updated: Streak=$streak, Remaining=$displayCalories');
    } on PlatformException catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }
}
