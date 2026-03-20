import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';
import 'package:sorutrack_pro/features/food/domain/entities/recipe_ingredient.dart';
import 'package:sorutrack_pro/features/food/domain/repositories/food_repository.dart';

part 'recipe_builder_event.dart';
part 'recipe_builder_state.dart';

@injectable
class RecipeBuilderBloc extends Bloc<RecipeBuilderEvent, RecipeBuilderState> {
  final FoodRepository _foodRepository;
  final Uuid _uuid = const Uuid();

  RecipeBuilderBloc(this._foodRepository) : super(const RecipeBuilderState()) {
    on<AddIngredient>(_onAddIngredient);
    on<RemoveIngredient>(_onRemoveIngredient);
    on<UpdateRecipeYield>(_onUpdateRecipeYield);
    on<SaveRecipe>(_onSaveRecipe);
  }

  void _onAddIngredient(AddIngredient event, Emitter<RecipeBuilderState> emit) {
    final newIngredient = RecipeIngredient(
      id: _uuid.v4(),
      foodItem: event.foodItem,
      quantity: event.quantity,
      unit: event.unit,
    );
    final newList = List<RecipeIngredient>.from(state.ingredients)..add(newIngredient);
    emit(state.copyWith(ingredients: newList));
  }

  void _onRemoveIngredient(RemoveIngredient event, Emitter<RecipeBuilderState> emit) {
    final newList = state.ingredients.where((i) => i.id != event.ingredientId).toList();
    emit(state.copyWith(ingredients: newList));
  }

  void _onUpdateRecipeYield(UpdateRecipeYield event, Emitter<RecipeBuilderState> emit) {
    emit(state.copyWith(yieldAmount: event.yieldAmount, yieldUnit: event.yieldUnit));
  }

  Future<void> _onSaveRecipe(SaveRecipe event, Emitter<RecipeBuilderState> emit) async {
    if (state.ingredients.isEmpty) {
      emit(state.copyWith(error: 'Add at least one ingredient'));
      return;
    }

    emit(state.copyWith(isSaving: true, error: null));

    final recipeFood = FoodItem(
      id: _uuid.v4(),
      name: event.name,
      category: event.category ?? 'Home Recipe',
      calories: state.caloriesPerServing,
      protein: state.proteinPerServing,
      carbs: state.carbsPerServing,
      fat: state.fatPerServing,
      servingSize: 1, // 1 serving
      servingUnit: state.yieldUnit,
      isCustom: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _foodRepository.saveCustomFood(recipeFood);
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, success: true)),
    );
  }
}
