import 'package:workmanager/workmanager.dart';
import 'package:get_it/get_it.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/data_management/data/services/backup_service.dart';
import 'package:sorutrack_pro/features/notifications/data/services/notification_service.dart';
import 'package:sorutrack_pro/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sorutrack_pro/features/notifications/domain/managers/notification_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sorutrack_pro/core/services/gemini_client.dart';
import 'package:sorutrack_pro/core/services/gemini_key_service.dart';
import 'package:sorutrack_pro/features/meal_log/data/gemini_meal_service.dart';
import 'package:sorutrack_pro/features/reports/data/services/gemini_reports_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize dependencies manually for background isolate
    // Register types for GetIt
    if (!GetIt.I.isRegistered<DatabaseHelper>()) {
      GetIt.I.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
      GetIt.I.registerLazySingleton<NotificationService>(() => NotificationService(FlutterLocalNotificationsPlugin()));
      GetIt.I.registerLazySingleton<NotificationRepository>(
          () => NotificationRepositoryImpl(GetIt.I<DatabaseHelper>()));
      GetIt.I.registerLazySingleton<NotificationManager>(
          () => NotificationManager(GetIt.I<NotificationService>(), GetIt.I<NotificationRepository>()));
      
      // AI Services
      GetIt.I.registerLazySingleton<GeminiKeyService>(() => GeminiKeyService(const FlutterSecureStorage(), Dio()));
      GetIt.I.registerLazySingleton<GeminiClient>(() => GeminiClientImpl());
      GetIt.I.registerLazySingleton<GeminiMealService>(() => GeminiMealService(GetIt.I<GeminiKeyService>(), GetIt.I<GeminiClient>()));
      GetIt.I.registerLazySingleton<GeminiReportsService>(() => GeminiReportsService(GetIt.I<GeminiKeyService>(), GetIt.I<GeminiClient>()));
    }

    final dbHelper = GetIt.I<DatabaseHelper>();
    final notificationManager = GetIt.I<NotificationManager>();

    try {
      if (task == BackgroundTaskService.smartAlertTask) {
        final userId = inputData?['userId'] as String?;
        if (userId != null) {
          // Fetch today's nutrition to check goals
          final today = DateTime.now().toIso8601String().split('T')[0];
          final nutrition = await dbHelper.getTodayNutrition(userId, today);
          final meals = await dbHelper.getMealsByDate(userId, today);
          final loggedMealTypes = meals.map((m) => (m['name'] as String).toLowerCase()).toList();

          // We'd ideally fetch target calories from user repository
          // For now, using default or stored values
          await notificationManager.checkSmartReminders(
            userId,
            currentCalories: (nutrition['calories'] as num?)?.toDouble() ?? 0.0,
            targetCalories: 2000.0, // Should be fetched from profile
            loggedMealTypes: loggedMealTypes,
          );
        }
      }

      final backupService = BackupService();
      await backupService.createFullBackup();
      await backupService.deleteOldBackups(7);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundTaskService {
  static const String autoBackupTask = "com.SoruTrack.autoBackup";
  static const String smartAlertTask = "com.SoruTrack.smartAlerts";

  static Future<void> init() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleSmartAlerts(String userId) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    await Workmanager().registerPeriodicTask(
      "2",
      smartAlertTask,
      frequency: const Duration(hours: 2), // Check every 2 hours
      inputData: {'userId': userId},
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }

  static Future<void> scheduleAutoBackup(Duration frequency) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    await Workmanager().registerPeriodicTask(
      "1",
      autoBackupTask,
      frequency: frequency,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  }

  static Future<void> cancelAutoBackup() async {
    await Workmanager().cancelByUniqueName("1");
  }
}
