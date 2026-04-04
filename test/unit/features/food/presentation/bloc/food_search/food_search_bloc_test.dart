import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';
import 'package:sorutrack_pro/features/food/domain/repositories/food_repository.dart';
import 'package:sorutrack_pro/features/food/presentation/bloc/food_search/food_search_bloc.dart';

@GenerateMocks([FoodRepository])
import 'food_search_bloc_test.mocks.dart';

void main() {
  late MockFoodRepository mockFoodRepository;
  late FoodSearchBloc bloc;

  setUp(() {
    mockFoodRepository = MockFoodRepository();
    bloc = FoodSearchBloc(mockFoodRepository);
  });

  tearDown(() {
    bloc.close();
  });

  const tFoodItem = FoodItem(
    id: '1',
    name: 'Apple',
    calories: 52,
    servingSize: 100,
    servingUnit: 'g',
  );

  group('FoodSearchBloc', () {
    test('initial state should be FoodSearchInitial', () {
      expect(bloc.state, FoodSearchInitial());
    });

    blocTest<FoodSearchBloc, FoodSearchState>(
      'emits [FoodSearchLoading, FoodSearchLoaded] when SearchQueryChanged is added',
      build: () {
        when(mockFoodRepository.searchFoods(any,
                limit: anyNamed('limit'), offset: anyNamed('offset')))
            .thenAnswer((_) async => const Right([tFoodItem]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('apple')),
      wait: const Duration(milliseconds: 400), // Account for debounce
      expect: () => [
        FoodSearchLoading(),
        const FoodSearchLoaded(
          results: [tFoodItem],
          query: 'apple',
          offset: 1,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<FoodSearchBloc, FoodSearchState>(
      'emits [FoodSearchLoaded] with recent foods when LoadRecentFoods is added',
      build: () {
        when(mockFoodRepository.getRecentFoods())
            .thenAnswer((_) async => const Right([tFoodItem]));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadRecentFoods()),
      expect: () => [
        const FoodSearchLoaded(results: [], recentFoods: [tFoodItem]),
      ],
    );

    blocTest<FoodSearchBloc, FoodSearchState>(
      'emits [FoodSearchError] when repository search fails',
      build: () {
        when(mockFoodRepository.searchFoods(any,
                limit: anyNamed('limit'), offset: anyNamed('offset')))
            .thenAnswer((_) async => const Left(DatabaseFailure('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('apple')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        FoodSearchLoading(),
        const FoodSearchError('Error'),
      ],
    );
    
    blocTest<FoodSearchBloc, FoodSearchState>(
      'emits updated FoodSearchLoaded when LoadMoreResults is added',
      build: () {
        when(mockFoodRepository.searchFoods(any,
                limit: anyNamed('limit'), offset: anyNamed('offset')))
            .thenAnswer((_) async => const Right([tFoodItem]));
        return bloc;
      },
      seed: () => const FoodSearchLoaded(
        results: [tFoodItem],
        query: 'apple',
        offset: 1,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(LoadMoreResults()),
      expect: () => [
        const FoodSearchLoaded(
          results: [tFoodItem, tFoodItem],
          query: 'apple',
          offset: 2,
          hasReachedMax: true, // Only 1 more returned, so < 20
        ),
      ],
    );
  });
}
