import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/features/data_management/data/services/backup_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

void main() {
  late BackupService backupService;
  late String tempDirPath;
  late String dbDirPath;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirPath = Directory.systemTemp.createTempSync('sorutrack_test_').path;
    final dbPathFromFactory = await getDatabasesPath();
    dbDirPath = dbPathFromFactory;
    
    // Ensure the directory exists
    await Directory(dbDirPath).create(recursive: true);

    // Mock path_provider method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDirPath;
        }
        if (methodCall.method == 'getTemporaryDirectory') {
          return tempDirPath;
        }
        return null;
      },
    );

    // Create a dummy database file
    final dbFile = File(p.join(dbDirPath, 'sorutrack_pro.db'));
    await dbFile.writeAsString('dummy_database_content');

    backupService = BackupService();
  });

  tearDown(() async {
    await Directory(tempDirPath).delete(recursive: true);
  });

  group('BackupService', () {
    test('createFullBackup should copy the database file to backups directory', () async {
      // Act
      final backupFile = await backupService.createFullBackup();

      // Assert
      expect(await backupFile.exists(), true);
      expect(backupFile.path.contains('backups'), true);
      expect(await backupFile.readAsString(), 'dummy_database_content');
    });

    test('createEncryptedBackup should create an encrypted file that can be restored', () async {
      // Arrange
      const password = 'secure_password';

      // Act
      final encryptedFile = await backupService.createEncryptedBackup(password);

      // Assert
      expect(await encryptedFile.exists(), true);
      expect(encryptedFile.path.endsWith('.SoruTackbackup'), true);
      
      // Verify it's not plain text
      final encryptedBytes = await encryptedFile.readAsBytes();
      final originalBytes = utf8.encode('dummy_database_content');
      expect(encryptedBytes, isNot(originalBytes));

      // Restore
      await backupService.restoreFromEncryptedBackup(encryptedFile, password);

      // Verify restoration (check the "database" file again)
      final dbFile = File(p.join(dbDirPath, 'sorutrack_pro.db'));
      expect(await dbFile.readAsString(), 'dummy_database_content');
    });

    test('restoreFromEncryptedBackup should throw exception with wrong password', () async {
      // Arrange
      const password = 'correct_password';
      final encryptedFile = await backupService.createEncryptedBackup(password);

      // Act & Assert
      expect(
        () => backupService.restoreFromEncryptedBackup(encryptedFile, 'wrong_password'),
        throwsA(isA<Exception>()),
      );
    });

    test('createCircularBackup should keep only 4 backups', () async {
      // Arrange
      final soruFolder = p.join(tempDirPath, 'circular');
      await Directory(soruFolder).create(recursive: true);

      // Act: Create 6 backups (simulating different days by manually modifying timestamps? 
      // No, BackupService uses DateFormat('yyyyMMdd').format(DateTime.now()), 
      // so I need to manually create files with different names to simulate rotation cleanup).
      
      final folder = Directory(p.join(soruFolder, 'sorutrack'));
      await folder.create(recursive: true);
      
      for (int i = 1; i <= 6; i++) {
        final dummyBackup = File(p.join(folder.path, 'sorutrack_backup_2026040$i.db'));
        await dummyBackup.writeAsString('old_data');
        // Small delay to ensure different modification times if needed
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Assert before cleanup (manually added files)
      expect(folder.listSync().length, 6);

      // Run one more manual cleanup or trigger it via a new backup
      await backupService.createCircularBackup(soruFolder);

      // Assert: Should have 4 backups left
      expect(folder.listSync().length, 4);
    });

    test('restoreRawBackup should overwrite current database', () async {
      // Arrange
      final rawBackup = File(p.join(tempDirPath, 'raw.db'));
      await rawBackup.writeAsString('new_raw_content');

      // Act
      await backupService.restoreRawBackup(rawBackup);

      // Assert
      final dbFile = File(p.join(dbDirPath, 'sorutrack_pro.db'));
      expect(await dbFile.readAsString(), 'new_raw_content');
    });
  });
}
