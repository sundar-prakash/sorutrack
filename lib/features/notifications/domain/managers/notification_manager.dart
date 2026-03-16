import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../models/notification_settings.dart';
import '../repositories/notification_repository.dart';
import '../../data/services/notification_service.dart';

@lazySingleton
class NotificationManager {
  final NotificationService _notificationService;
  final NotificationRepository _repository;

  NotificationManager(this._notificationService, this._repository);

  /// Reschedule all enabled notifications based on user settings
  Future<void> rescheduleAll(String userId) async {
    final settings = await _repository.getSettings(userId);
    await _notificationService.cancelAllNotifications();

    if (!settings.masterEnabled) return;

    if (settings.mealRemindersEnabled) {
      await _scheduleMealReminders(settings);
    }

    if (settings.waterRemindersEnabled) {
      await _scheduleWaterReminders(settings);
    }

    if (settings.streakProtectionEnabled) {
      await _scheduleStreakProtection();
    }
    
    // Smart reminders and weekly summary often handled by background tasks
  }

  Future<void> _scheduleMealReminders(NotificationSettings settings) async {
    // Breakfast
    await _scheduleDaily(
      id: 101,
      title: "Time to log your breakfast! 🍳",
      body: "What did you eat for your first meal of the day?",
      time: settings.breakfastTime,
      channelId: 'meal_reminders',
    );

    // Lunch
    await _scheduleDaily(
      id: 102,
      title: "Lunch time! 🥗",
      body: "Don't forget to log your lunch to stay on track.",
      time: settings.lunchTime,
      channelId: 'meal_reminders',
    );

    // Dinner
    await _scheduleDaily(
      id: 103,
      title: "Dinner is served! 🍲",
      body: "Time for a healthy dinner. What are you having?",
      time: settings.dinnerTime,
      channelId: 'meal_reminders',
    );
  }

  Future<void> _scheduleWaterReminders(NotificationSettings settings) async {
    // Water reminders are repeating throughout the day
    // For flutter_local_notifications, we might need to schedule multiple 
    // individual notifications or use a repeating interval if supported simply.
    // Given the "sleep hours" requirement, scheduling individual ones for the day is more robust.
    
    final startTime = _parseTime(settings.sleepEndTime); // Ends sleep = Starts day
    final endTime = _parseTime(settings.sleepStartTime);   // Starts sleep = Ends day
    
    DateTime now = DateTime.now();
    DateTime triggerDate = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    DateTime stopDate = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
    
    if (stopDate.isBefore(triggerDate)) {
      stopDate = stopDate.add(const Duration(days: 1));
    }

    int id = 200;
    while (triggerDate.isBefore(stopDate)) {
      if (triggerDate.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: id++,
          title: "💧 Time to hydrate!",
          body: "Keep that water intake up! Each glass counts.",
          scheduledDate: triggerDate,
          channelId: 'water_reminders',
        );
      }
      triggerDate = triggerDate.add(Duration(hours: settings.waterIntervalHours));
    }
  }

  Future<void> _scheduleStreakProtection() async {
    // 8 PM daily reminder
    await _scheduleDaily(
      id: 301,
      title: "Don't break your streak! 🔥",
      body: "Log today's meals to keep your progress alive.",
      time: "20:00",
      channelId: 'streak_alerts',
    );

    // 10 PM final warning
    await _scheduleDaily(
      id: 302,
      title: "Final Warning! ⚠️",
      body: "Your streak is at risk! Log now to save it.",
      time: "22:00",
      channelId: 'streak_alerts',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required String time,
    required String channelId,
  }) async {
    final parsedTime = _parseTime(time);
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      channelId: channelId,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 0, 0, int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Triggered by WorkManager for context-aware alerts
  Future<void> checkSmartReminders(String userId, {
    required double currentCalories,
    required double targetCalories,
    required List<String> loggedMealTypes,
  }) async {
    final settings = await _repository.getSettings(userId);
    if (!settings.masterEnabled || !settings.smartRemindersEnabled) return;

    final now = DateTime.now();
    
    // Missing logs checks
    if (now.hour >= 10 && !loggedMealTypes.contains('breakfast')) {
      await _notificationService.showNotification(
        id: 401,
        title: "Missing Breakfast Log? 🍳",
        body: "It's past 10 AM. Don't forget to log your breakfast!",
        channelId: 'meal_reminders',
      );
    }

    if (now.hour >= 15 && !loggedMealTypes.contains('lunch')) {
      await _notificationService.showNotification(
        id: 402,
        title: "Lunch not logged? 🥗",
        body: "Keep your diary updated. Log your lunch now!",
        channelId: 'meal_reminders',
      );
    }

    // Calorie goal checks
    final remaining = targetCalories - currentCalories;
    if (remaining > 0 && remaining <= 150) {
      await _notificationService.showNotification(
        id: 501,
        title: "Almost there! 🎯",
        body: "You're just $remaining cal from your goal. Great job!",
        channelId: 'achievements',
      );
    } else if (remaining < 0) {
      final over = remaining.abs();
      if (over > 0 && over < 500) { // Only notify if slightly over to avoid being too annoying
        await _notificationService.showNotification(
          id: 502,
          title: "Goal exceeded 💪",
          body: "Oops! You're ${over.toInt()} cal over. Tomorrow is a fresh start!",
          channelId: 'achievements',
        );
      }
    }
  }
}
