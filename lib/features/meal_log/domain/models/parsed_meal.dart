import 'package:equatable/equatable.dart';

class ParsedMeal extends Equatable {
  final String mealName;
  final String mealTime;
  final String mealType;
  final double confidenceScore;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final double totalFiberG;
  final List<ParsedMealItem> items;
  final List<String> warnings;
  final List<String> alternativesSuggested;

  const ParsedMeal({
    required this.mealName,
    required this.mealTime,
    required this.mealType,
    required this.confidenceScore,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    this.totalFiberG = 0.0,
    required this.items,
    this.warnings = const [],
    this.alternativesSuggested = const [],
  });

  @override
  List<Object?> get props => [
        mealName,
        mealTime,
        mealType,
        confidenceScore,
        totalCalories,
        totalProteinG,
        totalCarbsG,
        totalFatG,
        totalFiberG,
        items,
        warnings,
        alternativesSuggested,
      ];

  factory ParsedMeal.fromJson(Map<String, dynamic> json) {
    return ParsedMeal(
      mealName: json['mealName'] ?? json['meal_name'] ?? '',
      mealTime: json['mealTime'] ?? json['meal_time'] ?? '',
      mealType: json['mealType'] ?? json['meal_type'] ?? '',
      confidenceScore: (json['confidenceScore'] ?? json['confidence_score'] ?? 0.0).toDouble(),
      totalCalories: (json['totalCalories'] ?? json['total_calories'] ?? 0.0).toDouble(),
      totalProteinG: (json['totalProteinG'] ?? json['total_protein_g'] ?? 0.0).toDouble(),
      totalCarbsG: (json['totalCarbsG'] ?? json['total_carbs_g'] ?? 0.0).toDouble(),
      totalFatG: (json['totalFatG'] ?? json['total_fat_g'] ?? 0.0).toDouble(),
      totalFiberG: (json['totalFiberG'] ?? json['total_fiber_g'] ?? 0.0).toDouble(),
      items: (json['items'] as List?)?.map((e) => ParsedMealItem.fromJson(e)).toList() ?? [],
      warnings: (json['warnings'] as List?)?.cast<String>() ?? [],
      alternativesSuggested: (json['alternativesSuggested'] ?? json['alternatives_suggested'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'meal_name': mealName,
        'meal_time': mealTime,
        'meal_type': mealType,
        'confidence_score': confidenceScore,
        'total_calories': totalCalories,
        'total_protein_g': totalProteinG,
        'total_carbs_g': totalCarbsG,
        'total_fat_g': totalFatG,
        'total_fiber_g': totalFiberG,
        'items': items.map((e) => e.toJson()).toList(),
        'warnings': warnings,
        'alternatives_suggested': alternativesSuggested,
      };
}

class ParsedMealItem extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final double weightG;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sodiumMg;
  final double sugarG;
  final int? glycemicIndex;
  final String servingDescription;
  final String? notes;

  const ParsedMealItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.weightG,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0.0,
    this.sodiumMg = 0.0,
    this.sugarG = 0.0,
    this.glycemicIndex,
    required this.servingDescription,
    this.notes,
  });

  @override
  List<Object?> get props => [
        name,
        quantity,
        unit,
        weightG,
        calories,
        proteinG,
        carbsG,
        fatG,
        fiberG,
        sodiumMg,
        sugarG,
        glycemicIndex,
        servingDescription,
        notes,
      ];

  factory ParsedMealItem.fromJson(Map<String, dynamic> json) {
    return ParsedMealItem(
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      unit: json['unit'] ?? '',
      weightG: (json['weightG'] ?? json['weight_g'] ?? 0.0).toDouble(),
      calories: (json['calories'] ?? 0.0).toDouble(),
      proteinG: (json['proteinG'] ?? json['protein_g'] ?? 0.0).toDouble(),
      carbsG: (json['carbsG'] ?? json['carbs_g'] ?? 0.0).toDouble(),
      fatG: (json['fatG'] ?? json['fat_g'] ?? 0.0).toDouble(),
      fiberG: (json['fiberG'] ?? json['fiber_g'] ?? 0.0).toDouble(),
      sodiumMg: (json['sodiumMg'] ?? json['sodium_mg'] ?? 0.0).toDouble(),
      sugarG: (json['sugarG'] ?? json['sugar_g'] ?? 0.0).toDouble(),
      glycemicIndex: json['glycemicIndex'] ?? json['glycemic_index'],
      servingDescription: json['servingDescription'] ?? json['serving_description'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'weight_g': weightG,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'sodium_mg': sodiumMg,
        'sugar_g': sugarG,
        'glycemic_index': glycemicIndex,
        'serving_description': servingDescription,
        'notes': notes,
      };
}
