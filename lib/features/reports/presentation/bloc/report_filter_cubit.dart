import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum DateRangeType { today, thisWeek, thisMonth, last30Days, custom }

class ReportFilterState extends Equatable {
  final DateRangeType rangeType;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> mealTypes;
  final double? minCalories;
  final double? maxCalories;
  final String query;

  const ReportFilterState({
    required this.rangeType,
    required this.startDate,
    required this.endDate,
    this.mealTypes = const [],
    this.minCalories,
    this.maxCalories,
    this.query = '',
  });

  factory ReportFilterState.initial() {
    final now = DateTime.now();
    return ReportFilterState(
      rangeType: DateRangeType.today,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: now,
    );
  }

  ReportFilterState copyWith({
    DateRangeType? rangeType,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? mealTypes,
    double? minCalories,
    double? maxCalories,
    String? query,
  }) {
    return ReportFilterState(
      rangeType: rangeType ?? this.rangeType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mealTypes: mealTypes ?? this.mealTypes,
      minCalories: minCalories ?? this.minCalories,
      maxCalories: maxCalories ?? this.maxCalories,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [rangeType, startDate, endDate, mealTypes, minCalories, maxCalories, query];
}

class ReportFilterCubit extends Cubit<ReportFilterState> {
  ReportFilterCubit() : super(ReportFilterState.initial());

  void setRange(DateRangeType type, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (type) {
      case DateRangeType.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeType.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case DateRangeType.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case DateRangeType.last30Days:
        start = now.subtract(const Duration(days: 30));
        break;
      case DateRangeType.custom:
        start = customStart ?? state.startDate;
        end = customEnd ?? state.endDate;
        break;
    }

    emit(state.copyWith(
      rangeType: type,
      startDate: start,
      endDate: end,
    ));
  }

  void updateFilters({
    List<String>? mealTypes,
    double? minCalories,
    double? maxCalories,
    String? query,
  }) {
    emit(state.copyWith(
      mealTypes: mealTypes,
      minCalories: minCalories,
      maxCalories: maxCalories,
      query: query,
    ));
  }

  void resetFilters() {
    emit(ReportFilterState.initial());
  }
}
