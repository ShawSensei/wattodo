import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Singleton — one Database instance prevents "database is locked" errors
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  static const String _dbName = 'wattodo.db';
  static const int _dbVersion = 1;
  static const String taskTable = 'tasks';
  static const String metaTable = 'meta';

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // SQLite has no BOOLEAN type, using INTEGER 0/1 for is_completed
    await db.execute('''
      CREATE TABLE $taskTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Key-value store for one-time flags like "seeded"
    await db.execute('''
      CREATE TABLE $metaTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }
}
