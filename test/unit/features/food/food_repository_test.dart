import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sorutrack_pro/features/food/data/datasources/food_local_data_source.dart';
import 'package:sorutrack_pro/features/food/data/datasources/food_remote_data_source.dart';
import 'package:sorutrack_pro/features/food/data/repositories/food_repository_impl.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';
import 'package:sorutrack_pro/core/error/failures.dart';

@GenerateMocks([FoodLocalDataSource, FoodRemoteDataSource])
import 'food_repository_test.mocks.dart';

void main() {
  late MockFoodLocalDataSource mockLocalDataSource;
  late MockFoodRemoteDataSource mockRemoteDataSource;
  late FoodRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockFoodLocalDataSource();
    mockRemoteDataSource = MockFoodRemoteDataSource();
    repository = FoodRepositoryImpl(mockLocalDataSource, mockRemoteDataSource);
  });

  const tFoodItem = FoodItem(
    id: '1',
    name: 'Apple',
    calories: 52,
    servingSize: 100,
    servingUnit: 'g',
  );

  group('searchFoods', () {
    test('should return list of foods from local data source', () async {
      // Arrange
      when(mockLocalDataSource.searchFoods(any,
              filters: anyNamed('filters'),
              sortBy: anyNamed('sortBy'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset')))
          .thenAnswer((_) async => [tFoodItem]);

      // Act
      final result = await repository.searchFoods('apple');

      // Assert
      result.fold(
        (l) => fail('Should have returned Right'),
        (r) => expect(r, [tFoodItem]),
      );
      verify(mockLocalDataSource.searchFoods('apple', limit: 20, offset: 0));
    });

    test('should return DatabaseFailure when local search fails', () async {
      // Arrange
      when(mockLocalDataSource.searchFoods(any,
              filters: anyNamed('filters'),
              sortBy: anyNamed('sortBy'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset')))
          .thenThrow(Exception('DB Error'));

      // Act
      final result = await repository.searchFoods('apple');

      // Assert
      expect(result, isA<Left<Failure, List<FoodItem>>>());
    });
  });

  group('getFoodByBarcode', () {
    const tBarcode = '123456789';

    test('should return local food if found in cache', () async {
      // Arrange
      when(mockLocalDataSource.getFoodByBarcode(tBarcode))
          .thenAnswer((_) async => tFoodItem);

      // Act
      final result = await repository.getFoodByBarcode(tBarcode);

      // Assert
      expect(result, Right<Failure, FoodItem?>(tFoodItem));
      verify(mockLocalDataSource.getFoodByBarcode(tBarcode));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('should return remote food and cache it if not in local', () async {
      // Arrange
      when(mockLocalDataSource.getFoodByBarcode(tBarcode))
          .thenAnswer((_) async => null);
      when(mockRemoteDataSource.getFoodByBarcode(tBarcode))
          .thenAnswer((_) async => tFoodItem);

      // Act
      final result = await repository.getFoodByBarcode(tBarcode);

      // Assert
      expect(result, Right<Failure, FoodItem?>(tFoodItem));
      verify(mockRemoteDataSource.getFoodByBarcode(tBarcode));
      verify(mockLocalDataSource.cacheFood(tFoodItem));
    });
  });
}
