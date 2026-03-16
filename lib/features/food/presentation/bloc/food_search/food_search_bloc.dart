import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';
import 'package:sorutrack_pro/features/food/domain/repositories/food_repository.dart';

part 'food_search_event.dart';
part 'food_search_state.dart';

@injectable
class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> {
  final FoodRepository _foodRepository;

  FoodSearchBloc(this._foodRepository) : super(FoodSearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged, transformer: _debounce(const Duration(milliseconds: 300)));
    on<FilterChanged>(_onFilterChanged);
    on<SortChanged>(_onSortChanged);
    on<LoadRecentFoods>(_onLoadRecentFoods);
    on<LoadFrequentFoods>(_onLoadFrequentFoods);
    on<LoadMoreResults>(_onLoadMoreResults);
  }

  EventTransformer<T> _debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onSearchQueryChanged(SearchQueryChanged event, Emitter<FoodSearchState> emit) async {
    if (event.query.isEmpty) {
      add(LoadRecentFoods());
      return;
    }

    emit(FoodSearchLoading());
    final result = await _foodRepository.searchFoods(event.query, limit: 20, offset: 0);
    result.fold(
      (failure) => emit(FoodSearchError(failure.message)),
      (foods) => emit(FoodSearchLoaded(
        results: foods,
        query: event.query,
        offset: foods.length,
        hasReachedMax: foods.length < 20,
      )),
    );
  }

  Future<void> _onLoadMoreResults(LoadMoreResults event, Emitter<FoodSearchState> emit) async {
    final currentState = state;
    if (currentState is FoodSearchLoaded && !currentState.hasReachedMax) {
      final result = await _foodRepository.searchFoods(
        currentState.query,
        limit: 20,
        offset: currentState.offset,
      );

      result.fold(
        (failure) => emit(FoodSearchError(failure.message)),
        (foods) => emit(currentState.copyWith(
          results: List.of(currentState.results)..addAll(foods),
          offset: currentState.offset + foods.length,
          hasReachedMax: foods.length < 20,
        )),
      );
    }
  }

  Future<void> _onFilterChanged(FilterChanged event, Emitter<FoodSearchState> emit) async {
    // Current approach restarts search with filters
    // In a real app, we'd keep the current query
    // For now, let's assume we can get the query from the state if needed
  }

  Future<void> _onSortChanged(SortChanged event, Emitter<FoodSearchState> emit) async {
    // Similar to filters
  }

  Future<void> _onLoadRecentFoods(LoadRecentFoods event, Emitter<FoodSearchState> emit) async {
    final result = await _foodRepository.getRecentFoods();
    result.fold(
      (failure) => emit(FoodSearchError(failure.message)),
      (foods) => emit(FoodSearchLoaded(results: const [], recentFoods: foods)),
    );
  }

  Future<void> _onLoadFrequentFoods(LoadFrequentFoods event, Emitter<FoodSearchState> emit) async {
    final result = await _foodRepository.getFrequentFoods();
    result.fold(
      (failure) => emit(FoodSearchError(failure.message)),
      (foods) => emit(FoodSearchLoaded(results: const [], frequentFoods: foods)),
    );
  }
}
