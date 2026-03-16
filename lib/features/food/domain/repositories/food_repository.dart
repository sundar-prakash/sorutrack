import 'package:dartz/dartz.dart';
import 'package:sorutrack_pro/core/error/failures.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';

abstract class FoodRepository {
  Future<Either<Failure, List<FoodItem>>> searchFoods(String query, {List<String>? filters, String? sortBy, int limit = 20, int offset = 0});
  Future<Either<Failure, FoodItem?>> getFoodByBarcode(String barcode);
  Future<Either<Failure, List<FoodItem>>> getRecentFoods();
  Future<Either<Failure, List<FoodItem>>> getFrequentFoods();
  Future<Either<Failure, Unit>> saveCustomFood(FoodItem food);
  Future<Either<Failure, Unit>> toggleFavorite(String foodId, bool isFavorite);
  Future<Either<Failure, Unit>> updateFoodUseCount(String foodId);
}
