import 'package:flutter/foundation.dart';
import 'database_interface.dart';
import 'database_helper.dart';
import 'mock_database_helper.dart';
import '../models/account.dart';
import '../models/category.dart' as app_models;
import '../models/transaction.dart' as app_models;
import '../models/budget.dart';

/// Repository pattern implementation for data access
/// Chooses the appropriate database implementation based on platform
class DataRepository implements DatabaseInterface {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  late DatabaseInterface _database;
  bool _isInitialized = false;

  /// Initialize the repository with the appropriate database implementation
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      // Use SharedPreferences-based mock database for web
      _database = MockDatabaseHelper();
    } else {
      // Use SQLite database for mobile platforms
      _database = DatabaseHelper();
    }

    await _database.initialize();
    _isInitialized = true;
  }

  @override
  Future<void> close() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }

  // Account operations
  @override
  Future<void> initializeDatabase() async {
    await initialize();
  }

  @override
  Future<List<Account>> getAccounts() async {
    await initialize();
    return await _database.getAccounts();
  }

  @override
  Future<void> insertAccount(Account account) async {
    await initialize();
    await _database.insertAccount(account);
  }

  @override
  Future<void> updateAccount(Account account) async {
    await initialize();
    await _database.updateAccount(account);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await initialize();
    await _database.deleteAccount(id);
  }

  @override
  Future<Account?> getAccount(String id) async {
    await initialize();
    return await _database.getAccount(id);
  }

  // Category operations
  @override
  Future<List<app_models.Category>> getCategories() async {
    await initialize();
    return await _database.getCategories();
  }

  @override
  Future<void> insertCategory(app_models.Category category) async {
    await initialize();
    await _database.insertCategory(category);
  }

  @override
  Future<void> updateCategory(app_models.Category category) async {
    await initialize();
    await _database.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await initialize();
    await _database.deleteCategory(id);
  }

  @override
  Future<List<app_models.Category>> getCategoriesByType(String type) async {
    await initialize();
    return await _database.getCategoriesByType(type);
  }

  // Transaction operations
  @override
  Future<List<app_models.Transaction>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    await initialize();
    return await _database.getTransactions(limit: limit, offset: offset);
  }

  @override
  Future<void> insertTransaction(app_models.Transaction transaction) async {
    await initialize();
    await _database.insertTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(app_models.Transaction transaction) async {
    await initialize();
    await _database.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await initialize();
    await _database.deleteTransaction(id);
  }

  @override
  Future<app_models.Transaction?> getTransaction(String id) async {
    await initialize();
    return await _database.getTransaction(id);
  }

  @override
  Future<List<app_models.Transaction>> getTransactionsByAccount(
    String accountId,
  ) async {
    await initialize();
    return await _database.getTransactionsByAccount(accountId);
  }

  @override
  Future<List<app_models.Transaction>> getTransactionsByCategory(
    String categoryId,
  ) async {
    await initialize();
    return await _database.getTransactionsByCategory(categoryId);
  }

  @override
  Future<List<app_models.Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await initialize();
    return await _database.getTransactionsByDateRange(start, end);
  }

  // Budget operations
  @override
  Future<List<Budget>> getBudgets() async {
    await initialize();
    return await _database.getBudgets();
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    await initialize();
    await _database.insertBudget(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await initialize();
    await _database.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await initialize();
    await _database.deleteBudget(id);
  }

  @override
  Future<Budget?> getBudget(String id) async {
    await initialize();
    return await _database.getBudget(id);
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    await initialize();
    return await _database.getBudgetsByCategory(categoryId);
  }

  // Analytics operations
  @override
  Future<double> getCategoryExpenses(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    await initialize();
    return await _database.getCategoryExpenses(categoryId, start, end);
  }

  @override
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    await initialize();
    return await _database.getTotalIncome(start, end);
  }

  @override
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    await initialize();
    return await _database.getTotalExpenses(start, end);
  }

  @override
  Future<Map<String, double>> getMonthlyExpenseTrends(int months) async {
    await initialize();
    return await _database.getMonthlyExpenseTrends(months);
  }

  @override
  Future<double> getAccountBalance(String accountId) async {
    await initialize();
    return await _database.getAccountBalance(accountId);
  }

  @override
  Future<Map<String, double>> getAccountBalances() async {
    await initialize();
    return await _database.getAccountBalances();
  }

  // Search operations
  @override
  Future<List<app_models.Transaction>> searchTransactions(String query) async {
    await initialize();
    return await _database.searchTransactions(query);
  }

  // Backup and restore
  @override
  Future<Map<String, dynamic>> exportData() async {
    await initialize();
    return await _database.exportData();
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    await initialize();
    return await _database.importData(data);
  }

  // Clear all data
  @override
  Future<void> clearAllData() async {
    await initialize();
    return await _database.clearAllData();
  }

  @override
  Future<void> initializeDefaultData() async {
    await initialize();
    return await _database.initializeDefaultData();
  }

  @override
  Future<bool> isDatabaseEmpty() async {
    await initialize();
    return await _database.isDatabaseEmpty();
  }

  // Missing methods from interface
  @override
  Future<List<Budget>> getActiveBudgets() async {
    await initialize();
    return await _database.getActiveBudgets();
  }

  @override
  Future<double> getTotalBalance() async {
    await initialize();
    return await _database.getTotalBalance();
  }

  @override
  Future<Map<String, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await initialize();
    return await _database.getSpendingByCategory(startDate, endDate);
  }
}
