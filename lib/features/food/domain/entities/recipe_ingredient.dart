import 'package:equatable/equatable.dart';
import 'food_item.dart';

class RecipeIngredient extends Equatable {
  final String id;
  final FoodItem foodItem;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.id,
    required this.foodItem,
    required this.quantity,
    required this.unit,
  });

  double get calories => (foodItem.calories * quantity) / foodItem.servingSize;
  double get protein => (foodItem.protein * quantity) / foodItem.servingSize;
  double get carbs => (foodItem.carbs * quantity) / foodItem.servingSize;
  double get fat => (foodItem.fat * quantity) / foodItem.servingSize;
  double get fiber => (foodItem.fiber * quantity) / foodItem.servingSize;
  double get sodium => (foodItem.sodium * quantity) / foodItem.servingSize;
  double get sugar => (foodItem.sugar * quantity) / foodItem.servingSize;

  @override
  List<Object?> get props => [id, foodItem, quantity, unit];

  RecipeIngredient copyWith({
    String? id,
    FoodItem? foodItem,
    double? quantity,
    String? unit,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
