import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/meal_repository.dart';
import 'meal_log_event.dart';
import 'meal_log_state.dart';

@injectable
class MealLogBloc extends Bloc<MealLogEvent, MealLogState> {
  final MealRepository _repository;

  MealLogBloc(this._repository) : super(const MealLogState.initial()) {
    on<ParseMealEvent>(_onParseMeal);
    on<UpdateMealEvent>(_onUpdateMeal);
    on<SaveMealEvent>(_onSaveMeal);
    on<ResetEvent>(_onReset);
    on<FetchMealDetailsEvent>(_onFetchMealDetails);
  }

  Future<void> _onFetchMealDetails(FetchMealDetailsEvent event, Emitter<MealLogState> emit) async {
    emit(const MealLogState.analyzing()); // Reuse analyzing state as loading
    final result = await _repository.getMealsForDate(event.date);
    result.fold(
      (failure) => emit(MealLogState.error(failure.message)),
      (meals) {
        final meal = meals.firstWhere(
          (m) => m.mealId == event.mealId, 
          orElse: () => throw Exception('Meal not found'),
        );
        emit(MealLogState.reviewing(meal));
      },
    );
  }

  Future<void> _onParseMeal(ParseMealEvent event, Emitter<MealLogState> emit) async {
    emit(const MealLogState.analyzing());
    final result = await _repository.parseMeal(event.input, event.mealType);
    result.fold(
      (failure) => emit(MealLogState.error(failure.message)),
      (meal) => emit(MealLogState.reviewing(meal)),
    );
  }

  void _onUpdateMeal(UpdateMealEvent event, Emitter<MealLogState> emit) {
    emit(MealLogState.reviewing(event.meal));
  }

  Future<void> _onSaveMeal(SaveMealEvent event, Emitter<MealLogState> emit) async {
    emit(const MealLogState.saving());
    final result = await _repository.saveMeal(event.meal);
    result.fold(
      (failure) => emit(MealLogState.error(failure.message)),
      (_) => emit(const MealLogState.success()),
    );
  }

  void _onReset(ResetEvent event, Emitter<MealLogState> emit) {
    emit(const MealLogState.initial());
  }
}
