import 'package:equatable/equatable.dart';

class DailyNutrition extends Equatable {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailyNutrition({
    this.totalCalories = 0.0,
    this.totalProtein = 0.0,
    this.totalCarbs = 0.0,
    this.totalFat = 0.0,
  });

  @override
  List<Object?> get props => [totalCalories, totalProtein, totalCarbs, totalFat];

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      totalCalories: (json['calories'] as num? ?? 0.0).toDouble(),
      totalProtein: (json['protein'] as num? ?? 0.0).toDouble(),
      totalCarbs: (json['carbs'] as num? ?? 0.0).toDouble(),
      totalFat: (json['fat'] as num? ?? 0.0).toDouble(),
    );
  }
}
