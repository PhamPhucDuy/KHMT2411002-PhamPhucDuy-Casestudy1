import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'expense_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          category.dart TEXT NOT NULL,
          amount INTEGER NOT NULL,
          date TEXT NOT NULL,
          note TEXT
        )
      '''),
    );
  }

  Future<int> insert(TransactionModel t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    return db.insert('transactions', map);
  }

  Future<int> update(TransactionModel t) async {
    final db = await database;
    return db.update('transactions', t.toMap(),
        where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getAll() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }
}
