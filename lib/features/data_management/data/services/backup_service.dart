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

@lazySingleton
class BackupService {
  final Logger _logger = Logger();
  static const String backupExtension = '.SoruTackbackup';

  /// Create a full backup of the SQLite database file
  Future<File> createFullBackup() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'sorutrack_pro.db');
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database file not found');
    }

    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(join(directory.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = join(backupDir.path, 'sorutrack_backup_$timestamp.db');
    return await sourceFile.copy(backupPath);
  }

  /// Create an encrypted backup file
  Future<File> createEncryptedBackup(String password) async {
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

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = join(directory.path, 'backups', 'sorutrack_secure_$timestamp$backupExtension');
    
    final file = File(backupPath);
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
