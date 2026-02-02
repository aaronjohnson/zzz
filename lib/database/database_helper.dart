import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sleep_hygiene.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        short_desc TEXT NOT NULL,
        long_desc TEXT NOT NULL,
        category TEXT NOT NULL,
        display_order INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        log_date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (habit_id) REFERENCES habits(id),
        UNIQUE(habit_id, log_date)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_daily_logs_date ON daily_logs(log_date)');
    await db.execute(
        'CREATE INDEX idx_daily_logs_habit ON daily_logs(habit_id)');

    // Seed default habits
    for (final habit in defaultHabits) {
      await db.insert('habits', habit.toMap());
    }
  }

  // Habit operations
  Future<List<Habit>> getActiveHabits() async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'display_order',
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  // Daily log operations
  Future<Map<int, bool>> getLogsForDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'daily_logs',
      where: 'log_date = ?',
      whereArgs: [date],
    );

    final result = <int, bool>{};
    for (final map in maps) {
      result[map['habit_id'] as int] = (map['completed'] as int) == 1;
    }
    return result;
  }

  Future<Map<String, Map<int, bool>>> getLogsForWeek(List<String> dates) async {
    final db = await database;
    final placeholders = dates.map((_) => '?').join(',');
    final maps = await db.query(
      'daily_logs',
      where: 'log_date IN ($placeholders)',
      whereArgs: dates,
    );

    final result = <String, Map<int, bool>>{};
    for (final date in dates) {
      result[date] = {};
    }
    for (final map in maps) {
      final date = map['log_date'] as String;
      final habitId = map['habit_id'] as int;
      final completed = (map['completed'] as int) == 1;
      result[date]![habitId] = completed;
    }
    return result;
  }

  Future<void> toggleHabitCompletion(int habitId, String date, bool completed) async {
    final db = await database;

    // Try to update existing record
    final updated = await db.update(
      'daily_logs',
      {'completed': completed ? 1 : 0},
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, date],
    );

    // If no record exists, insert one
    if (updated == 0) {
      await db.insert('daily_logs', {
        'habit_id': habitId,
        'log_date': date,
        'completed': completed ? 1 : 0,
      });
    }
  }

  Future<DailyLog?> getLog(int habitId, String date) async {
    final db = await database;
    final maps = await db.query(
      'daily_logs',
      where: 'habit_id = ? AND log_date = ?',
      whereArgs: [habitId, date],
    );
    if (maps.isEmpty) return null;
    return DailyLog.fromMap(maps.first);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
