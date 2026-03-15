import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/di/injection.dart';
import 'core/database/database_helper.dart';
import 'core/services/background_task_service.dart';
import 'app.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Timezone
  tz.initializeTimeZones();

  // Initialize Background Tasks
  await BackgroundTaskService.init();
  await BackgroundTaskService.scheduleAutoBackup(const Duration(days: 1));

  // Initialize Dependency Injection
  await configureDependencies();

  // Initialize Database
  final dbHelper = getIt<DatabaseHelper>();
  await dbHelper.database;

  // Setup error logging
  final logger = getIt<Logger>();
  FlutterError.onError = (details) {
    logger.e('Flutter Error', error: details.exception, stackTrace: details.stack);
  };

  runApp(const SoruTrackProApp());
}
