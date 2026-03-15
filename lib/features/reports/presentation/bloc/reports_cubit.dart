import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/report_models.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/services/gemini_reports_service.dart';
import 'report_filter_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ReportTrendData> calorieTrend;
  final List<MacroDistribution> macroTrend;
  final List<TopFood> topFoods;
  final List<MealTimingData> mealTiming;
  final List<ReportTrendData> weightTrend;
  final List<GoalAdherenceData> goalAdherence;
  final MicronutrientData micronutrients;
  final List<FoodLogEntry> foodDiary;
  final String? insights;

  const ReportsLoaded({
    required this.calorieTrend,
    required this.macroTrend,
    required this.topFoods,
    required this.mealTiming,
    required this.weightTrend,
    required this.goalAdherence,
    required this.micronutrients,
    required this.foodDiary,
    this.insights,
  });

  ReportsLoaded copyWith({String? insights}) {
    return ReportsLoaded(
      calorieTrend: calorieTrend,
      macroTrend: macroTrend,
      topFoods: topFoods,
      mealTiming: mealTiming,
      weightTrend: weightTrend,
      goalAdherence: goalAdherence,
      micronutrients: micronutrients,
      foodDiary: foodDiary,
      insights: insights ?? this.insights,
    );
  }

  @override
  List<Object?> get props => [
    calorieTrend, 
    macroTrend, 
    topFoods, 
    mealTiming, 
    weightTrend, 
    goalAdherence, 
    micronutrients, 
    foodDiary,
    insights
  ];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

@injectable
class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;
  final GeminiReportsService _geminiService;

  ReportsCubit(this._repository, this._geminiService) : super(ReportsInitial());

  Future<void> loadReports(ReportFilterState filter, String userId) async {
    emit(ReportsLoading());
    try {
      final calorieTrend = await _repository.getCalorieTrend(userId, filter.startDate, filter.endDate);
      final macroTrend = await _repository.getMacroTrend(userId, filter.startDate, filter.endDate);
      final topFoods = await _repository.getTopFoods(userId, startDate: filter.startDate, endDate: filter.endDate);
      final mealTiming = await _repository.getMealTimingData(userId);
      final weightTrend = await _repository.getWeightTrend(userId, filter.startDate, filter.endDate);
      final goalAdherence = await _repository.getGoalAdherence(userId, filter.startDate, filter.endDate);
      final micronutrients = await _repository.getMicronutrientAverages(userId, filter.startDate, filter.endDate);
      final foodDiary = await _repository.searchFoodEntries(
        userId,
        query: filter.query,
        startDate: filter.startDate,
        endDate: filter.endDate,
        mealTypes: filter.mealTypes,
        minCalories: filter.minCalories,
        maxCalories: filter.maxCalories,
      );

      emit(ReportsLoaded(
        calorieTrend: calorieTrend,
        macroTrend: macroTrend,
        topFoods: topFoods,
        mealTiming: mealTiming,
        weightTrend: weightTrend,
        goalAdherence: goalAdherence,
        micronutrients: micronutrients,
        foodDiary: foodDiary,
      ));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> loadInsights() async {
    final currentState = state;
    if (currentState is! ReportsLoaded) return;

    try {
      final insights = await _geminiService.generateWeeklyInsights(
        calories: currentState.calorieTrend,
        macros: currentState.macroTrend,
        topFoods: currentState.topFoods,
        micros: currentState.micronutrients,
      );
      emit(currentState.copyWith(insights: insights));
    } catch (e) {
      // Don't emit error state, just don't update insights
    }
  }
}
