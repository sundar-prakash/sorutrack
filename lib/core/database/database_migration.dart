import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

class DatabaseMigration {
  static final Logger _logger = Logger();
  
  static const int currentVersion = 8;

  /// Migration map: version → migration SQL commands
  static final Map<int, List<String>> migrations = {
    2: [
      'ALTER TABLE users ADD COLUMN height_unit TEXT;',
      'ALTER TABLE users ADD COLUMN weight_unit TEXT;',
      'ALTER TABLE users ADD COLUMN goal TEXT;',
      'ALTER TABLE users ADD COLUMN target_weight REAL;',
      'ALTER TABLE users ADD COLUMN weekly_goal REAL;',
      'ALTER TABLE users ADD COLUMN target_date DATE;',
      'ALTER TABLE users ADD COLUMN dietary_preference TEXT;',
      'ALTER TABLE users ADD COLUMN allergies TEXT;',
      'ALTER TABLE users ADD COLUMN cuisines TEXT;',
      'ALTER TABLE users ADD COLUMN meal_reminder_morning TEXT;',
      'ALTER TABLE users ADD COLUMN meal_reminder_afternoon TEXT;',
      'ALTER TABLE users ADD COLUMN meal_reminder_evening TEXT;',
      'ALTER TABLE users ADD COLUMN water_reminder_interval INTEGER;',
      'ALTER TABLE users ADD COLUMN is_onboarded INTEGER DEFAULT 0;',
      'ALTER TABLE users ADD COLUMN body_fat_percentage REAL;',
      'ALTER TABLE users ADD COLUMN is_pregnant INTEGER DEFAULT 0;',
      'ALTER TABLE users ADD COLUMN is_lactating INTEGER DEFAULT 0;'
    ],
    3: [
      '''
      CREATE TABLE api_usage (
        date TEXT PRIMARY KEY,
        call_count INTEGER DEFAULT 0,
        token_estimate INTEGER DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
      ''',
      'DROP TABLE IF EXISTS food_cache;',
      '''
      CREATE TABLE food_cache (
        id TEXT PRIMARY KEY,
        input_text TEXT UNIQUE,
        parsed_json TEXT NOT NULL,
        use_count INTEGER DEFAULT 1,
        last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
      '''
    ],
    4: [
      '''
      CREATE TABLE weight_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        weight REAL NOT NULL,
        logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
      ''',
      'ALTER TABLE food_items ADD COLUMN fiber REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN sodium REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN sugar REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN potassium REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN vitamin_a REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN vitamin_c REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN calcium REAL DEFAULT 0;',
      'ALTER TABLE food_items ADD COLUMN iron REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN fiber REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN sodium REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN sugar REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN potassium REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN vitamin_a REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN vitamin_c REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN calcium REAL DEFAULT 0;',
      'ALTER TABLE meal_items ADD COLUMN iron REAL DEFAULT 0;',
      'ALTER TABLE daily_logs ADD COLUMN total_fiber REAL DEFAULT 0;',
      'ALTER TABLE daily_logs ADD COLUMN total_sodium REAL DEFAULT 0;',
      'ALTER TABLE daily_logs ADD COLUMN total_sugar REAL DEFAULT 0;',
      'ALTER TABLE daily_logs ADD COLUMN total_potassium REAL DEFAULT 0;'
    ],
    5: [
      'ALTER TABLE food_items ADD COLUMN glycemic_index INTEGER DEFAULT 0;',
      'ALTER TABLE water_logs ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;',
      'ALTER TABLE weight_logs ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;',
      'CREATE INDEX IF NOT EXISTS idx_meals_date ON meals(meal_time, user_id);'
    ],
    6: [
      'ALTER TABLE gamification_data ADD COLUMN streak_freeze_count INTEGER DEFAULT 0;',
      '''
      CREATE TABLE xp_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
      ''',
      '''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        reward_xp INTEGER NOT NULL,
        type TEXT NOT NULL, -- calories, protein, water, meal_log, etc.
        target_value REAL NOT NULL,
        duration_days INTEGER DEFAULT 7,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
      ''',
      '''
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
      '''
    ],
    7: [
      '''
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
      '''
    ],
    8: [
      'ALTER TABLE food_items ADD COLUMN category TEXT;',
      'CREATE VIRTUAL TABLE foods_fts USING fts5(name, brand, category, content="food_items", content_rowid="id");',
      '''
      CREATE TRIGGER food_items_ai AFTER INSERT ON food_items BEGIN
        INSERT INTO foods_fts(rowid, name, brand, category) VALUES (new.id, new.name, new.brand, new.category);
      END;
      ''',
      '''
      CREATE TRIGGER food_items_ad AFTER DELETE ON food_items BEGIN
        INSERT INTO foods_fts(foods_fts, rowid, name, brand, category) VALUES('delete', old.id, old.name, old.brand, old.category);
      END;
      ''',
      '''
      CREATE TRIGGER food_items_au AFTER UPDATE ON food_items BEGIN
        INSERT INTO foods_fts(foods_fts, rowid, name, brand, category) VALUES('delete', old.id, old.name, old.brand, old.category);
        INSERT INTO foods_fts(rowid, name, brand, category) VALUES (new.id, new.name, new.brand, new.category);
      END;
      '''
    ],
  };

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    _logger.i('Migrating database from version $oldVersion to $newVersion...');
    
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      if (migrations.containsKey(v)) {
        _logger.i('Running migration for version $v');
        for (final sql in migrations[v]!) {
          try {
            await db.execute(sql);
          } catch (e) {
            _logger.e('Error during migration v$v: $e');
            // Depending on requirements, we might want to rethrow or continue
          }
        }
      }
    }
    
    _logger.i('Database migration completed.');
  }

  /// Sync Conflict Resolution: Track last_modified timestamp on all records
  /// This should be called before inserting/updating imported records.
  static bool shouldOverwrite(Map<String, dynamic> localRecord, Map<String, dynamic> importedRecord) {
    if (!localRecord.containsKey('updated_at') || !importedRecord.containsKey('updated_at')) {
      return true; // Default to overwrite if no timestamp
    }
    
    final localTime = DateTime.tryParse(localRecord['updated_at'] ?? '') ?? DateTime(1970);
    final importedTime = DateTime.tryParse(importedRecord['updated_at'] ?? '') ?? DateTime(1970);
    
    return importedTime.isAfter(localTime);
  }
}
