import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

@lazySingleton
class BackupService {
  final Logger _logger = Logger();
  static const String backupExtension = '.SoruTackbackup';

  /// Create a full backup of the SQLite database file in a specific directory
  Future<File> createFullBackup({String? targetPath}) async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'sorutrack_pro.db');
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database file not found');
    }

    String finalPath;
    if (targetPath != null) {
      finalPath = targetPath;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(join(directory.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      finalPath = join(backupDir.path, 'sorutrack_backup_$timestamp.db');
    }

    final file = File(finalPath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    return await sourceFile.copy(finalPath);
  }

  /// Create a circular backup (keeps 4 days) in a specific directory
  Future<File> createCircularBackup(String baseDirectoryPath) async {
    // 1. Ensure "sorutrack" folder exists
    final soruFolder = Directory(join(baseDirectoryPath, 'sorutrack'));
    if (!await soruFolder.exists()) {
      await soruFolder.create(recursive: true);
    }

    // 2. Identify rotation slot (1 to 4) based on today
    // We can use a simple rotation or just keep the latest 4 with timestamps.
    // The user said "4 days in a circle", so using day of month % 4 is a simple way
    // but might not be ideal if they skip days.
    // Better: List existing backups and rotate.
    
    final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
    final backupPath = join(soruFolder.path, 'sorutrack_backup_$timestamp.db');
    
    final file = await createFullBackup(targetPath: backupPath);

    // 3. Clean up older backups, keeping only 4
    await _cleanupCircularBackups(soruFolder);

    return file;
  }

  Future<void> _cleanupCircularBackups(Directory folder) async {
    final files = folder.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    if (files.length > 4) {
      for (var i = 4; i < files.length; i++) {
        await files[i].delete();
      }
    }
  }

  /// Create an encrypted backup file
  Future<File> createEncryptedBackup(String password, {String? targetPath}) async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'sorutrack_pro.db');
    final sourceFile = File(sourcePath);
    final bytes = await sourceFile.readAsBytes();

    final key = _deriveKey(password);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    
    // Metadata: version + schema version + IV
    final metadata = {
      'app_version': '1.0.0',
      'schema_version': 5,
      'iv': iv.base64,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final metadataJson = jsonEncode(metadata);
    final metadataBytes = utf8.encode(metadataJson);
    final metadataLength = metadataBytes.length;

    // File structure: [4 bytes metadata length] [metadata] [encrypted data]
    final result = BytesBuilder();
    final lengthBuffer = ByteData(4)..setInt32(0, metadataLength);
    result.add(lengthBuffer.buffer.asUint8List());
    result.add(metadataBytes);
    result.add(encrypted.bytes);

    String finalPath;
    if (targetPath != null) {
      finalPath = targetPath;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      finalPath = join(directory.path, 'backups', 'sorutrack_secure_$timestamp$backupExtension');
    }
    
    final file = File(finalPath);
    if (!await file.parent.exists()) await file.parent.create(recursive: true);
    
    await file.writeAsBytes(result.toBytes());
    return file;
  }

  /// Restore from an encrypted backup
  Future<void> restoreFromEncryptedBackup(File backupFile, String password) async {
    final bytes = await backupFile.readAsBytes();
    if (bytes.length < 4) throw Exception('Invalid backup file');

    final metadataLength = ByteData.sublistView(bytes, 0, 4).getInt32(0);
    final metadataJson = utf8.decode(bytes.sublist(4, 4 + metadataLength));
    final metadata = jsonDecode(metadataJson);
    
    final iv = encrypt.IV.fromBase64(metadata['iv']);
    final encryptedData = bytes.sublist(4 + metadataLength);

    final key = _deriveKey(password);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    try {
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedData), iv: iv);
      
      final dbPath = await getDatabasesPath();
      final targetPath = join(dbPath, 'sorutrack_pro.db');
      
      // Close the current DB before overwriting? 
      // Usually sqflite handles this if we overwrite and restart, 
      // but it's safer to ensure it's not in use.
      await deleteDatabase(targetPath);
      await File(targetPath).writeAsBytes(decrypted);
      
      _logger.i('Database restored successfully from encrypted backup');
    } catch (e) {
      _logger.e('Failed to decrypt backup: $e');
      throw Exception('Incorrect password or corrupted backup file');
    }
  }

  /// Restore from a raw .db file
  Future<void> restoreRawBackup(File backupFile) async {
    final bytes = await backupFile.readAsBytes();
    final dbPath = await getDatabasesPath();
    final targetPath = join(dbPath, 'sorutrack_pro.db');
    
    await deleteDatabase(targetPath);
    await File(targetPath).writeAsBytes(bytes);
    
    _logger.i('Database restored successfully from raw backup');
  }

  encrypt.Key _deriveKey(String password) {
    // Basic key derivation: SHA-256 of password
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  Future<List<File>> getLocalBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(directory.path, 'backups'));
    if (!await backupDir.exists()) return [];
    
    return backupDir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db') || f.path.endsWith(backupExtension))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  }

  Future<void> deleteOldBackups(int keepN) async {
    final backups = await getLocalBackups();
    if (backups.length > keepN) {
      for (var i = keepN; i < backups.length; i++) {
        await backups[i].delete();
      }
    }
  }
}
