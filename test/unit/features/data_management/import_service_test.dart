import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';
import 'package:sorutrack_pro/features/data_management/data/services/import_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late DatabaseHelper dbHelper;
  late ImportService importService;
  late String tempDirPath;
  const userId = 'test_user';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirPath = Directory.systemTemp.createTempSync('sorutrack_import_test_').path;
    dbHelper = DatabaseHelper();
    final db = await dbHelper.openTestDatabase();
    
    // Insert test user to satisfy foreign key constraints
    await db.insert('users', {'id': userId, 'name': 'Test User'});
    
    importService = ImportService(dbHelper);
  });

  tearDown(() async {
    final db = await dbHelper.database;
    await db.close();
    dbHelper.reset();
    await Directory(tempDirPath).delete(recursive: true);
  });

  group('ImportService', () {
    test('parseHealthifyMe should correctly map CSV rows', () async {
      // Arrange
      final file = File(p.join(tempDirPath, 'hm_export.csv'));
      await file.writeAsString(
        'Date,Meal,Food,Quantity,Calories,P,C,F\r\n'
        '2026-04-01,Breakfast,Banana,1.0,105.0,1.3,27.0,0.3\r\n'
        '2026-04-01,Lunch,Chicken,200.0,330.0,62.0,0.0,7.0'
      );

      // Act
      final results = await importService.parseHealthifyMe(file);

      // Assert
      expect(results.length, 2);
      expect(results[0]['food_name'], 'Banana');
      expect(results[0]['calories'], 105.0);
      expect(results[1]['food_name'], 'Chicken');
      expect(results[1]['protein'], 62.0);
    });

    test('parseGenericCsv should correctly map columns using mapping', () async {
      // Arrange
      final file = File(p.join(tempDirPath, 'generic.csv'));
      await file.writeAsString(
        'ts,type,label,qty,unit,kcal\r\n'
        '2026-04-02,Snack,Nuts,30.0,g,180.0'
      );
      final mapping = {
        'date': 'ts',
        'meal_type': 'type',
        'food_name': 'label',
        'calories': 'kcal'
      };

      // Act
      final results = await importService.parseGenericCsv(file, mapping);

      // Assert
      expect(results.length, 1);
      expect(results[0]['food_name'], 'Nuts');
      expect(results[0]['calories'], 180.0);
    });

    test('importData should insert records into database', () async {
      // Arrange
      final data = [
        {
          'date': '2026-04-03T08:00:00Z',
          'meal_type': 'Breakfast',
          'food_name': 'Oatmeal',
          'quantity': 1.0,
          'calories': 150.0,
          'protein': 5.0,
          'carbs': 27.0,
          'fat': 3.0,
        }
      ];

      // Act
      final result = await importService.importData(userId, data);

      // Assert
      expect(result.imported, 1);
      expect(result.errors, 0);

      final db = await dbHelper.database;
      final foodItems = await db.query('food_items', where: 'name = ?', whereArgs: ['Oatmeal']);
      expect(foodItems.length, 1);
      expect(foodItems[0]['calories'], 150.0);

      final meals = await db.query('meals', where: 'user_id = ?', whereArgs: [userId]);
      expect(meals.length, 1);
      expect(meals[0]['name'], 'Breakfast');

      final mealItems = await db.query('meal_items', where: 'meal_id = ?', whereArgs: [meals[0]['id']]);
      expect(mealItems.length, 1);
      expect(mealItems[0]['calories'], 150.0);
    });
  });
}
