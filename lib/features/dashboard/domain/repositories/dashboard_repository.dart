import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData(String userId, DateTime date);
  Future<Either<Failure, List<WeeklyCalorieData>>> getWeeklyCalories(String userId);
  Future<Either<Failure, void>> logWater(String userId, DateTime date, int mlToAdd);
}
