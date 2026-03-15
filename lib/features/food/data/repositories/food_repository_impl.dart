import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_local_data_source.dart';
import '../datasources/food_remote_data_source.dart';

@LazySingleton(as: FoodRepository)
class FoodRepositoryImpl implements FoodRepository {
  final FoodLocalDataSource _localDataSource;
  final FoodRemoteDataSource _remoteDataSource;

  FoodRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, List<FoodItem>>> searchFoods(String query, {List<String>? filters, String? sortBy, int limit = 20, int offset = 0}) async {
    try {
      final results = await _localDataSource.searchFoods(query, filters: filters, sortBy: sortBy, limit: limit, offset: offset);
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodItem?>> getFoodByBarcode(String barcode) async {
    try {
      // 1. Check local cache first
      final localFood = await _localDataSource.getFoodByBarcode(barcode);
      if (localFood != null) return Right(localFood);

      // 2. Lookup remote
      final remoteFood = await _remoteDataSource.getFoodByBarcode(barcode);
      if (remoteFood != null) {
        // Cache it
        await _localDataSource.cacheFood(remoteFood);
        return Right(remoteFood);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getRecentFoods() async {
    try {
      final results = await _localDataSource.getRecentFoods();
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getFrequentFoods() async {
    try {
      final results = await _localDataSource.getFrequentFoods();
      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCustomFood(FoodItem food) async {
    try {
      await _localDataSource.saveCustomFood(food);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleFavorite(String foodId, bool isFavorite) async {
    try {
      await _localDataSource.toggleFavorite(foodId, isFavorite);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateFoodUseCount(String foodId) async {
    try {
      await _localDataSource.updateFoodUseCount(foodId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
