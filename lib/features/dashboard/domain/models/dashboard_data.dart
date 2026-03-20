import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final DailyNutritionSummary nutritionSummary;
  final List<MealSummary> meals;
  final double waterIntakeMl;
  final double waterTargetMl;
  final int currentStreak;
  final String greeting;
  final List<WeeklyCalorieData> weeklyCalories;
  final String? dailyInsight;

  const DashboardData({
    required this.nutritionSummary,
    required this.meals,
    required this.waterIntakeMl,
    required this.waterTargetMl,
    required this.currentStreak,
    required this.greeting,
    required this.weeklyCalories,
    this.dailyInsight,
  });

  @override
  List<Object?> get props => [
        nutritionSummary,
        meals,
        waterIntakeMl,
        waterTargetMl,
        currentStreak,
        greeting,
        weeklyCalories,
        dailyInsight,
      ];

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      nutritionSummary: DailyNutritionSummary.fromJson(json['nutritionSummary'] ?? json['nutrition_summary']),
      meals: (json['meals'] as List?)?.map((e) => MealSummary.fromJson(e)).toList() ?? [],
      waterIntakeMl: (json['waterIntakeMl'] ?? json['water_intake_ml'] ?? 0.0).toDouble(),
      waterTargetMl: (json['waterTargetMl'] ?? json['water_target_ml'] ?? 0.0).toDouble(),
      currentStreak: json['currentStreak'] ?? json['current_streak'] ?? 0,
      greeting: json['greeting'] ?? '',
      weeklyCalories: (json['weeklyCalories'] ?? json['weekly_calories'] as List?)
              ?.map((e) => WeeklyCalorieData.fromJson(e))
              .toList() ??
          [],
      dailyInsight: json['dailyInsight'] ?? json['daily_insight'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nutrition_summary': nutritionSummary.toJson(),
        'meals': meals.map((e) => e.toJson()).toList(),
        'water_intake_ml': waterIntakeMl,
        'water_target_ml': waterTargetMl,
        'current_streak': currentStreak,
        'greeting': greeting,
        'weekly_calories': weeklyCalories.map((e) => e.toJson()).toList(),
        'daily_insight': dailyInsight,
      };
}

class DailyNutritionSummary extends Equatable {
  final double consumedCalories;
  final double targetCalories;
  final double burnedCalories;
  final double proteinG;
  final double proteinTargetG;
  final double carbsG;
  final double carbsTargetG;
  final double fatG;
  final double fatTargetG;
  final double fiberG;
  final double fiberTargetG;

  const DailyNutritionSummary({
    required this.consumedCalories,
    required this.targetCalories,
    required this.burnedCalories,
    required this.proteinG,
    required this.proteinTargetG,
    required this.carbsG,
    required this.carbsTargetG,
    required this.fatG,
    required this.fatTargetG,
    required this.fiberG,
    required this.fiberTargetG,
  });

  @override
  List<Object?> get props => [
        consumedCalories,
        targetCalories,
        burnedCalories,
        proteinG,
        proteinTargetG,
        carbsG,
        carbsTargetG,
        fatG,
        fatTargetG,
        fiberG,
        fiberTargetG,
      ];

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      consumedCalories: (json['consumedCalories'] ?? json['consumed_calories'] ?? 0.0).toDouble(),
      targetCalories: (json['targetCalories'] ?? json['target_calories'] ?? 0.0).toDouble(),
      burnedCalories: (json['burnedCalories'] ?? json['burned_calories'] ?? 0.0).toDouble(),
      proteinG: (json['proteinG'] ?? json['protein_g'] ?? 0.0).toDouble(),
      proteinTargetG: (json['proteinTargetG'] ?? json['protein_target_g'] ?? 0.0).toDouble(),
      carbsG: (json['carbsG'] ?? json['carbs_g'] ?? 0.0).toDouble(),
      carbsTargetG: (json['carbsTargetG'] ?? json['carbs_target_g'] ?? 0.0).toDouble(),
      fatG: (json['fatG'] ?? json['fat_g'] ?? 0.0).toDouble(),
      fatTargetG: (json['fatTargetG'] ?? json['fat_target_g'] ?? 0.0).toDouble(),
      fiberG: (json['fiberG'] ?? json['fiber_g'] ?? 0.0).toDouble(),
      fiberTargetG: (json['fiberTargetG'] ?? json['fiber_target_g'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'consumed_calories': consumedCalories,
        'target_calories': targetCalories,
        'burned_calories': burnedCalories,
        'protein_g': proteinG,
        'protein_target_g': proteinTargetG,
        'carbs_g': carbsG,
        'carbs_target_g': carbsTargetG,
        'fat_g': fatG,
        'fat_target_g': fatTargetG,
        'fiber_g': fiberG,
        'fiber_target_g': fiberTargetG,
      };

  double get netCalories => consumedCalories - burnedCalories;
  double get remainingCalories => targetCalories - netCalories;
}

class MealSummary extends Equatable {
  final String id;
  final String name;
  final DateTime time;
  final double totalCalories;
  final int itemCount;
  final List<String> itemPreviews;
  final bool isExpanded;

  const MealSummary({
    required this.id,
    required this.name,
    required this.time,
    required this.totalCalories,
    required this.itemCount,
    this.itemPreviews = const [],
    this.isExpanded = false,
  });

  @override
  List<Object?> get props => [id, name, time, totalCalories, itemCount, itemPreviews, isExpanded];

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      time: DateTime.parse(json['time'] ?? json['meal_time'] ?? DateTime.now().toIso8601String()),
      totalCalories: (json['totalCalories'] ?? json['total_calories'] ?? 0.0).toDouble(),
      itemCount: json['itemCount'] ?? json['item_count'] ?? 0,
      itemPreviews: (json['itemPreviews'] ?? json['item_previews'] as List?)?.cast<String>() ?? [],
      isExpanded: json['isExpanded'] ?? json['is_expanded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time': time.toIso8601String(),
        'total_calories': totalCalories,
        'item_count': itemCount,
        'item_previews': itemPreviews,
        'is_expanded': isExpanded,
      };
}

class WeeklyCalorieData extends Equatable {
  final DateTime date;
  final double calories;
  final double targetCalories;

  const WeeklyCalorieData({
    required this.date,
    required this.calories,
    required this.targetCalories,
  });

  @override
  List<Object?> get props => [date, calories, targetCalories];

  factory WeeklyCalorieData.fromJson(Map<String, dynamic> json) {
    return WeeklyCalorieData(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      calories: (json['calories'] ?? 0.0).toDouble(),
      targetCalories: (json['targetCalories'] ?? json['target_calories'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'calories': calories,
        'target_calories': targetCalories,
      };
}
