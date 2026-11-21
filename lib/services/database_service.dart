import 'package:sqflite/sqflite.dart';
import 'package:monvexa/models/account_model.dart';

class DatabaseService {
  static final DatabaseService to = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '${databasesPath}monvexa.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT,
            bankName TEXT,
            accountNumber TEXT,
            balance REAL,
            address TEXT,
            type TEXT,
            createdAt INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertAccount(AccountModel account) async {
    final db = await database;
    return await db.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AccountModel>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      orderBy: 'createdAt ASC',
    );
    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  Future<bool> accountExists(String bankName, String accountNumber) async {
    final db = await database;
    final result = await db.query(
      'accounts',
      where: 'bankName = ? AND accountNumber = ?',
      whereArgs: [bankName, accountNumber],
    );
    return result.isNotEmpty;
  }

  Future<int> deleteAccount(String id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
