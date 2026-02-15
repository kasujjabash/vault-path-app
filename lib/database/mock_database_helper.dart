import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/category.dart' as models;
import '../models/transaction.dart' as trans;
import '../models/budget.dart';
import 'database_interface.dart';

/// Mock database helper for web development
/// This class provides in-memory storage for web platform
class MockDatabaseHelper implements DatabaseInterface {
  static final MockDatabaseHelper _instance = MockDatabaseHelper._internal();

  /// Singleton pattern implementation
  factory MockDatabaseHelper() => _instance;
  MockDatabaseHelper._internal();

  // In-memory storage
  final List<Account> _accounts = [];
  final List<models.Category> _categories = [];
  final List<trans.Transaction> _transactions = [];
  final List<Budget> _budgets = [];

  /// Initialize with default data
  @override
  Future<void> initialize() async {
    if (_accounts.isNotEmpty || _categories.isNotEmpty) {
      return; // Already initialized
    }

    // Load data from local storage first
    await _loadFromLocalStorage();

    // If no data exists, initialize with minimal default categories
    if (_categories.isEmpty) {
      _initializeDefaultCategories();
    }
  }

  /// Initialize database - alias for initialize
  @override
  Future<void> initializeDatabase() async {
    await initialize();
  }

  /// Initialize default categories for better user experience
  void _initializeDefaultCategories() {
    final defaultCategories = [
      // Expense categories
      models.Category(
        id: 'cat_food',
        name: 'Food & Dining',
        type: 'expense',
        color: '#FF5722',
        icon: 'restaurant',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      models.Category(
        id: 'cat_transport',
        name: 'Transportation',
        type: 'expense',
        color: '#2196F3',
        icon: 'directions_car',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      models.Category(
        id: 'cat_shopping',
        name: 'Shopping',
        type: 'expense',
        color: '#9C27B0',
        icon: 'shopping_bag',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      models.Category(
        id: 'cat_utilities',
        name: 'Utilities',
        type: 'expense',
        color: '#FF9800',
        icon: 'electrical_services',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // Income categories
      models.Category(
        id: 'cat_salary',
        name: 'Salary',
        type: 'income',
        color: '#4CAF50',
        icon: 'work',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      models.Category(
        id: 'cat_freelance',
        name: 'Freelance',
        type: 'income',
        color: '#00BCD4',
        icon: 'computer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _categories.addAll(defaultCategories);
  }

  /// Save data to SharedPreferences for persistence
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save accounts
      final accountsJson = jsonEncode(
        _accounts.map((account) => account.toMap()).toList(),
      );
      await prefs.setString('budjar_accounts', accountsJson);

      // Save categories
      final categoriesJson = jsonEncode(
        _categories.map((category) => category.toMap()).toList(),
      );
      await prefs.setString('budjar_categories', categoriesJson);

      // Save transactions
      final transactionsJson = jsonEncode(
        _transactions.map((transaction) => transaction.toMap()).toList(),
      );
      await prefs.setString('budjar_transactions', transactionsJson);

      // Save budgets
      final budgetsJson = jsonEncode(
        _budgets.map((budget) => budget.toMap()).toList(),
      );
      await prefs.setString('budjar_budgets', budgetsJson);
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  /// Load data from SharedPreferences on app startup
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load accounts
      final accountsJson = prefs.getString('budjar_accounts');
      if (accountsJson != null) {
        final accountsList = jsonDecode(accountsJson) as List;
        _accounts.clear();
        _accounts.addAll(
          accountsList.map((json) => Account.fromMap(json)).toList(),
        );
      }

      // Load categories
      final categoriesJson = prefs.getString('budjar_categories');
      if (categoriesJson != null) {
        final categoriesList = jsonDecode(categoriesJson) as List;
        _categories.clear();
        _categories.addAll(
          categoriesList.map((json) => models.Category.fromMap(json)).toList(),
        );
      }

      // Load transactions
      final transactionsJson = prefs.getString('budjar_transactions');
      if (transactionsJson != null) {
        final transactionsList = jsonDecode(transactionsJson) as List;
        _transactions.clear();
        _transactions.addAll(
          transactionsList
              .map((json) => trans.Transaction.fromMap(json))
              .toList(),
        );
      }

      // Load budgets
      final budgetsJson = prefs.getString('budjar_budgets');
      if (budgetsJson != null) {
        final budgetsList = jsonDecode(budgetsJson) as List;
        _budgets.clear();
        _budgets.addAll(
          budgetsList.map((json) => Budget.fromMap(json)).toList(),
        );
      }

      print('Data loaded from local storage successfully');
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  // Account operations
  @override
  Future<List<Account>> getAccounts() async {
    await initialize();
    return List.from(_accounts);
  }

  @override
  Future<void> insertAccount(Account account) async {
    _accounts.add(account);
    await _saveToLocalStorage();
  }

  @override
  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveToLocalStorage();
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await _saveToLocalStorage();
  }

  @override
  Future<Account?> getAccount(String id) async {
    await initialize();
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Category operations
  @override
  Future<List<models.Category>> getCategories() async {
    await initialize();
    return List.from(_categories);
  }

  @override
  Future<void> insertCategory(models.Category category) async {
    _categories.add(category);
    await _saveToLocalStorage();
  }

  @override
  Future<void> updateCategory(models.Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await _saveToLocalStorage();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _saveToLocalStorage();
  }

  @override
  Future<List<models.Category>> getCategoriesByType(String type) async {
    await initialize();
    return _categories.where((cat) => cat.type == type).toList();
  }

  // Transaction operations
  @override
  Future<List<trans.Transaction>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    await initialize();
    var result = List<trans.Transaction>.from(_transactions);
    result.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    if (offset != null) {
      result = result.skip(offset).toList();
    }
    if (limit != null) {
      result = result.take(limit).toList();
    }

    return result;
  }

  @override
  Future<void> insertTransaction(trans.Transaction transaction) async {
    _transactions.add(transaction);
    await _saveToLocalStorage();
  }

  @override
  Future<void> updateTransaction(trans.Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveToLocalStorage();
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveToLocalStorage();
  }

  @override
  Future<List<trans.Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await initialize();
    return _transactions
        .where(
          (t) =>
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  @override
  Future<List<trans.Transaction>> getTransactionsByAccount(
    String accountId,
  ) async {
    await initialize();
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  // Budget operations
  @override
  Future<List<Budget>> getBudgets() async {
    await initialize();
    return List.from(_budgets);
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    _budgets.add(budget);
    await _saveToLocalStorage();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      await _saveToLocalStorage();
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveToLocalStorage();
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    await initialize();
    return _budgets.where((budget) => budget.isActive).toList();
  }

  // Analytics operations
  Future<Map<String, double>> getExpensesByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await initialize();
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type == 'expense') {
        final category = _categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse:
              () => models.Category(
                id: 'unknown',
                name: 'Unknown',
                type: 'expense',
                color: '#999999',
                icon: 'category',
                isDefault: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );
        result[category.name] =
            (result[category.name] ?? 0) + transaction.amount;
      }
    }

    return result;
  }

  @override
  Future<double> getTotalBalance() async {
    await initialize();
    return _accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  Future<double> getCurrentMonthExpenses() async {
    await initialize();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))),
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getCurrentMonthIncome() async {
    await initialize();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))),
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<List<trans.Transaction>> getRecentTransactions({
    int limit = 10,
  }) async {
    await initialize();
    final sorted = List<trans.Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  // Additional methods required by ExpenseProvider
  @override
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    await initialize();
    return _transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    await initialize();
    return _transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<Map<String, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await initialize();
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type == 'expense' &&
          transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)))) {
        final category = _categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse:
              () => models.Category(
                id: 'unknown',
                name: 'Unknown',
                type: 'expense',
                color: '#999999',
                icon: 'category',
                isDefault: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );
        result[category.name] =
            (result[category.name] ?? 0) + transaction.amount;
      }
    }

    return result;
  }

  /// Close method for compatibility with DatabaseHelper
  @override
  Future<void> close() async {
    // Mock database doesn't need to close anything
  }

  // Additional utility methods
  @override
  Future<trans.Transaction?> getTransaction(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<trans.Transaction>> getTransactionsByCategory(
    String categoryId,
  ) async {
    return _transactions.where((t) => t.categoryId == categoryId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Budget?> getBudget(String id) async {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    return _budgets.where((b) => b.categoryId == categoryId).toList();
  }

  @override
  Future<double> getCategoryExpenses(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final total = _transactions
        .where(
          (t) =>
              t.categoryId == categoryId &&
              t.type == 'expense' &&
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .fold<double>(0.0, (double sum, trans.Transaction t) => sum + t.amount);
    return total;
  }

  @override
  Future<Map<String, double>> getMonthlyExpenseTrends(int months) async {
    final startDate = DateTime.now().subtract(Duration(days: months * 30));
    final trends = <String, double>{};

    final expenseTransactions =
        _transactions
            .where((t) => t.type == 'expense' && t.date.isAfter(startDate))
            .toList();

    for (final transaction in expenseTransactions) {
      final monthKey =
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      trends[monthKey] = (trends[monthKey] ?? 0) + transaction.amount;
    }

    return trends;
  }

  @override
  Future<double> getAccountBalance(String accountId) async {
    final incomeTotal = _transactions
        .where((t) => t.accountId == accountId && t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenseTotal = _transactions
        .where((t) => t.accountId == accountId && t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    return incomeTotal - expenseTotal;
  }

  @override
  Future<Map<String, double>> getAccountBalances() async {
    final balances = <String, double>{};

    for (final account in _accounts) {
      final balance = await getAccountBalance(account.id);
      balances[account.id] = balance;
    }

    return balances;
  }

  @override
  Future<List<trans.Transaction>> searchTransactions(String query) async {
    final lowerQuery = query.toLowerCase();
    return _transactions
        .where(
          (t) =>
              t.title.toLowerCase().contains(lowerQuery) ||
              (t.description?.toLowerCase().contains(lowerQuery) ?? false),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Map<String, dynamic>> exportData() async {
    return {
      'accounts': _accounts.map((a) => a.toMap()).toList(),
      'categories': _categories.map((c) => c.toMap()).toList(),
      'transactions': _transactions.map((t) => t.toMap()).toList(),
      'budgets': _budgets.map((b) => b.toMap()).toList(),
    };
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
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
        await insertCategory(models.Category.fromMap(item));
      }
    }

    // Import transactions
    if (data['transactions'] != null) {
      for (final item in data['transactions']) {
        await insertTransaction(trans.Transaction.fromMap(item));
      }
    }

    // Import budgets
    if (data['budgets'] != null) {
      for (final item in data['budgets']) {
        await insertBudget(Budget.fromMap(item));
      }
    }

    await _saveToLocalStorage();
  }

  @override
  Future<void> clearAllData() async {
    _accounts.clear();
    _categories.clear();
    _transactions.clear();
    _budgets.clear();
    await _saveToLocalStorage();
  }

  @override
  Future<void> initializeDefaultData() async {
    if (await isDatabaseEmpty()) {
      _initializeDefaultCategories();

      // Add default account
      await insertAccount(
        Account(
          id: 'acc_cash',
          name: 'Cash',
          type: 'cash',
          balance: 0.0,
          color: '#6C5CE7',
          icon: 'account_balance_wallet',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await _saveToLocalStorage();
    }
  }

  @override
  Future<bool> isDatabaseEmpty() async {
    return _accounts.isEmpty &&
        _categories.isEmpty &&
        _transactions.isEmpty &&
        _budgets.isEmpty;
  }
}
