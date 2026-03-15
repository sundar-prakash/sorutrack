part of 'food_search_bloc.dart';

abstract class FoodSearchEvent extends Equatable {
  const FoodSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends FoodSearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterChanged extends FoodSearchEvent {
  final List<String> filters;
  const FilterChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

class SortChanged extends FoodSearchEvent {
  final String sortBy;
  const SortChanged(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class LoadRecentFoods extends FoodSearchEvent {}

class LoadFrequentFoods extends FoodSearchEvent {}
class LoadMoreResults extends FoodSearchEvent {}
