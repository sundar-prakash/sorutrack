import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sorutrack_pro/features/notifications/domain/models/notification_settings.dart';

import 'notification_repository_impl_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;
  late NotificationRepositoryImpl repository;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    repository = NotificationRepositoryImpl(mockDbHelper);
    when(mockDbHelper.database).thenAnswer((_) async => mockDb);
  });

  group('NotificationRepositoryImpl', () {
    const userId = 'user123';

    test('getSettings returns from DB if exists', () async {
      when(mockDb.query(
        'notification_settings',
        where: 'user_id = ?',
        whereArgs: [userId],
      )).thenAnswer((_) async => [
            {
              'masterEnabled': 0,
              'mealRemindersEnabled': 1,
              'breakfastTime': '07:30',
            }
          ]);

      final result = await repository.getSettings(userId);
      expect(result.masterEnabled, false);
      expect(result.breakfastTime, '07:30');
    });

    test('getSettings returns default if DB is empty', () async {
      when(mockDb.query(
        'notification_settings',
        where: 'user_id = ?',
        whereArgs: [userId],
      )).thenAnswer((_) async => []);

      final result = await repository.getSettings(userId);
      expect(result.masterEnabled, true); // Default
    });

    test('saveSettings inserts with replace', () async {
      when(mockDb.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);
      const settings = NotificationSettings(masterEnabled: false);
      await repository.saveSettings(userId, settings);

      verify(mockDb.insert(
        'notification_settings',
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).called(1);
    });
  });
}
