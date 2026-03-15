import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/models/report_models.dart';
import '../repositories/reports_repository.dart';

@LazySingleton(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  final DatabaseHelper _dbHelper;
  final DateFormat _df = DateFormat('yyyy-MM-dd');

  ReportsRepositoryImpl(this._dbHelper);

  @override
  Future<List<ReportTrendData>> getCalorieTrend(String userId, DateTime startDate, DateTime endDate) async {
    final result = await _dbHelper.getCalorieTrend(
      userId, 
      _df.format(startDate), 
      _df.format(endDate),
    );
    return result.map((json) => ReportTrendData.fromJson(json)).toList();
  }

  @override
  Future<List<MacroDistribution>> getMacroTrend(String userId, DateTime startDate, DateTime endDate) async {
    final result = await _dbHelper.getMacroTrend(
      userId, 
      _df.format(startDate), 
      _df.format(endDate),
    );
    return result.map((json) => MacroDistribution.fromJson(json)).toList();
  }

  @override
  Future<List<TopFood>> getTopFoods(String userId, {int limit = 10, DateTime? startDate, DateTime? endDate}) async {
    final result = await _dbHelper.getTopFoods(
      userId, 
      limit, 
      startDate != null ? _df.format(startDate) : _df.format(DateTime.now().subtract(const Duration(days: 30))), 
      endDate != null ? _df.format(endDate) : _df.format(DateTime.now()),
    );
    return result.map((json) => TopFood.fromJson(json)).toList();
  }

  @override
  Future<List<MealTimingData>> getMealTimingData(String userId) async {
    final result = await _dbHelper.getMealTimingData(userId);
    return result.map((json) => MealTimingData.fromJson(json)).toList();
  }

  @override
  Future<List<ReportTrendData>> getWeightTrend(String userId, DateTime startDate, DateTime endDate) async {
    final result = await _dbHelper.getWeightTrend(
      userId, 
      _df.format(startDate), 
      _df.format(endDate),
    );
    return result.map((json) => ReportTrendData.fromJson({
      'date': json['date'],
      'value': json['weight'],
    })).toList();
  }

  @override
  Future<List<GoalAdherenceData>> getGoalAdherence(String userId, DateTime startDate, DateTime endDate) async {
    final result = await _dbHelper.getGoalAdherence(
      userId, 
      _df.format(startDate), 
      _df.format(endDate),
    );
    return result.map((json) => GoalAdherenceData.fromJson(json)).toList();
  }

  @override
  Future<MicronutrientData> getMicronutrientAverages(String userId, DateTime startDate, DateTime endDate) async {
    final result = await _dbHelper.getMicronutrientAverages(
      userId, 
      _df.format(startDate), 
      _df.format(endDate),
    );
    return MicronutrientData.fromJson(result);
  }

  @override
  Future<List<FoodLogEntry>> searchFoodEntries(
    String userId, 
    {String query = '', 
    DateTime? startDate, 
    DateTime? endDate, 
    List<String>? mealTypes, 
    double? minCalories, 
    double? maxCalories}
  ) async {
    final result = await _dbHelper.searchFoodInLog(
      userId, 
      query,
      startDate: startDate != null ? _df.format(startDate) : null,
      endDate: endDate != null ? _df.format(endDate) : null,
      mealTypes: mealTypes,
      minCalories: minCalories,
      maxCalories: maxCalories,
    );
    return result.map((json) => FoodLogEntry.fromJson(json)).toList();
  }
}
