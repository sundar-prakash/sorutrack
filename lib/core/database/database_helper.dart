import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';
import 'database_migration.dart';

@lazySingleton
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final Logger _logger = Logger();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _logger.i('Initializing database...');
    if (UniversalPlatform.isWindows || UniversalPlatform.isLinux || UniversalPlatform.isMacOS) {
      _logger.i('Initializing FFI for Desktop');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else if (UniversalPlatform.isWeb) {
      _logger.i('Initializing FFI for Web with explicit options');
      databaseFactory = createDatabaseFactoryFfiWeb(
        options: SqfliteFfiWebOptions(
          sqlite3WasmUri: Uri.parse('sqlite3.wasm'),
          sharedWorkerUri: Uri.parse('sqflite_sw.js'),
        ),
      );
    }

    String path;
    if (UniversalPlatform.isWeb) {
      path = 'sorutrack_pro.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'sorutrack_pro.db');
    }
    _logger.i('Opening database at: $path');
    
    Database db;
    try {
      db = await openDatabase(
        path,
        version: DatabaseMigration.currentVersion,
        onCreate: _onCreate,
        onConfigure: _onConfigure,
        onUpgrade: (db, oldVersion, newVersion) async {
          _logger.i('Upgrading database from $oldVersion to $newVersion');
          await DatabaseMigration.migrate(db, oldVersion, newVersion);
        },
      );
    } catch (e) {
      if (e.toString().contains('no such module: fts5')) {
        _logger.e('Critical FTS5 module missing but table exists. Deleting database to resolve deadlock.');
        await deleteDatabase(path);
        // Retry exactly once after deletion
        db = await openDatabase(
          path,
          version: DatabaseMigration.currentVersion,
          onCreate: _onCreate,
          onConfigure: _onConfigure,
        );
      } else {
        rethrow;
      }
    }

    _logger.i('Database opened successfully.');

    // Phase 9: Copy and merge bundled food database if needed
    _logger.i('Checking for food database merge...');
    await _copyAndMergeFoodDatabase(db);

    return db;
  }

  /// Opens an in-memory database for testing purposes.
  Future<Database> openTestDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    _database = await openDatabase(
      inMemoryDatabasePath,
      version: DatabaseMigration.currentVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
    return _database!;
  }

  /// Reset the database instance (useful for tests)
  void reset() {
    _database = null;
  }

  Future<void> _copyAndMergeFoodDatabase(Database db) async {
    if (UniversalPlatform.isWeb) {
      _logger.i('Merging bundled food database skipped on Web (not supported via dart:io)');
      return;
    }
    final dbPath = await getDatabasesPath();
    final assetPath = join(dbPath, 'food_database.db');

    // Check if food_items is already populated (simplest check for "already merged")
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM food_items WHERE is_custom = 0'));
    if (count != null && count > 0) {
      _logger.i('Bundled food database already merged.');
      return;
    }

    _logger.i('Merging bundled food database...');
    try {
      // 1. Copy asset to filesystem
      final data = await rootBundle.load('assets/food_database.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(assetPath).writeAsBytes(bytes, flush: true);

      // 2. Attach and Merge
      await db.execute("ATTACH DATABASE ? AS bundled", [assetPath]);
      
      // We use INSERT OR IGNORE to avoid duplicates if some are already there
      await db.execute('''
        INSERT OR IGNORE INTO food_items (
          id, name, brand, category, calories, protein, carbs, fat, fiber, sodium, sugar, serving_size, serving_unit, is_custom
        )
        SELECT 
          id, name, brand, category, calories, protein, carbs, fat, fiber, sodium, sugar, serving_size, serving_unit, 0
        FROM bundled.food_items
      ''');

      await db.execute("DETACH DATABASE bundled");
      _logger.i('Food database merged successfully.');

      // 3. Clean up the temp file
      await File(assetPath).delete();
    } catch (e) {
      _logger.e('Error merging food database: $e');
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    if (!UniversalPlatform.isWeb) {
      // Use rawQuery for PRAGMA journal_mode as it returns a result which can cause 
      // SqfliteDatabaseException on some Android versions if execute() is used.
      await db.rawQuery('PRAGMA journal_mode = WAL');
    }
    await db.rawQuery('PRAGMA synchronous = NORMAL');
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables...');

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        gender TEXT,
        age INTEGER,
        height REAL,
        height_unit TEXT,
        weight REAL,
        weight_unit TEXT,
        activity_level TEXT,
        goal TEXT,
        target_weight REAL,
        weekly_goal REAL,
        target_date DATE,
        dietary_preference TEXT,
        allergies TEXT,
        cuisines TEXT,
        meal_reminder_morning TEXT,
        meal_reminder_afternoon TEXT,
        meal_reminder_evening TEXT,
        water_reminder_interval INTEGER,
        is_onboarded INTEGER DEFAULT 0,
        body_fat_percentage REAL,
        is_pregnant INTEGER DEFAULT 0,
        is_lactating INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP
      )
    ''');

    // User Goals Table
    await db.execute('''
      CREATE TABLE user_goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        goal_type TEXT NOT NULL, -- calories, protein, etc.
        target_value REAL NOT NULL,
        start_date TIMESTAMP NOT NULL,
        end_date TIMESTAMP,
        status TEXT DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Food Items Table (General Library)
    await db.execute('''
      CREATE TABLE food_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        calories REAL NOT NULL,
        protein REAL DEFAULT 0,
        carbs REAL DEFAULT 0,
        fat REAL DEFAULT 0,
        fiber REAL DEFAULT 0,
        sodium REAL DEFAULT 0,
        sugar REAL DEFAULT 0,
        potassium REAL DEFAULT 0,
        vitamin_a REAL DEFAULT 0,
        vitamin_c REAL DEFAULT 0,
        calcium REAL DEFAULT 0,
        iron REAL DEFAULT 0,
        serving_size REAL,
        serving_unit TEXT,
        category TEXT,
        is_custom INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP
      )
    ''');

    // Food Cache (For Gemini results)
    await db.execute('''
      CREATE TABLE food_cache (
        id TEXT PRIMARY KEY,
        input_text TEXT UNIQUE,
        parsed_json TEXT NOT NULL,
        use_count INTEGER DEFAULT 1,
        last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // API Usage tracking
    await db.execute('''
      CREATE TABLE api_usage (
        date TEXT PRIMARY KEY, -- YYYY-MM-DD
        call_count INTEGER DEFAULT 0,
        token_estimate INTEGER DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Meals Table
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL, -- Breakfast, Lunch, etc.
        meal_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Meal Items Table
    await db.execute('''
      CREATE TABLE meal_items (
        id TEXT PRIMARY KEY,
        meal_id TEXT NOT NULL,
        food_item_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL DEFAULT 0,
        carbs REAL DEFAULT 0,
        fat REAL DEFAULT 0,
        fiber REAL DEFAULT 0,
        sodium REAL DEFAULT 0,
        sugar REAL DEFAULT 0,
        potassium REAL DEFAULT 0,
        vitamin_a REAL DEFAULT 0,
        vitamin_c REAL DEFAULT 0,
        calcium REAL DEFAULT 0,
        iron REAL DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (meal_id) REFERENCES meals (id) ON DELETE CASCADE,
        FOREIGN KEY (food_item_id) REFERENCES food_items (id)
      )
    ''');

    // Daily Logs
    await db.execute('''
      CREATE TABLE daily_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL, -- YYYY-MM-DD
        total_calories REAL DEFAULT 0,
        total_protein REAL DEFAULT 0,
        total_carbs REAL DEFAULT 0,
        total_fat REAL DEFAULT 0,
        total_fiber REAL DEFAULT 0,
        total_sodium REAL DEFAULT 0,
        total_sugar REAL DEFAULT 0,
        total_potassium REAL DEFAULT 0,
        water_intake REAL DEFAULT 0,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        UNIQUE(user_id, date),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Water Logs
    await db.execute('''
      CREATE TABLE water_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Weight Logs
    await db.execute('''
      CREATE TABLE weight_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        weight REAL NOT NULL,
        logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Exercise Logs
    await db.execute('''
      CREATE TABLE exercise_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        duration_minutes INTEGER,
        calories_burned REAL,
        logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Gamification Data
    await db.execute('''
      CREATE TABLE gamification_data (
        user_id TEXT PRIMARY KEY,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        current_streak INTEGER DEFAULT 0,
        highest_streak INTEGER DEFAULT 0,
        streak_freeze_count INTEGER DEFAULT 0,
        last_check_in TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // XP History
    await db.execute('''
      CREATE TABLE xp_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Challenges
    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        reward_xp INTEGER NOT NULL,
        type TEXT NOT NULL,
        target_value REAL NOT NULL,
        duration_days INTEGER DEFAULT 7,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User Challenges
    await db.execute('''
      CREATE TABLE user_challenges (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        challenge_id TEXT NOT NULL,
        current_value REAL DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        completed_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (challenge_id) REFERENCES challenges (id) ON DELETE CASCADE
      )
    ''');

    // Badges
    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT, -- streak, nutrition, milestone, special
        criteria TEXT, -- JSON logic or type
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Achievements (User-Badge mapping)
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        badge_id TEXT NOT NULL,
        unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (badge_id) REFERENCES badges (id) ON DELETE CASCADE
      )
    ''');

    // Notifications Schedule
    await db.execute('''
      CREATE TABLE notifications_schedule (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        scheduled_time TEXT NOT NULL, -- HH:mm
        days_of_week TEXT, -- 1,2,3...
        is_active INTEGER DEFAULT 1,
        type TEXT, -- reminder, alert
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // App Settings
    await db.execute('''
      CREATE TABLE app_settings (
        user_id TEXT PRIMARY KEY,
        theme_mode TEXT DEFAULT 'system',
        language TEXT DEFAULT 'en',
        unit_system TEXT DEFAULT 'metric',
        push_enabled INTEGER DEFAULT 1,
        biometric_enabled INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Notification Settings
    await db.execute('''
      CREATE TABLE notification_settings (
        user_id TEXT PRIMARY KEY,
        master_enabled INTEGER DEFAULT 1,
        meal_reminders_enabled INTEGER DEFAULT 1,
        smart_reminders_enabled INTEGER DEFAULT 1,
        streak_protection_enabled INTEGER DEFAULT 1,
        water_reminders_enabled INTEGER DEFAULT 1,
        achievements_enabled INTEGER DEFAULT 1,
        weekly_summary_enabled INTEGER DEFAULT 1,
        goal_reminders_enabled INTEGER DEFAULT 1,
        breakfast_time TEXT DEFAULT '08:00',
        lunch_time TEXT DEFAULT '13:00',
        dinner_time TEXT DEFAULT '19:30',
        water_interval_hours INTEGER DEFAULT 2,
        sleep_start_time TEXT DEFAULT '22:00',
        sleep_end_time TEXT DEFAULT '07:00',
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Foods FTS Table with robust detection and different name to avoid poisoned table state
    bool fts5Supported = false;
    try {
      await db.execute('CREATE VIRTUAL TABLE fts5_test USING fts5(dummy)');
      await db.execute('DROP TABLE fts5_test');
      fts5Supported = true;
    } catch (_) {}

    if (fts5Supported) {
      await db.execute('CREATE VIRTUAL TABLE IF NOT EXISTS food_items_fts USING fts5(food_id UNINDEXED, name, brand, category)');
      _logger.i('FTS5 table created successfully.');
    } else {
      bool fts4Supported = false;
      try {
        await db.execute('CREATE VIRTUAL TABLE fts4_test USING fts4(dummy)');
        await db.execute('DROP TABLE fts4_test');
        fts4Supported = true;
      } catch (_) {}

      if (fts4Supported) {
        await db.execute('CREATE VIRTUAL TABLE IF NOT EXISTS food_items_fts USING fts4(food_id, name, brand, category, notindexed=food_id)');
        _logger.i('FTS4 table created successfully.');
      } else {
        await db.execute('CREATE TABLE IF NOT EXISTS food_items_fts (food_id TEXT, name TEXT, brand TEXT, category TEXT)');
      }
    }

    // Foods FTS Triggers
    await db.execute('''
      CREATE TRIGGER food_items_ai AFTER INSERT ON food_items BEGIN
        INSERT INTO food_items_fts(food_id, name, brand, category) VALUES (new.id, new.name, new.brand, new.category);
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER food_items_ad AFTER DELETE ON food_items BEGIN
        DELETE FROM food_items_fts WHERE food_id = old.id;
      END;
    ''');
    await db.execute('''
      CREATE TRIGGER food_items_au AFTER UPDATE ON food_items BEGIN
        UPDATE food_items_fts SET name = new.name, brand = new.brand, category = new.category WHERE food_id = old.id;
      END;
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_meals_user_id ON meals(user_id)');
    await db.execute('CREATE INDEX idx_meal_items_meal_id ON meal_items(meal_id)');
    await db.execute('CREATE INDEX idx_daily_logs_user_date ON daily_logs(user_id, date)');
    await db.execute('CREATE INDEX idx_food_items_name ON food_items(name)');
    
    _logger.i('Tables created successfully.');
  }

  // Dashboard Queries

  Future<Map<String, dynamic>> getTodayNutrition(String userId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(mi.calories) as calories,
        SUM(mi.protein) as protein,
        SUM(mi.carbs) as carbs,
        SUM(mi.fat) as fat,
        SUM(mi.fiber) as fiber
      FROM meal_items mi
      JOIN meals m ON mi.meal_id = m.id
      WHERE m.user_id = ? AND DATE(m.meal_time) = ? AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
    ''', [userId, date]);

    if (result.isNotEmpty && result.first['calories'] != null) {
      return result.first;
    }
    return {'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0, 'fiber': 0.0};
  }

  Future<double> getExerciseCaloriesByDate(String userId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(calories_burned) as total_burned
      FROM exercise_logs
      WHERE user_id = ? AND DATE(logged_at) = ? AND deleted_at IS NULL
    ''', [userId, date]);

    if (result.isNotEmpty && result.first['total_burned'] != null) {
      return (result.first['total_burned'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('meals');
      await txn.delete('meal_items');
      await txn.delete('daily_logs');
      await txn.delete('water_logs');
      await txn.delete('weight_logs');
      await txn.delete('exercise_logs');
      await txn.delete('food_cache');
      await txn.delete('api_usage');
      await txn.delete('gamification_data');
      await txn.delete('xp_history');
      await txn.delete('user_challenges');
      await txn.delete('achievements');
      await txn.delete('notifications_schedule');
      // We keep users and app_settings or reset them? 
      // User asked to clear "all your meals, weight history, and settings".
      await txn.delete('users');
      await txn.delete('app_settings');
      await txn.delete('notification_settings');
    });
  }

  Future<List<Map<String, dynamic>>> getMealsByDate(String userId, String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT m.*, 
        (SELECT COUNT(*) FROM meal_items mi WHERE mi.meal_id = m.id AND mi.deleted_at IS NULL) as item_count,
        (SELECT SUM(mi.calories) FROM meal_items mi WHERE mi.meal_id = m.id AND mi.deleted_at IS NULL) as total_calories
      FROM meals m
      WHERE m.user_id = ? AND DATE(m.meal_time) = ? AND m.deleted_at IS NULL
      ORDER BY m.meal_time ASC
    ''', [userId, date]);
  }

  Future<List<Map<String, dynamic>>> getMealItemsByMealId(String mealId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT mi.*, fi.name as name
      FROM meal_items mi
      JOIN food_items fi ON mi.food_item_id = fi.id
      WHERE mi.meal_id = ? AND mi.deleted_at IS NULL
    ''', [mealId]);
  }

  Future<List<Map<String, dynamic>>> getWeeklyCalories(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final dateStr = sevenDaysAgo.toIso8601String().split('T')[0];

    return await db.rawQuery('''
      SELECT DATE(m.meal_time) as date, SUM(mi.calories) as total_calories
      FROM meals m
      JOIN meal_items mi ON m.id = mi.meal_id
      WHERE m.user_id = ? AND DATE(m.meal_time) >= ? AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
      GROUP BY DATE(m.meal_time)
      ORDER BY date ASC
    ''', [userId, dateStr]);
  }

  Future<double> getWaterByDate(String userId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total_water
      FROM water_logs
      WHERE user_id = ? AND DATE(logged_at) = ? AND deleted_at IS NULL
    ''', [userId, date]);

    if (result.isNotEmpty && result.first['total_water'] != null) {
      return (result.first['total_water'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> getCurrentStreak(String userId) async {
    final db = await database;
    final result = await db.query(
      'gamification_data',
      columns: ['current_streak'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first['current_streak'] as int;
    }
    return 0;
  }

  // Phase 5: Reports & Analytics Queries

  Future<List<Map<String, dynamic>>> getCalorieTrend(String userId, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT date, total_calories as calories
      FROM daily_logs
      WHERE user_id = ? AND date BETWEEN ? AND ? AND deleted_at IS NULL
      ORDER BY date ASC
    ''', [userId, startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getMacroTrend(String userId, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT date, total_protein as protein, total_carbs as carbs, total_fat as fat
      FROM daily_logs
      WHERE user_id = ? AND date BETWEEN ? AND ? AND deleted_at IS NULL
      ORDER BY date ASC
    ''', [userId, startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getTopFoods(String userId, int limit, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT fi.name, COUNT(*) as frequency, SUM(mi.calories) as total_calories
      FROM meal_items mi
      JOIN meals m ON mi.meal_id = m.id
      JOIN food_items fi ON mi.food_item_id = fi.id
      WHERE m.user_id = ? AND DATE(m.meal_time) BETWEEN ? AND ? 
        AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
      GROUP BY fi.id
      ORDER BY frequency DESC
      LIMIT ?
    ''', [userId, startDate, endDate, limit]);
  }

  Future<List<Map<String, dynamic>>> getMealTimingData(String userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT strftime('%H', meal_time) as hour, COUNT(*) as count
      FROM meals
      WHERE user_id = ? AND deleted_at IS NULL
      GROUP BY hour
      ORDER BY hour ASC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getWeightTrend(String userId, String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT DATE(logged_at) as date, weight
      FROM weight_logs
      WHERE user_id = ? AND DATE(logged_at) BETWEEN ? AND ? AND deleted_at IS NULL
      ORDER BY date ASC
    ''', [userId, startDate, endDate]);
  }

  Future<List<Map<String, dynamic>>> getGoalAdherence(String userId, String startDate, String endDate) async {
    final db = await database;
    // This query assumes a 'calories' goal exists in user_goals. 
    // It compares daily_logs.total_calories with user_goals.target_value
    return await db.rawQuery('''
      SELECT dl.date, dl.total_calories, ug.target_value as goal_calories,
             CASE WHEN dl.total_calories <= ug.target_value THEN 1 ELSE 0 END as is_on_track
      FROM daily_logs dl
      JOIN user_goals ug ON dl.user_id = ug.user_id
      WHERE dl.user_id = ? AND dl.date BETWEEN ? AND ? 
        AND ug.goal_type = 'calories' AND ug.status = 'active'
        AND dl.deleted_at IS NULL
      ORDER BY dl.date ASC
    ''', [userId, startDate, endDate]);
  }

  Future<Map<String, dynamic>> getMicronutrientAverages(String userId, String startDate, String endDate) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        AVG(total_fiber) as avg_fiber,
        AVG(total_sodium) as avg_sodium,
        AVG(total_sugar) as avg_sugar,
        AVG(total_potassium) as avg_potassium
      FROM daily_logs
      WHERE user_id = ? AND date BETWEEN ? AND ? AND deleted_at IS NULL
    ''', [userId, startDate, endDate]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> searchFoodInLog(
    String userId, 
    String query, 
    {String? startDate, String? endDate, List<String>? mealTypes, double? minCalories, double? maxCalories}
  ) async {
    final db = await database;
    String sql = '''
      SELECT m.meal_time, m.name as meal_type, fi.name as food_name, mi.calories, mi.protein, mi.carbs, mi.fat
      FROM meal_items mi
      JOIN meals m ON mi.meal_id = m.id
      JOIN food_items fi ON mi.food_item_id = fi.id
      WHERE m.user_id = ? AND m.deleted_at IS NULL AND mi.deleted_at IS NULL
    ''';
    List<dynamic> args = [userId];

    if (query.isNotEmpty) {
      sql += " AND fi.name LIKE ?";
      args.add('%$query%');
    }
    if (startDate != null && endDate != null) {
      sql += " AND DATE(m.meal_time) BETWEEN ? AND ?";
      args.add(startDate);
      args.add(endDate);
    }
    if (mealTypes != null && mealTypes.isNotEmpty) {
      sql += " AND m.name IN (${mealTypes.map((_) => '?').join(',')})";
      args.addAll(mealTypes);
    }
    if (minCalories != null) {
      sql += " AND mi.calories >= ?";
      args.add(minCalories);
    }
    if (maxCalories != null) {
      sql += " AND mi.calories <= ?";
      args.add(maxCalories);
    }

    sql += " ORDER BY m.meal_time DESC";
    return await db.rawQuery(sql, args);
  }

  Future<void> logWater(String userId, String date, double amountMl) async {
    final db = await database;
    await db.insert(
      'water_logs',
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID gen
        'user_id': userId,
        'amount': amountMl,
        // logged_at is CURRENT_TIMESTAMP by default, but we should align with date
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
