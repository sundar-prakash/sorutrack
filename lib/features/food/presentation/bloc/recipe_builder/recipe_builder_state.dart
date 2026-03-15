part of 'recipe_builder_bloc.dart';

class RecipeBuilderState extends Equatable {
  final List<RecipeIngredient> ingredients;
  final double yieldAmount;
  final String yieldUnit;
  final bool isSaving;
  final String? error;
  final bool success;

  const RecipeBuilderState({
    this.ingredients = const [],
    this.yieldAmount = 1,
    this.yieldUnit = 'serving',
    this.isSaving = false,
    this.error,
    this.success = false,
  });

  double get totalCalories => ingredients.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => ingredients.fold(0, (sum, item) => sum + item.protein);
  double get totalCarbs => ingredients.fold(0, (sum, item) => sum + item.carbs);
  double get totalFat => ingredients.fold(0, (sum, item) => sum + item.fat);

  double get caloriesPerServing => yieldAmount > 0 ? totalCalories / yieldAmount : 0;
  double get proteinPerServing => yieldAmount > 0 ? totalProtein / yieldAmount : 0;
  double get carbsPerServing => yieldAmount > 0 ? totalCarbs / yieldAmount : 0;
  double get fatPerServing => yieldAmount > 0 ? totalFat / yieldAmount : 0;

  @override
  List<Object?> get props => [ingredients, yieldAmount, yieldUnit, isSaving, error, success];

  RecipeBuilderState copyWith({
    List<RecipeIngredient>? ingredients,
    double? yieldAmount,
    String? yieldUnit,
    bool? isSaving,
    String? error,
    bool? success,
  }) {
    return RecipeBuilderState(
      ingredients: ingredients ?? this.ingredients,
      yieldAmount: yieldAmount ?? this.yieldAmount,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      success: success ?? this.success,
    );
  }
}
