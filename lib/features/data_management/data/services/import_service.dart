import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';

@lazySingleton
class ImportService {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ImportService(this._dbHelper);

  /// Parse HealthifyMe CSV
  Future<List<Map<String, dynamic>>> parseHealthifyMe(File file) async {
    final input = await file.readAsString();
    List<List<dynamic>> rows = const csv.CsvToListConverter().convert(input);
    
    if (rows.isEmpty) return [];

    // HealthifyMe format usually: Date, Meal, Food, Quantity, Calories, P, C, F
    // Note: This is an example mapping, realistic mapping depends on actual export format
    List<Map<String, dynamic>> results = [];
    
    // Skip header
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;

      results.add({
        'date': row[0].toString(),
        'meal_type': row[1].toString(),
        'food_name': row[2].toString(),
        'quantity': double.tryParse(row[3].toString()) ?? 1.0,
        'calories': double.tryParse(row[4].toString()) ?? 0.0,
        'protein': double.tryParse(row[5].toString()) ?? 0.0,
        'carbs': double.tryParse(row[6].toString()) ?? 0.0,
        'fat': double.tryParse(row[7].toString()) ?? 0.0,
      });
    }
    return results;
  }

  /// Parse MyFitnessPal CSV
  Future<List<Map<String, dynamic>>> parseMyFitnessPal(File file) async {
    final input = await file.readAsString();
    List<List<dynamic>> rows = const csv.CsvToListConverter().convert(input);
    
    if (rows.isEmpty) return [];

    List<Map<String, dynamic>> results = [];
    // MFP format: Date, Meal, Type, Calories, Fat, ...
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 4) continue;

      results.add({
        'date': row[0].toString(),
        'meal_type': row[1].toString(),
        'food_name': row[2].toString(),
        'calories': double.tryParse(row[3].toString()) ?? 0.0,
        // ... more mapping
      });
    }
    return results;
  }

  /// Generic CSV Parser with Column Mapping
  Future<List<Map<String, dynamic>>> parseGenericCsv(File file, Map<String, String> mapping) async {
    final input = await file.readAsString();
    List<List<dynamic>> rows = const csv.CsvToListConverter().convert(input);
    
    if (rows.isEmpty) return [];
    
    final header = rows[0].map((e) => e.toString()).toList();
    List<Map<String, dynamic>> results = [];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      Map<String, dynamic> item = {};
      
      mapping.forEach((appField, csvColumn) {
        int index = header.indexOf(csvColumn);
        if (index != -1 && index < row.length) {
          item[appField] = row[index];
        }
      });
      
      results.add(item);
    }
    return results;
  }

  /// Perform the actual import into the database
  Future<ImportResult> importData(String userId, List<Map<String, dynamic>> data, {bool overwrite = false}) async {
    final db = await _dbHelper.database;
    int imported = 0;
    int errors = 0;
    List<String> errorDetails = [];

    await db.transaction((txn) async {
      for (var item in data) {
        try {
          // 1. Ensure food_item exists or create it
          String foodId = _uuid.v4();
          await txn.insert('food_items', {
            'id': foodId,
            'name': item['food_name'] ?? 'Unknown',
            'calories': item['calories'] ?? 0.0,
            'protein': item['protein'] ?? 0.0,
            'carbs': item['carbs'] ?? 0.0,
            'fat': item['fat'] ?? 0.0,
            'is_custom': 1,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          // 2. Create meal
          String mealId = _uuid.v4();
          await txn.insert('meals', {
            'id': mealId,
            'user_id': userId,
            'name': item['meal_type'] ?? 'Lunch',
            'meal_time': item['date'] ?? DateTime.now().toIso8601String(),
          });

          // 3. Create meal item
          await txn.insert('meal_items', {
            'id': _uuid.v4(),
            'meal_id': mealId,
            'food_item_id': foodId,
            'quantity': item['quantity'] ?? 1.0,
            'unit': item['unit'] ?? 'serving',
            'calories': item['calories'] ?? 0.0,
            'protein': item['protein'] ?? 0.0,
            'carbs': item['carbs'] ?? 0.0,
            'fat': item['fat'] ?? 0.0,
          });

          imported++;
        } catch (e) {
          errors++;
          errorDetails.add('Error importing ${item['food_name']}: $e');
        }
      }
    });

    return ImportResult(imported: imported, errors: errors, errorDetails: errorDetails);
  }
}

class ImportResult {
  final int imported;
  final int errors;
  final List<String> errorDetails;

  ImportResult({required this.imported, required this.errors, required this.errorDetails});
}
