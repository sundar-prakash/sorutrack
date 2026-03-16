import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/core/database/database_helper.dart';

@lazySingleton
class ExportService {
  final DatabaseHelper _dbHelper;

  ExportService(this._dbHelper);

  /// Export all data as JSON
  Future<String> exportToJson(String userId) async {
    final db = await _dbHelper.database;
    
    // Fetch all relevant tables
    final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    final meals = await db.query('meals', where: 'user_id = ?', whereArgs: [userId]);
    final mealItems = await db.rawQuery('''
      SELECT mi.* FROM meal_items mi 
      JOIN meals m ON mi.meal_id = m.id 
      WHERE m.user_id = ?
    ''', [userId]);
    final dailyLogs = await db.query('daily_logs', where: 'user_id = ?', whereArgs: [userId]);
    final weightLogs = await db.query('weight_logs', where: 'user_id = ?', whereArgs: [userId]);
    final waterLogs = await db.query('water_logs', where: 'user_id = ?', whereArgs: [userId]);
    final foodItems = await db.query('food_items'); // Export all food items (custom ones)

    final data = {
      'version': '1.0.0',
      'export_date': DateTime.now().toIso8601String(),
      'users': users,
      'meals': meals,
      'meal_items': mealItems,
      'daily_logs': dailyLogs,
      'weight_logs': weightLogs,
      'water_logs': waterLogs,
      'food_items': foodItems,
    };

    final jsonString = jsonEncode(data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/sorutrack_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);
    
    return file.path;
  }

  /// Export meal logs as CSV
  Future<String> exportToCsv(String userId) async {
    final db = await _dbHelper.database;
    final meals = await db.rawQuery('''
      SELECT m.meal_time, m.name as meal_type, fi.name as food_name, 
             mi.quantity, mi.unit, mi.calories, mi.protein, mi.carbs, mi.fat
      FROM meal_items mi
      JOIN meals m ON mi.meal_id = m.id
      JOIN food_items fi ON mi.food_item_id = fi.id
      WHERE m.user_id = ? AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
      ORDER BY m.meal_time DESC
    ''', [userId]);

    List<List<dynamic>> rows = [];
    // Header
    rows.add([
      TextCellValue('Date'), 
      TextCellValue('Meal Type'), 
      TextCellValue('Food Name'), 
      TextCellValue('Quantity'), 
      TextCellValue('Unit'), 
      TextCellValue('Calories'), 
      TextCellValue('Protein'), 
      TextCellValue('Carbs'), 
      TextCellValue('Fat')
    ]);
    
    for (var meal in meals) {
      rows.add([
        TextCellValue(meal['meal_time'].toString()),
        TextCellValue(meal['meal_type'].toString()),
        TextCellValue(meal['food_name'].toString()),
        DoubleCellValue(double.tryParse(meal['quantity'].toString()) ?? 0.0),
        TextCellValue(meal['unit'].toString()),
        DoubleCellValue(double.tryParse(meal['calories'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(meal['protein'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(meal['carbs'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(meal['fat'].toString()) ?? 0.0),
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/meal_logs_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);
    
    return file.path;
  }

  /// Export to multi-sheet Excel
  Future<String> exportToExcel(String userId) async {
    final excel = Excel.createExcel();
    
    // Sheet 1: Daily Summary
    final dailySheet = excel['Daily Summary'];
    final db = await _dbHelper.database;
    final dailyLogs = await db.query('daily_logs', where: 'user_id = ?', whereArgs: [userId]);
    
    dailySheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Calories'),
      TextCellValue('Protein'),
      TextCellValue('Carbs'),
      TextCellValue('Fat'),
      TextCellValue('Water (ml)')
    ]);
    for (var log in dailyLogs) {
      dailySheet.appendRow([
        TextCellValue(log['date'].toString()),
        DoubleCellValue(double.tryParse(log['total_calories'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(log['total_protein'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(log['total_carbs'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(log['total_fat'].toString()) ?? 0.0),
        IntCellValue(int.tryParse(log['water_intake'].toString()) ?? 0),
      ]);
    }

    // Sheet 2: All Meals Detailed
    final mealSheet = excel['Meal Details'];
    final mealDetails = await db.rawQuery('''
       SELECT m.meal_time, m.name as meal_type, fi.name as food_name, 
             mi.quantity, mi.unit, mi.calories, mi.protein, mi.carbs, mi.fat
      FROM meal_items mi
      JOIN meals m ON mi.meal_id = m.id
      JOIN food_items fi ON mi.food_item_id = fi.id
      WHERE m.user_id = ? AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
    ''', [userId]);

    mealSheet.appendRow([
      TextCellValue('Time'),
      TextCellValue('Type'),
      TextCellValue('Food'),
      TextCellValue('Qty'),
      TextCellValue('Unit'),
      TextCellValue('Cal'),
      TextCellValue('P'),
      TextCellValue('C'),
      TextCellValue('F')
    ]);
    for (var m in mealDetails) {
       mealSheet.appendRow([
        TextCellValue(m['meal_time'].toString()),
        TextCellValue(m['meal_type'].toString()),
        TextCellValue(m['food_name'].toString()),
        DoubleCellValue(double.tryParse(m['quantity'].toString()) ?? 0.0),
        TextCellValue(m['unit'].toString()),
        DoubleCellValue(double.tryParse(m['calories'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(m['protein'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(m['carbs'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(m['fat'].toString()) ?? 0.0),
      ]);
    }

    // Sheet 3: Food Database
    final foodSheet = excel['Food Database'];
    final foods = await db.query('food_items');
    foodSheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Brand'),
      TextCellValue('Calories'),
      TextCellValue('Protein'),
      TextCellValue('Carbs'),
      TextCellValue('Fat'),
      TextCellValue('Serving')
    ]);
    for (var f in foods) {
      foodSheet.appendRow([
        TextCellValue(f['name'].toString()),
        TextCellValue(f['brand']?.toString() ?? ''),
        DoubleCellValue(double.tryParse(f['calories'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(f['protein'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(f['carbs'].toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(f['fat'].toString()) ?? 0.0),
        TextCellValue('${f['serving_size']} ${f['serving_unit']}'),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final fileBytes = excel.save();
    final filePath = '${directory.path}/sorutrack_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(filePath);
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }
    
    return filePath;
  }

  /// PDF Report Generation
  Future<String> generatePdfReport(String userId, {DateTime? start, DateTime? end}) async {
    final pdf = pw.Document();
    final db = await _dbHelper.database;
    
    final startDate = start ?? DateTime.now().subtract(const Duration(days: 30));
    final endDate = end ?? DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    final logs = await db.query(
      'daily_logs', 
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, dateFormat.format(startDate), dateFormat.format(endDate)],
      orderBy: 'date DESC'
    );

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('SoruTrack Pro - Nutrition Report')),
            pw.Paragraph(text: 'Period: ${dateFormat.format(startDate)} to ${dateFormat.format(endDate)}'),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                ['Date', 'Cal', 'Prot', 'Carb', 'Fat', 'Water'],
                ...logs.map((l) => [
                  l['date'],
                  l['total_calories'],
                  l['total_protein'],
                  l['total_carbs'],
                  l['total_fat'],
                  l['water_intake']
                ])
              ],
            ),
          ];
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/nutrition_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    
    return filePath;
  }

  Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)], text: 'Exported from SoruTrack Pro'));
  }
}
