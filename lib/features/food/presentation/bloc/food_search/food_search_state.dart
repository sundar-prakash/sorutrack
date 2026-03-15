part of 'food_search_bloc.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();

  @override
  List<Object?> get props => [];
}

class FoodSearchInitial extends FoodSearchState {}

class FoodSearchLoading extends FoodSearchState {}

class FoodSearchLoaded extends FoodSearchState {
  final List<FoodItem> results;
  final List<FoodItem> recentFoods;
  final List<FoodItem> frequentFoods;
  final String query;
  final int offset;
  final bool hasReachedMax;

  const FoodSearchLoaded({
    this.results = const [],
    this.recentFoods = const [],
    this.frequentFoods = const [],
    this.query = '',
    this.offset = 0,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [results, recentFoods, frequentFoods, query, offset, hasReachedMax];

  FoodSearchLoaded copyWith({
    List<FoodItem>? results,
    List<FoodItem>? recentFoods,
    List<FoodItem>? frequentFoods,
    String? query,
    int? offset,
    bool? hasReachedMax,
  }) {
    return FoodSearchLoaded(
      results: results ?? this.results,
      recentFoods: recentFoods ?? this.recentFoods,
      frequentFoods: frequentFoods ?? this.frequentFoods,
      query: query ?? this.query,
      offset: offset ?? this.offset,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class FoodSearchError extends FoodSearchState {
  final String message;
  const FoodSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
