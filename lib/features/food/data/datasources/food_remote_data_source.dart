import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sorutrack_pro/features/food/domain/entities/food_item.dart';

abstract class FoodRemoteDataSource {
  Future<FoodItem?> getFoodByBarcode(String barcode);
}

@LazySingleton(as: FoodRemoteDataSource)
class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  FoodRemoteDataSourceImpl(this._dio);

  @override
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      final response = await _dio.get('$_baseUrl/$barcode.json');
      
      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'];
        final nutriments = product['nutriments'] ?? {};

        return FoodItem(
          id: barcode,
          name: product['product_name'] ?? 'Unknown Product',
          brand: product['brands'],
          category: product['categories_tags']?.isNotEmpty == true ? product['categories_tags'][0] : null,
          calories: (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 0,
          protein: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0,
          carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0,
          fat: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0,
          fiber: (nutriments['fiber_100g'] as num?)?.toDouble() ?? 0,
          sodium: (nutriments['sodium_100g'] as num?)?.toDouble() ?? 0,
          sugar: (nutriments['sugars_100g'] as num?)?.toDouble() ?? 0,
          servingSize: (product['serving_quantity'] as num?)?.toDouble() ?? 100,
          servingUnit: product['serving_unit'] ?? 'g',
          isCustom: false,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
