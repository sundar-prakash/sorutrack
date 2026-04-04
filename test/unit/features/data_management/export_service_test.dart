import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/data_management/data/services/export_service.dart';
import 'package:flutter/services.dart';

void main() {
  late DatabaseHelper dbHelper;
  late ExportService exportService;
  const userId = 'test_user';

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Mock path_provider
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
    final db = await dbHelper.openTestDatabase();
    
    // Setup dummy data
    await db.insert('users', {'id': userId, 'name': 'John Doe'});
    await db.insert('food_items', {
      'id': 'food_1',
      'name': 'Apple',
      'calories': 52.0,
      'protein': 0.3,
      'carbs': 14.0,
      'fat': 0.2,
    });
    await db.insert('meals', {
      'id': 'meal_1',
      'user_id': userId,
      'name': 'Breakfast',
      'meal_time': DateTime.now().toIso8601String(),
    });
    await db.insert('meal_items', {
      'id': 'mi_1',
      'meal_id': 'meal_1',
      'food_item_id': 'food_1',
      'quantity': 1.0,
      'unit': 'piece',
      'calories': 52.0,
      'protein': 0.3,
      'carbs': 14.0,
      'fat': 0.2,
    });
    await db.insert('daily_logs', {
      'id': 'log_1',
      'user_id': userId,
      'date': '2026-04-04',
      'total_calories': 1500.0,
      'water_intake': 2000,
    });

    exportService = ExportService(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
  });

  group('ExportService', () {
    test('exportToJson should create a valid JSON file', () async {
      // Act
      final filePath = await exportService.exportToJson(userId);

      // Assert
      final file = File(filePath);
      expect(await file.exists(), true);
      expect(filePath.endsWith('.json'), true);
      
      final content = await file.readAsString();
      expect(content.contains('John Doe'), true);
      expect(content.contains('Breakfast'), true);
      
      // Cleanup
      await file.delete();
    });

    test('exportToCsv should create a valid CSV file', () async {
      // Act
      final filePath = await exportService.exportToCsv(userId);

      // Assert
      final file = File(filePath);
      expect(await file.exists(), true);
      expect(filePath.endsWith('.csv'), true);
      
      final content = await file.readAsString();
      expect(content.contains('Meal Type,Food Name,Quantity'), true);
      expect(content.contains('Breakfast,Apple,1.0'), true);
      
      // Cleanup
      await file.delete();
    });

    test('exportToExcel should create an Excel file', () async {
      // Act
      final filePath = await exportService.exportToExcel(userId);

      // Assert
      final file = File(filePath);
      expect(await file.exists(), true);
      expect(filePath.endsWith('.xlsx'), true);
      
      // Cleanup
      await file.delete();
    });

    test('generatePdfReport should create a PDF file', () async {
      // Act
      final filePath = await exportService.generatePdfReport(userId);

      // Assert
      final file = File(filePath);
      expect(await file.exists(), true);
      expect(filePath.endsWith('.pdf'), true);
      
      // Cleanup
      await file.delete();
    });
  });
}
