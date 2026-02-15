import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart' as models;
import '../models/budget.dart';
import 'database_interface.dart';

/// Database helper class to manage SQLite database operations
/// This class handles all CRUD operations for the expense tracker app
class DatabaseHelper implements DatabaseInterface {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  /// Singleton pattern implementation
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  /// Initialize the database (required by interface)
  @override
  Future<void> initialize() async {
    await database; // This triggers _initDatabase if not already done
  }

  /// Initialize database - alias for initialize
  @override
  Future<void> initializeDatabase() async {
    await initialize();
  }

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'budjar.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        description TEXT,
        color TEXT NOT NULL,
        icon TEXT NOT NULL,
        isPrimary INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color TEXT NOT NULL,
        icon TEXT NOT NULL,
        budgetLimit REAL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        location TEXT,
        tags TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPattern TEXT,
        transferToAccountId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id),
        FOREIGN KEY (categoryId) REFERENCES categories (id),
        FOREIGN KEY (transferToAccountId) REFERENCES accounts (id)
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0,
        period TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions(date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_account ON transactions(accountId)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions(categoryId)',
    );
    await db.execute(
      'CREATE INDEX idx_budgets_category ON budgets(categoryId)',
    );
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database migrations here when version changes
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  // ACCOUNT OPERATIONS

  /// Insert a new account
  @override
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  /// Get all accounts
  @override
  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts', orderBy: 'name ASC');
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  /// Get account by ID
  @override
  Future<Account?> getAccount(String id) async {
    final db = await database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  /// Update account
  @override
  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Delete account
  @override
  Future<int> deleteAccount(String id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // CATEGORY OPERATIONS

  /// Insert a new category
  @override
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  /// Get all categories
  @override
  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Get categories by type
  @override
  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// Update category
  @override
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete category
  @override
  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // TRANSACTION OPERATIONS

  /// Insert a new transaction
  @override
  Future<int> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Get all transactions
  @override
  Future<List<models.Transaction>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  /// Get transactions by date range
  @override
  Future<List<models.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  /// Get transactions by account
  @override
  Future<List<models.Transaction>> getTransactionsByAccount(
    String accountId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  /// Update transaction
  @override
  Future<int> updateTransaction(models.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Delete transaction
  @override
  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // BUDGET OPERATIONS

  /// Insert a new budget
  @override
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  /// Get all budgets
  @override
  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets', orderBy: 'name ASC');
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  /// Get active budgets
  @override
  Future<List<Budget>> getActiveBudgets() async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'isActive = 1',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  /// Update budget
  @override
  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Delete budget
  @override
  Future<int> deleteBudget(String id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ANALYTICS OPERATIONS

  /// Get total balance across all accounts
  @override
  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM accounts',
    );
    if (result.isEmpty) return 0.0;
    return result.first['total'] as double? ?? 0.0;
  }

  /// Get total expenses for a date range
  @override
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'expense' AND date >= ? AND date <= ?
    ''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    if (result.isEmpty) return 0.0;
    return result.first['total'] as double? ?? 0.0;
  }

  /// Get total income for a date range
  @override
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total FROM transactions 
      WHERE type = 'income' AND date >= ? AND date <= ?
    ''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    if (result.isEmpty) return 0.0;
    return result.first['total'] as double? ?? 0.0;
  }

  /// Get spending by category for a date range
  @override
  Future<Map<String, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT c.name, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.type = 'expense' AND t.date >= ? AND t.date <= ?
      GROUP BY c.id, c.name
      ORDER BY total DESC
    ''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );

    final Map<String, double> spending = {};
    for (final row in result) {
      spending[row['name'] as String] = row['total'] as double;
    }
    return spending;
  }

  /// Close database connection
  @override
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Additional utility methods
  @override
  Future<models.Transaction?> getTransaction(String id) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    if (result.isEmpty) {
      throw Exception('Transaction not found');
    }
    return models.Transaction.fromMap(result.first);
  }

  @override
  Future<List<models.Transaction>> getTransactionsByCategory(
    String categoryId,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return result.map((row) => models.Transaction.fromMap(row)).toList();
  }

  @override
  Future<Budget?> getBudget(String id) async {
    final db = await database;
    final result = await db.query('budgets', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    if (result.isEmpty) {
      throw Exception('Budget not found');
    }
    return Budget.fromMap(result.first);
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    return result.map((row) => Budget.fromMap(row)).toList();
  }

  @override
  Future<double> getCategoryExpenses(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT SUM(amount) as total FROM transactions 
         WHERE categoryId = ? AND type = 'expense' 
         AND date BETWEEN ? AND ?''',
      [categoryId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  @override
  Future<Map<String, double>> getMonthlyExpenseTrends(int months) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: months * 30));

    final result = await db.rawQuery(
      '''SELECT strftime('%Y-%m', date) as month, SUM(amount) as total 
         FROM transactions 
         WHERE type = 'expense' AND date >= ?
         GROUP BY month
         ORDER BY month''',
      [startDate.toIso8601String()],
    );

    final trends = <String, double>{};
    for (final row in result) {
      trends[row['month'] as String] = row['total'] as double;
    }
    return trends;
  }

  @override
  Future<double> getAccountBalance(String accountId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT 
         (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE accountId = ? AND type = 'income') -
         (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE accountId = ? AND type = 'expense') as balance''',
      [accountId, accountId],
    );

    return (result.first['balance'] as double?) ?? 0.0;
  }

  @override
  Future<Map<String, double>> getAccountBalances() async {
    final accounts = await getAccounts();
    final balances = <String, double>{};

    for (final account in accounts) {
      balances[account.id] = await getAccountBalance(account.id);
    }

    return balances;
  }

  @override
  Future<List<models.Transaction>> searchTransactions(String query) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );

    return result.map((row) => models.Transaction.fromMap(row)).toList();
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    return {
      'accounts': (await getAccounts()).map((a) => a.toMap()).toList(),
      'categories': (await getCategories()).map((c) => c.toMap()).toList(),
      'transactions': (await getTransactions()).map((t) => t.toMap()).toList(),
      'budgets': (await getBudgets()).map((b) => b.toMap()).toList(),
    };
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing data
      await clearAllData();

      // Import accounts
      if (data['accounts'] != null) {
        for (final item in data['accounts']) {
          await insertAccount(Account.fromMap(item));
        }
      }

      // Import categories
      if (data['categories'] != null) {
        for (final item in data['categories']) {
          await insertCategory(Category.fromMap(item));
        }
      }

      // Import transactions
      if (data['transactions'] != null) {
        for (final item in data['transactions']) {
          await insertTransaction(models.Transaction.fromMap(item));
        }
      }

      // Import budgets
      if (data['budgets'] != null) {
        for (final item in data['budgets']) {
          await insertBudget(Budget.fromMap(item));
        }
      }
    });
  }

  @override
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('categories');
      await txn.delete('accounts');
    });
  }

  @override
  Future<void> initializeDefaultData() async {
    if (await isDatabaseEmpty()) {
      // Add default categories
      await insertCategory(
        Category(
          id: '1',
          name: 'Food & Dining',
          type: 'expense',
          color: '#FF6B6B',
          icon: 'restaurant',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await insertCategory(
        Category(
          id: '2',
          name: 'Transportation',
          type: 'expense',
          color: '#4ECDC4',
          icon: 'directions_car',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await insertCategory(
        Category(
          id: '3',
          name: 'Shopping',
          type: 'expense',
          color: '#45B7D1',
          icon: 'shopping_bag',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await insertCategory(
        Category(
          id: '4',
          name: 'Salary',
          type: 'income',
          color: '#96CEB4',
          icon: 'attach_money',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Add default account
      await insertAccount(
        Account(
          id: '1',
          name: 'Cash',
          type: 'cash',
          balance: 0.0,
          color: '#6C5CE7',
          icon: 'account_balance_wallet',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<bool> isDatabaseEmpty() async {
    final accounts = await getAccounts();
    return accounts.isEmpty;
  }
}
