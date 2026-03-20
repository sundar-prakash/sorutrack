import 'package:equatable/equatable.dart';

class ReportTrendData extends Equatable {
  final String date;
  final double value;

  const ReportTrendData({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];

  factory ReportTrendData.fromJson(Map<String, dynamic> json) {
    return ReportTrendData(
      date: (json['date'] ?? '').toString(),
      value: (json['calories'] ?? json['weight'] ?? json['value'] ?? 0.0 as num).toDouble(),
    );
  }
}

class MacroDistribution extends Equatable {
  final String date;
  final double protein;
  final double carbs;
  final double fat;

  const MacroDistribution({
    required this.date,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [date, protein, carbs, fat];

  factory MacroDistribution.fromJson(Map<String, dynamic> json) {
    return MacroDistribution(
      date: (json['date'] ?? '').toString(),
      protein: (json['protein'] ?? 0.0 as num).toDouble(),
      carbs: (json['carbs'] ?? 0.0 as num).toDouble(),
      fat: (json['fat'] ?? 0.0 as num).toDouble(),
    );
  }
}

class TopFood extends Equatable {
  final String name;
  final int frequency;
  final double totalCalories;

  const TopFood({
    required this.name,
    required this.frequency,
    required this.totalCalories,
  });

  @override
  List<Object?> get props => [name, frequency, totalCalories];

  factory TopFood.fromJson(Map<String, dynamic> json) {
    return TopFood(
      name: (json['name'] ?? 'Unknown').toString(),
      frequency: (json['frequency'] ?? 0 as num).toInt(),
      totalCalories: (json['total_calories'] ?? 0.0 as num).toDouble(),
    );
  }
}

class MealTimingData extends Equatable {
  final int hour;
  final int count;

  const MealTimingData({required this.hour, required this.count});

  @override
  List<Object?> get props => [hour, count];

  factory MealTimingData.fromJson(Map<String, dynamic> json) {
    return MealTimingData(
      hour: int.tryParse((json['hour'] ?? '0').toString()) ?? 0,
      count: (json['count'] ?? 0 as num).toInt(),
    );
  }
}

class GoalAdherenceData extends Equatable {
  final String date;
  final double actual;
  final double target;
  final bool isOnTrack;

  const GoalAdherenceData({
    required this.date,
    required this.actual,
    required this.target,
    required this.isOnTrack,
  });

  @override
  List<Object?> get props => [date, actual, target, isOnTrack];

  factory GoalAdherenceData.fromJson(Map<String, dynamic> json) {
    return GoalAdherenceData(
      date: (json['date'] ?? '').toString(),
      actual: (json['total_calories'] ?? 0.0 as num).toDouble(),
      target: (json['goal_calories'] ?? 0.0 as num).toDouble(),
      isOnTrack: (json['is_on_track'] ?? 0 as num) == 1,
    );
  }
}

class MicronutrientData extends Equatable {
  final double fiber;
  final double sodium;
  final double sugar;
  final double potassium;

  const MicronutrientData({
    required this.fiber,
    required this.sodium,
    required this.sugar,
    required this.potassium,
  });

  @override
  List<Object?> get props => [fiber, sodium, sugar, potassium];

  factory MicronutrientData.fromJson(Map<String, dynamic> json) {
    return MicronutrientData(
      fiber: (json['avg_fiber'] as num? ?? 0.0).toDouble(),
      sodium: (json['avg_sodium'] as num? ?? 0.0).toDouble(),
      sugar: (json['avg_sugar'] as num? ?? 0.0).toDouble(),
      potassium: (json['avg_potassium'] as num? ?? 0.0).toDouble(),
    );
  }
}

class FoodLogEntry extends Equatable {
  final DateTime dateTime;
  final String mealType;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodLogEntry({
    required this.dateTime,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  List<Object?> get props => [dateTime, mealType, foodName, calories, protein, carbs, fat];

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) {
    String timeStr = (json['meal_time'] ?? '').toString();
    return FoodLogEntry(
      dateTime: timeStr.isNotEmpty ? DateTime.parse(timeStr) : DateTime.now(),
      mealType: (json['meal_type'] ?? 'Unknown').toString(),
      foodName: (json['food_name'] ?? 'Unknown').toString(),
      calories: (json['calories'] ?? 0.0 as num).toDouble(),
      protein: (json['protein'] ?? 0.0 as num).toDouble(),
      carbs: (json['carbs'] ?? 0.0 as num).toDouble(),
      fat: (json['fat'] ?? 0.0 as num).toDouble(),
    );
  }
}
