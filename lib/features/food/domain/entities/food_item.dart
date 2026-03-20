import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String? brand;
  final String? category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sodium;
  final double sugar;
  final double potassium;
  final double vitaminA;
  final double vitaminC;
  final double calcium;
  final double iron;
  final double servingSize;
  final String servingUnit;
  final bool isCustom;
  final bool isFavorite;
  final int useCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodItem({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sodium = 0,
    this.sugar = 0,
    this.potassium = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.calcium = 0,
    this.iron = 0,
    required this.servingSize,
    required this.servingUnit,
    this.isCustom = false,
    this.isFavorite = false,
    this.useCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        category,
        calories,
        protein,
        carbs,
        fat,
        fiber,
        sodium,
        sugar,
        potassium,
        vitaminA,
        vitaminC,
        calcium,
        iron,
        servingSize,
        servingUnit,
        isCustom,
        isFavorite,
        useCount,
      ];

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sodium,
    double? sugar,
    double? potassium,
    double? vitaminA,
    double? vitaminC,
    double? calcium,
    double? iron,
    double? servingSize,
    String? servingUnit,
    bool? isCustom,
    bool? isFavorite,
    int? useCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      potassium: potassium ?? this.potassium,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
      useCount: useCount ?? this.useCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      brand: map['brand'],
      category: map['category'],
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0,
      potassium: (map['potassium'] as num?)?.toDouble() ?? 0,
      vitaminA: (map['vitamin_a'] as num?)?.toDouble() ?? 0,
      vitaminC: (map['vitamin_c'] as num?)?.toDouble() ?? 0,
      calcium: (map['calcium'] as num?)?.toDouble() ?? 0,
      iron: (map['iron'] as num?)?.toDouble() ?? 0,
      servingSize: (map['serving_size'] as num?)?.toDouble() ?? 100,
      servingUnit: map['serving_unit'] ?? 'g',
      isCustom: (map['is_custom'] as int?) == 1,
      isFavorite: (map['is_favorite'] as int?) == 1,
      useCount: (map['use_count'] as int?) ?? 0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'sugar': sugar,
      'potassium': potassium,
      'vitamin_a': vitaminA,
      'vitamin_c': vitaminC,
      'calcium': calcium,
      'iron': iron,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'is_custom': isCustom ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'use_count': useCount,
    };
  }
}
