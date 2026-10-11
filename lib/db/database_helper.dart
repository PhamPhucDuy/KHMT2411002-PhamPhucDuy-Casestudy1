import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Tăng lên mỗi khi dữ liệu thay đổi để các màn hình tự tải lại.
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'expense_manager.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTransactions(db);
        await _createSettings(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Bản cũ có thể đã tạo bảng sai -> xóa và tạo lại
          await db.execute('DROP TABLE IF EXISTS transactions');
          await _createTransactions(db);
        }
        if (oldVersion < 3) {
          await _createSettings(db);
        }
      },
    );
  }

  Future<void> _createTransactions(Database db) => db.execute('''
    CREATE TABLE transactions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      amount INTEGER NOT NULL,
      date TEXT NOT NULL,
      note TEXT
    )
  ''');

  Future<void> _createSettings(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS settings(
      setting_key TEXT PRIMARY KEY,
      setting_value TEXT NOT NULL
    )
  ''');

  // ---------- Giao dịch ----------
  Future<int> insert(TransactionModel t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    final id = await db.insert('transactions', map);
    changes.value++;
    return id;
  }

  Future<int> update(TransactionModel t) async {
    final db = await database;
    final n = await db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
    changes.value++;
    return n;
  }

  Future<int> delete(int id) async {
    final db = await database;
    final n = await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    changes.value++;
    return n;
  }

  Future<List<TransactionModel>> getAll() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  // ---------- Cài đặt (tên, email, ngân sách, thông báo) ----------
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final rows = await db.query('settings');
    final result = <String, String>{};
    for (final r in rows) {
      result[r['setting_key'] as String] = r['setting_value'] as String;
    }
    return result;
  }

  Future<void> setSettings(Map<String, String> values) async {
    final db = await database;
    final batch = db.batch();
    values.forEach((k, v) {
      batch.insert(
        'settings',
        {'setting_key': k, 'setting_value': v},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
    changes.value++;
  }

  Future<void> setSetting(String key, String value) =>
      setSettings({key: value});
}
