part of 'recipe_builder_bloc.dart';

abstract class RecipeBuilderEvent extends Equatable {
  const RecipeBuilderEvent();

  @override
  List<Object?> get props => [];
}

class AddIngredient extends RecipeBuilderEvent {
  final FoodItem foodItem;
  final double quantity;
  final String unit;

  const AddIngredient({
    required this.foodItem,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [foodItem, quantity, unit];
}

class RemoveIngredient extends RecipeBuilderEvent {
  final String ingredientId;
  const RemoveIngredient(this.ingredientId);

  @override
  List<Object?> get props => [ingredientId];
}

class UpdateRecipeYield extends RecipeBuilderEvent {
  final double yieldAmount;
  final String yieldUnit;

  const UpdateRecipeYield({
    required this.yieldAmount,
    required this.yieldUnit,
  });

  @override
  List<Object?> get props => [yieldAmount, yieldUnit];
}

class SaveRecipe extends RecipeBuilderEvent {
  final String name;
  final String? category;

  const SaveRecipe({required this.name, this.category});

  @override
  List<Object?> get props => [name, category];
}
