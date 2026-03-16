import 'dart:io';
import 'package:csv/csv.dart' as csv;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sorutrack_pro/features/reports/domain/models/report_models.dart';

class ExportService {
  static final DateFormat _df = DateFormat('yyyy-MM-dd HH:mm');

  static Future<void> exportToCsv(List<FoodLogEntry> entries) async {
    List<List<dynamic>> rows = [
      ['Date', 'Meal Type', 'Food Name', 'Calories', 'Protein (g)', 'Carbs (g)', 'Fat (g)']
    ];

    for (var entry in entries) {
      rows.add([
        _df.format(entry.dateTime),
        entry.mealType,
        entry.foodName,
        entry.calories,
        entry.protein,
        entry.carbs,
        entry.fat,
      ]);
    }

    String csvData = const csv.ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/food_diary_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'My Food Diary Export'));
  }

  static Future<void> exportToExcel(List<FoodLogEntry> entries) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Food Diary'];

    sheetObject.appendRow([
      TextCellValue('Date'),
      TextCellValue('Meal Type'),
      TextCellValue('Food Name'),
      TextCellValue('Calories'),
      TextCellValue('Protein'),
      TextCellValue('Carbs'),
      TextCellValue('Fat')
    ]);

    for (var entry in entries) {
      sheetObject.appendRow([
        TextCellValue(_df.format(entry.dateTime)),
        TextCellValue(entry.mealType),
        TextCellValue(entry.foodName),
        DoubleCellValue(entry.calories),
        DoubleCellValue(entry.protein),
        DoubleCellValue(entry.carbs),
        DoubleCellValue(entry.fat),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final fileName = '${directory.path}/food_diary_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    
    if (fileBytes != null) {
      await File(fileName).writeAsBytes(fileBytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(fileName)], text: 'My Food Diary Excel Export'));
    }
  }

  static Future<void> exportToPdf({
    required List<ReportTrendData> calorieTrend,
    required List<MacroDistribution> macroTrend,
    required List<TopFood> topFoods,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text('SoruTrack Pro - Nutrition Report')),
          pw.SizedBox(height: 20),
          pw.Text('Report Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Calorie Trend')),
          pw.TableHelper.fromTextArray(
            data: [
              ['Date', 'Calories'],
              ...calorieTrend.map((e) => [e.date, e.value.toStringAsFixed(0)]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Macro Avg')),
          pw.TableHelper.fromTextArray(
            data: [
              ['Date', 'Protein', 'Carbs', 'Fat'],
              ...macroTrend.map((e) => [
                e.date, 
                e.protein.toStringAsFixed(1), 
                e.carbs.toStringAsFixed(1), 
                e.fat.toStringAsFixed(1)
              ]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Top 10 Foods')),
          pw.TableHelper.fromTextArray(
            data: [
              ['Food', 'Frequency', 'Total Calories'],
              ...topFoods.map((e) => [e.name, e.frequency.toString(), e.totalCalories.toStringAsFixed(0)]),
            ],
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/nutrition_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'My Nutrition Report PDF'));
  }
}
