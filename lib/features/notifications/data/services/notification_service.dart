import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  NotificationService(this._notifications);

  Future<void> init() async {
    if (kIsWeb || (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST'))) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    const mealChannel = AndroidNotificationChannel(
      'meal_reminders',
      'Meal Reminders',
      description: 'Scheduled reminders for breakfast, lunch, and dinner.',
      importance: Importance.high,
    );

    const waterChannel = AndroidNotificationChannel(
      'water_reminders',
      'Water Reminders',
      description: 'Scheduled reminders for water intake.',
      importance: Importance.high,
    );

    const achievementChannel = AndroidNotificationChannel(
      'achievements',
      'Achievements',
      description: 'Progress and goal notifications.',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(mealChannel);
      await androidPlugin.createNotificationChannel(waterChannel);
      await androidPlugin.createNotificationChannel(achievementChannel);
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST'))) return;
    
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'meal_reminders',
  }) async {
    if (kIsWeb) return;
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          channelDescription: 'Notification channel for $channelId',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'meal_reminders',
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (kIsWeb) return;

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          channelDescription: 'Notification channel for $channelId',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  /// Convenience method for 3x daily meal reminders
  Future<void> scheduleMealReminders() async {
    if (kIsWeb) return;
    await _scheduleInternalDaily(101, 'Breakfast Time!', 'Time to log your morning meal.', 8, 0);
    await _scheduleInternalDaily(102, 'Lunch Time!', 'Stay on track with your lunch.', 13, 0);
    await _scheduleInternalDaily(103, 'Dinner Time!', 'Final meal of the day? Log it now.', 20, 0);
  }

  Future<void> cancelMealReminders() async {
    await cancelNotification(101);
    await cancelNotification(102);
    await cancelNotification(103);
  }

  /// Convenience method for 3x daily water reminders
  Future<void> scheduleWaterReminders() async {
    if (kIsWeb) return;
    await _scheduleInternalDaily(201, 'Hydration Check!', 'Start your day (8:30 AM) with a glass of water.', 8, 30, channel: 'water_reminders');
    await _scheduleInternalDaily(202, 'Drink Water!', 'Don\'t forget to stay hydrated (1:30 PM).', 13, 30, channel: 'water_reminders');
    await _scheduleInternalDaily(203, 'Water Reminder!', 'Evening hydration (6 PM) check.', 18, 0, channel: 'water_reminders');
  }

  Future<void> cancelWaterReminders() async {
    await cancelNotification(201);
    await cancelNotification(202);
    await cancelNotification(203);
  }

  Future<void> _scheduleInternalDaily(int id, String title, String body, int hour, int minute, {String channel = 'meal_reminders'}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      channelId: channel,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
