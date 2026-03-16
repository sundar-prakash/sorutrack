import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/notifications/domain/models/notification_settings.dart';

abstract class NotificationRepository {
  Future<NotificationSettings> getSettings(String userId);
  Future<void> saveSettings(String userId, NotificationSettings settings);
}

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final DatabaseHelper _dbHelper;

  NotificationRepositoryImpl(this._dbHelper);

  @override
  Future<NotificationSettings> getSettings(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notification_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return NotificationSettings.fromMap(maps.first);
    }
    return NotificationSettings.defaultSettings();
  }

  @override
  Future<void> saveSettings(String userId, NotificationSettings settings) async {
    final db = await _dbHelper.database;
    await db.insert(
      'notification_settings',
      {
        ...settings.toMap(),
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
