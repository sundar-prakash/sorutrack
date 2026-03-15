import 'package:injectable/injectable.dart';
import '../../../../core/database/database_helper.dart';
import '../entities/food_item.dart';

abstract class FoodLocalDataSource {
  Future<List<FoodItem>> searchFoods(String query, {List<String>? filters, String? sortBy, int limit = 20, int offset = 0});
  Future<FoodItem?> getFoodByBarcode(String barcode);
  Future<void> cacheFood(FoodItem food);
  Future<List<FoodItem>> getRecentFoods();
  Future<List<FoodItem>> getFrequentFoods();
  Future<void> saveCustomFood(FoodItem food);
  Future<void> toggleFavorite(String foodId, bool isFavorite);
  Future<void> updateFoodUseCount(String foodId);
}

@LazySingleton(as: FoodLocalDataSource)
class FoodLocalDataSourceImpl implements FoodLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FoodLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<FoodItem>> searchFoods(String query, {List<String>? filters, String? sortBy, int limit = 20, int offset = 0}) async {
    final db = await _databaseHelper.database;
    
    String sql;
    List<dynamic> args = [];
    
    if (query.isEmpty) {
      sql = 'SELECT * FROM food_items WHERE deleted_at IS NULL';
    } else {
      // FTS5 Search
      sql = '''
        SELECT fi.*
        FROM food_items fi
        JOIN foods_fts fts ON fi.id = fts.rowid
        WHERE foods_fts MATCH ? AND fi.deleted_at IS NULL
      ''';
      args.add('$query*');
    }

    // Apply filters (simplified example)
    if (filters != null && filters.isNotEmpty) {
      for (var filter in filters) {
        if (filter == 'Indian') sql += " AND fi.category = 'Indian'";
        if (filter == 'Western') sql += " AND fi.category = 'Western'";
        if (filter == 'High-protein') sql += " AND (fi.protein * 4 / fi.calories) > 0.25";
        if (filter == 'Low-carb') sql += " AND (fi.carbs * 4 / fi.calories) < 0.3";
      }
    }

    // Sort
    if (sortBy == 'Calories') {
      sql += ' ORDER BY fi.calories ASC';
    } else if (sortBy == 'Protein') {
      sql += ' ORDER BY fi.protein DESC';
    } else {
      sql += ' ORDER BY fi.use_count DESC, fi.name ASC';
    }

    // Pagination
    sql += ' LIMIT ? OFFSET ?';
    args.addAll([limit, offset]);

    final result = await db.rawQuery(sql, args);
    return result.map((e) => FoodItem.fromMap(e)).toList();
  }

  @override
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'food_items',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [barcode],
    );
    if (result.isNotEmpty) {
      return FoodItem.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> cacheFood(FoodItem food) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'food_items',
      food.toMap()..['is_custom'] = 0,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<FoodItem>> getRecentFoods() async {
    final db = await _databaseHelper.database;
    // Actually we need a 'last_used' timestamp in food_items or a separate table
    // Let's assume updated_at tracking for now, but a joined query with meal_items is better
    final result = await db.query(
      'food_items',
      where: 'deleted_at IS NULL',
      orderBy: 'updated_at DESC',
      limit: 20,
    );
    return result.map((e) => FoodItem.fromMap(e)).toList();
  }

  @override
  Future<List<FoodItem>> getFrequentFoods() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'food_items',
      where: 'deleted_at IS NULL',
      orderBy: 'use_count DESC',
      limit: 20,
    );
    return result.map((e) => FoodItem.fromMap(e)).toList();
  }

  @override
  Future<void> saveCustomFood(FoodItem food) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'food_items',
      food.toMap()..['is_custom'] = 1,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> toggleFavorite(String foodId, bool isFavorite) async {
    final db = await _databaseHelper.database;
    await db.update(
      'food_items',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [foodId],
    );
  }

  @override
  Future<void> updateFoodUseCount(String foodId) async {
    final db = await _databaseHelper.database;
    await db.rawUpdate(
      'UPDATE food_items SET use_count = use_count + 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [foodId],
    );
  }
}
