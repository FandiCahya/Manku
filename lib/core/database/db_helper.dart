import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static const _databaseName = 'MyManageLocal.db';
  static const _databaseVersion = 1;

  static const tableTransactions = 'transactions';

  static const columnId = 'id';
  static const columnDescription = 'description';
  static const columnAmount = 'amount';
  static const columnCategoryName = 'category_name';
  static const columnCategoryType = 'category_type';
  static const columnDate = 'date';
  static const columnTime = 'time';
  static const columnInputSource = 'input_source';
  static const columnIsSynced = 'is_synced';
  static const columnCreatedAt = 'created_at';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite not supported on Web. Use API instead.');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnId TEXT PRIMARY KEY,
        $columnDescription TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnCategoryName TEXT NOT NULL,
        $columnCategoryType TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnTime TEXT NOT NULL,
        $columnInputSource TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<String> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    final String id = (row[columnId] as String?) ?? const Uuid().v4();
    row[columnId] = id;
    row[columnIsSynced] ??= 0;
    row[columnCreatedAt] ??= DateTime.now().toIso8601String();
    await db.insert(
      tableTransactions,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllTransactions() async {
    final db = await database;
    return db.query(
      tableTransactions,
      orderBy: '$columnDate DESC, $columnTime DESC',
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete(
      tableTransactions,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllData() async {
    if (kIsWeb) {
      debugPrint('clearAllData: skipped on Web (no local SQLite)');
      return;
    }
    final db = await database;
    await db.delete(tableTransactions);
  }
}
