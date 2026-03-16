import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/di/injection.dart';
import 'core/database/database_helper.dart';
import 'core/services/background_task_service.dart';
import 'app.dart';
import 'package:logger/logger.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Timezone
  tz.initializeTimeZones();

  // Initialize Background Tasks
  if (!kIsWeb) {
    await BackgroundTaskService.init();
    await BackgroundTaskService.scheduleAutoBackup(const Duration(days: 1));
  }

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
  // Setup HydratedBloc Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );

  runApp(const SoruTrackProApp());
}
