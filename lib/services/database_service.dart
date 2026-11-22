import 'package:sqflite/sqflite.dart';
import 'package:monvexa/models/account_model.dart';
import 'package:monvexa/models/transaction_model.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await _createAccountsTable(db);
        await _createTransactionsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTransactionsTable(db);
        }
      },
    );
  }

  Future<void> _createAccountsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS accounts (
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
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT,
        bankName TEXT,
        accountNumber TEXT,
        address TEXT,
        amount REAL,
        balance REAL,
        type TEXT,
        title TEXT,
        description TEXT,
        category TEXT,
        timestamp INTEGER,
        rawBody TEXT
      )
    ''');
    // Index for quick queries by account and timestamp
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_txn_account_time 
      ON transactions (accountNumber, timestamp DESC)
    ''');
  }

  // ── Account operations ──────────────────────────────────────────────
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

  // ── Transaction operations ──────────────────────────────────────────
  Future<void> insertTransactions(List<TransactionModel> txns) async {
    if (txns.isEmpty) return;
    final db = await database;
    final batch = db.batch();

    for (final txn in txns) {
      batch.insert(
        'transactions',
        txn.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<TransactionModel>> getTransactionsForAccount({
    required String accountNumber,
    String? address,
    int? limit,
  }) async {
    final db = await database;
    String whereClause;
    List<dynamic> whereArgs;

    if (accountNumber.isNotEmpty) {
      whereClause = 'accountNumber = ?';
      whereArgs = [accountNumber];
    } else if (address != null && address.isNotEmpty) {
      whereClause = 'address = ?';
      whereArgs = [address];
    } else {
      whereClause = '1 = 1';
      whereArgs = [];
    }

    final maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTodayTransactionsForAccount({
    required String accountNumber,
    String? address,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    final db = await database;
    String whereClause;
    List<dynamic> whereArgs;

    if (accountNumber.isNotEmpty) {
      whereClause = 'accountNumber = ? AND timestamp >= ? AND timestamp <= ?';
      whereArgs = [accountNumber, todayStart, todayEnd];
    } else if (address != null && address.isNotEmpty) {
      whereClause = 'address = ? AND timestamp >= ? AND timestamp <= ?';
      whereArgs = [address, todayStart, todayEnd];
    } else {
      whereClause = 'timestamp >= ? AND timestamp <= ?';
      whereArgs = [todayStart, todayEnd];
    }

    final maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp ASC',
    );

    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }
}
