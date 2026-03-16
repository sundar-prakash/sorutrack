import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Create Notification Channels for Android
    await _createChannels();
  }

  Future<void> _createChannels() async {
    const mealChannel = AndroidNotificationChannel(
      'meal_reminders',
      'Meal Reminders',
      description: 'Scheduled reminders for breakfast, lunch, and dinner.',
      importance: Importance.defaultImportance,
    );

    const streakChannel = AndroidNotificationChannel(
      'streak_alerts',
      'Streak Alerts',
      description: 'High priority alerts to protect your login streak.',
      importance: Importance.high,
    );

    const waterChannel = AndroidNotificationChannel(
      'water_reminders',
      'Water Reminders',
      description: 'Periodic hydration reminders.',
      importance: Importance.low,
    );

    const achievementChannel = AndroidNotificationChannel(
      'achievements',
      'Achievements',
      description: 'Notifications for badges and level ups.',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(mealChannel);
      await androidPlugin.createNotificationChannel(streakChannel);
      await androidPlugin.createNotificationChannel(waterChannel);
      await androidPlugin.createNotificationChannel(achievementChannel);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'meal_reminders',
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.replaceAll('_', ' ').toUpperCase(),
          importance: Importance.max,
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
    String? payload,
    String channelId = 'meal_reminders',
    DateTimeComponents? matchDateTimeComponents,
  }) async {
//    await _notifications.zonedSchedule(
//      id,
//      title,
//      body,
//      tz.TZDateTime.from(scheduledDate, tz.local),
//      NotificationDetails(
//        android: AndroidNotificationDetails(
//          channelId,
//          channelId.replaceAll('_', ' ').toUpperCase(),
//        ),
//        iOS: const DarwinNotificationDetails(),
//      ),
//      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//      uiLocalNotificationDateInterpretation:
//          UILocalNotificationDateInterpretation.absoluteTime,
//      matchDateTimeComponents: matchDateTimeComponents,
//      payload: payload,
//    );
  }

  Future<void> cancelNotification(int id) async {
    // await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }
}
