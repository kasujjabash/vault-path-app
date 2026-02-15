import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/data_repository.dart';
import '../models/account.dart';
import '../models/category.dart' as models;
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/category_spending_data.dart';

/// Main data provider for the expense tracker app
/// This class manages all data operations and notifies listeners of changes
class ExpenseProvider extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  // Data lists
  List<Account> _accounts = [];
  List<models.Category> _categories = [];
  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  List<Account> get accounts => _accounts;
  List<models.Category> get categories => _categories;
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Filtered getters
  List<models.Category> get expenseCategories =>
      _categories.where((cat) => cat.type == 'expense').toList();

  List<models.Category> get incomeCategories =>
      _categories.where((cat) => cat.type == 'income').toList();

  List<Budget> get activeBudgets =>
      _budgets.where((budget) => budget.isActive).toList();

  /// Initialize the provider with data from database
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      // Initialize repository (chooses appropriate database implementation)
      await _repository.initialize();

      // Create default categories and accounts if needed (must be first)
      await createDefaultCategoriesIfNeeded();
      await createDefaultAccountIfNeeded();

      // Load essential data first, then load secondary data
      await loadAccounts();
      await loadCategories();

      // Load transactions and budgets in background to speed up initial load
      unawaited(
        loadTransactions().catchError((e) {
          debugPrint('Error loading transactions: $e');
        }),
      );
      unawaited(
        loadBudgets().catchError((e) {
          debugPrint('Error loading budgets: $e');
        }),
      );

      _isInitialized = true;
      debugPrint('ExpenseProvider initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ExpenseProvider: $e');
      // Don't rethrow, just mark as initialized to prevent infinite loading
      _isInitialized = true;
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // ACCOUNT OPERATIONS

  /// Load accounts from database
  Future<void> loadAccounts() async {
    try {
      _accounts = await _repository.getAccounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      rethrow;
    }
  }

  /// Add new account
  Future<void> addAccount(Account account) async {
    try {
      await _repository.insertAccount(account);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error adding account: $e');
      rethrow;
    }
  }

  /// Update existing account
  Future<void> updateAccount(Account account) async {
    try {
      await _repository.updateAccount(account);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount(String accountId) async {
    try {
      await _repository.deleteAccount(accountId);
      await loadAccounts();
      await loadTransactions(); // Refresh transactions as they reference accounts
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  // CATEGORY OPERATIONS

  /// Load categories from database
  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }

  /// Add new category
  Future<void> addCategory(models.Category category) async {
    try {
      await _repository.insertCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  /// Update existing category
  Future<void> updateCategory(models.Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
      rethrow;
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _repository.deleteCategory(categoryId);
      await loadCategories();
      await loadTransactions(); // Refresh transactions as they reference categories
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  /// Create default categories if none exist
  Future<void> createDefaultCategoriesIfNeeded() async {
    try {
      final existingCategories = await _repository.getCategories();
      if (existingCategories.isNotEmpty) {
        // Clean up any miscategorized transport/clothing categories in income
        await _cleanupMiscategorizedCategories();
        return;
      }

      // Default expense categories
      final expenseCategories = [
        _createCategory('Food & Dining', 'expense', '#FF5722', 'restaurant'),
        _createCategory(
          'Transportation',
          'expense',
          '#2196F3',
          'directions_car',
        ),
        _createCategory('Shopping', 'expense', '#9C27B0', 'shopping_bag'),
        _createCategory('Entertainment', 'expense', '#FF9800', 'movie'),
        _createCategory('Bills & Utilities', 'expense', '#F44336', 'receipt'),
        _createCategory('Healthcare', 'expense', '#4CAF50', 'local_hospital'),
        _createCategory('Education', 'expense', '#607D8B', 'school'),
        _createCategory('Travel', 'expense', '#3F51B5', 'flight'),
        _createCategory('Personal Care', 'expense', '#E91E63', 'spa'),
        _createCategory('Other', 'expense', '#795548', 'category'),
      ];

      // Default income categories
      final incomeCategories = [
        _createCategory('Borrowing', 'income', '#8B4513', 'handshake'),
        _createCategory('Dividend', 'income', '#4CAF50', 'attach_money'),
        _createCategory('Freelance', 'income', '#2196F3', 'work_outline'),
        _createCategory('Passive Income', 'income', '#FF9800', 'savings'),
        _createCategory('Pension', 'income', '#9C27B0', 'elderly'),
        _createCategory('Profit', 'income', '#CDDC39', 'trending_up'),
        _createCategory('Salary', 'income', '#009688', 'payment'),
        _createCategory('Stocks', 'income', '#6A1B9A', 'show_chart'),
      ];

      // Insert all default categories
      for (final category in [...expenseCategories, ...incomeCategories]) {
        await _repository.insertCategory(category);
      }

      debugPrint('Default categories created successfully');
    } catch (e) {
      debugPrint('Error creating default categories: $e');
    }
  }

  /// Clean up any miscategorized categories and ensure proper categorization
  Future<void> _cleanupMiscategorizedCategories() async {
    try {
      final existingCategories = await _repository.getCategories();
      bool needsUpdate = false;

      // List of category names that should ONLY be expense categories
      final expenseOnlyCategories = [
        'Transport',
        'Transportation', 
        'Clothing',
        'Clothes'
      ];

      // Fix any transport/clothing categories that are incorrectly marked as income
      for (final category in existingCategories) {
        if (category.type == 'income' && 
            expenseOnlyCategories.any((name) => 
              category.name.toLowerCase().contains(name.toLowerCase()))) {
          
          // Update this category to be expense type
          final updatedCategory = models.Category(
            id: category.id,
            name: category.name,
            type: 'expense', // Fix the type
            color: category.color,
            icon: category.icon,
            isDefault: category.isDefault,
            createdAt: category.createdAt,
            updatedAt: DateTime.now(),
          );
          
          await _repository.updateCategory(updatedCategory);
          needsUpdate = true;
          debugPrint('Fixed category: ${category.name} changed from income to expense');
        }
      }

      // Add missing income categories if they don't exist
      final incomeNames = existingCategories
          .where((c) => c.type == 'income')
          .map((c) => c.name.toLowerCase())
          .toList();

      if (!incomeNames.contains('borrowing') && !incomeNames.contains('borrow')) {
        await _repository.insertCategory(
          _createCategory('Borrowing', 'income', '#8B4513', 'handshake')
        );
        needsUpdate = true;
      }

      if (!incomeNames.contains('stocks') && !incomeNames.contains('stock')) {
        await _repository.insertCategory(
          _createCategory('Stocks', 'income', '#6A1B9A', 'show_chart')
        );
        needsUpdate = true;
      }

      if (needsUpdate) {
        final categories = await _repository.getCategories();
        _categories = categories;
        notifyListeners();
        debugPrint('Categories cleaned up and updated successfully');
      }

    } catch (e) {
      debugPrint('Error cleaning up categories: $e');
    }
  }

  /// Helper to create a category
  models.Category _createCategory(
    String name,
    String type,
    String color,
    String icon,
  ) {
    final now = DateTime.now();
    return models.Category(
      id:
          '${DateTime.now().millisecondsSinceEpoch}_${name.replaceAll(' ', '_').toLowerCase()}',
      name: name,
      type: type,
      color: color,
      icon: icon,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create default account if none exist
  Future<void> createDefaultAccountIfNeeded() async {
    try {
      final existingAccounts = await _repository.getAccounts();
      if (existingAccounts.isNotEmpty) return;

      // Create default main account
      final defaultAccount = Account(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Main Account',
        type: 'cash',
        balance: 0.0,
        color: '#006E1F',
        icon: 'account_balance_wallet',
        isPrimary: true,
        description: 'Your primary account for tracking expenses',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.insertAccount(defaultAccount);
      debugPrint('Default account created successfully');
    } catch (e) {
      debugPrint('Error creating default account: $e');
    }
  }

  // TRANSACTION OPERATIONS

  /// Load transactions from database
  Future<void> loadTransactions() async {
    try {
      _transactions = await _repository.getTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow;
    }
  }

  /// Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.insertTransaction(transaction);

      // Update account balance
      await _updateAccountBalance(transaction);

      // Update budget if it's an expense
      if (transaction.type == 'expense') {
        await _updateBudgetSpending(transaction.categoryId, transaction.amount);
      }

      await loadTransactions();
      await loadAccounts();
      await loadBudgets();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  /// Update existing transaction
  Future<void> updateTransaction(
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    try {
      await _repository.updateTransaction(newTransaction);

      // Reverse old transaction effect on account balance
      await _reverseAccountBalance(oldTransaction);

      // Apply new transaction effect on account balance
      await _updateAccountBalance(newTransaction);

      // Update budget spending
      if (oldTransaction.type == 'expense') {
        await _updateBudgetSpending(
          oldTransaction.categoryId,
          -oldTransaction.amount,
        );
      }
      if (newTransaction.type == 'expense') {
        await _updateBudgetSpending(
          newTransaction.categoryId,
          newTransaction.amount,
        );
      }

      await loadTransactions();
      await loadAccounts();
      await loadBudgets();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      await _repository.deleteTransaction(transaction.id);

      // Reverse transaction effect on account balance
      await _reverseAccountBalance(transaction);

      // Update budget if it was an expense
      if (transaction.type == 'expense') {
        await _updateBudgetSpending(
          transaction.categoryId,
          -transaction.amount,
        );
      }

      await loadTransactions();
      await loadAccounts();
      await loadBudgets();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  /// Update account balance after transaction
  Future<void> _updateAccountBalance(Transaction transaction) async {
    try {
      final accountIndex = _accounts.indexWhere(
        (acc) => acc.id == transaction.accountId,
      );
      if (accountIndex == -1) {
        debugPrint(
          'Account not found for transaction: ${transaction.accountId}',
        );
        return; // Silently return instead of throwing error
      }

      final account = _accounts[accountIndex];
      double newBalance = account.balance;

      if (transaction.type == 'income') {
        newBalance += transaction.amount;
      } else if (transaction.type == 'expense') {
        newBalance -= transaction.amount;
      }

      final updatedAccount = account.copyWith(balance: newBalance);
      await _repository.updateAccount(updatedAccount);
    } catch (e) {
      debugPrint('Error updating account balance: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  /// Reverse account balance changes from a transaction
  Future<void> _reverseAccountBalance(Transaction transaction) async {
    try {
      final accountIndex = _accounts.indexWhere(
        (acc) => acc.id == transaction.accountId,
      );
      if (accountIndex == -1) {
        debugPrint(
          'Account not found for transaction reversal: ${transaction.accountId}',
        );
        return; // Silently return instead of throwing error
      }

      final account = _accounts[accountIndex];
      double newBalance = account.balance;

      if (transaction.type == 'income') {
        newBalance -= transaction.amount;
      } else if (transaction.type == 'expense') {
        newBalance += transaction.amount;
      }

      final updatedAccount = account.copyWith(balance: newBalance);
      await _repository.updateAccount(updatedAccount);
    } catch (e) {
      debugPrint('Error reversing account balance: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  // BUDGET OPERATIONS

  /// Load budgets from database
  Future<void> loadBudgets() async {
    try {
      _budgets = await _repository.getBudgets();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      rethrow;
    }
  }

  /// Add new budget
  Future<void> addBudget(Budget budget) async {
    try {
      await _repository.insertBudget(budget);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error adding budget: $e');
      rethrow;
    }
  }

  /// Update existing budget
  Future<void> updateBudget(Budget budget) async {
    try {
      await _repository.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  /// Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _repository.deleteBudget(budgetId);
      await loadBudgets();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  /// Update budget spending amount
  Future<void> _updateBudgetSpending(String categoryId, double amount) async {
    final budget =
        _budgets
            .where((b) => b.categoryId == categoryId && b.isActive)
            .firstOrNull;
    if (budget != null) {
      final updatedBudget = budget.copyWith(spent: budget.spent + amount);
      await _repository.updateBudget(updatedBudget);
    }
  }

  // ANALYTICS METHODS

  /// Get total balance across all accounts
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  /// Get total expenses for current month
  Future<double> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await _repository.getTotalExpenses(startOfMonth, endOfMonth);
  }

  /// Get total income for current month
  Future<double> getCurrentMonthIncome() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await _repository.getTotalIncome(startOfMonth, endOfMonth);
  }

  /// Get spending by category for current month
  Future<Map<String, double>> getCurrentMonthSpendingByCategory() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await _repository.getSpendingByCategory(startOfMonth, endOfMonth);
  }

  /// Get category spending data with colors and percentages for donut chart
  Future<List<CategorySpendingData>>
  getCategorySpendingWithPercentages() async {
    try {
      // Get all expense transactions, not just current month
      final expenseTransactions =
          _transactions.where((t) => t.type == 'expense').toList();

      if (expenseTransactions.isEmpty) {
        return [];
      }

      // Group by category and calculate totals
      final Map<String, double> spendingByCategory = {};
      for (var transaction in expenseTransactions) {
        final categoryId = transaction.categoryId;
        spendingByCategory[categoryId] =
            (spendingByCategory[categoryId] ?? 0.0) + transaction.amount;
      }

      final totalSpending = spendingByCategory.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );

      if (totalSpending == 0) return [];

      List<CategorySpendingData> result = [];

      for (var entry in spendingByCategory.entries) {
        final category = findCategoryById(entry.key);
        if (category != null) {
          final percentage = (entry.value / totalSpending) * 100;
          result.add(
            CategorySpendingData(
              categoryId: category.id,
              categoryName: category.name,
              amount: entry.value,
              percentage: percentage,
              color: category.color,
            ),
          );
        }
      }

      // Sort by amount descending
      result.sort((a, b) => b.amount.compareTo(a.amount));
      return result;
    } catch (e, stackTrace) {
      debugPrint('Error getting category spending with percentages: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Delete transaction with UI feedback
  Future<bool> deleteTransactionWithFeedback(Transaction transaction) async {
    try {
      await deleteTransaction(transaction);
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  /// Find account by ID
  Account? findAccountById(String id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find category by ID
  models.Category? findCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all data for testing
  Future<void> clearAllData() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear all data from repository
      final allTransactions = await _repository.getTransactions();
      for (final transaction in allTransactions) {
        await _repository.deleteTransaction(transaction.id);
      }

      final allBudgets = await _repository.getBudgets();
      for (final budget in allBudgets) {
        await _repository.deleteBudget(budget.id);
      }

      final nonDefaultCategories =
          _categories.where((c) => !c.isDefault).toList();
      for (final category in nonDefaultCategories) {
        await _repository.deleteCategory(category.id);
      }

      final allAccounts = await _repository.getAccounts();
      for (final account in allAccounts) {
        // Reset balance instead of deleting accounts
        final resetAccount = account.copyWith(balance: 0.0);
        await _repository.updateAccount(resetAccount);
      }

      // Reload all data
      await loadAccounts();
      await loadCategories();
      await loadTransactions();
      await loadBudgets();

      debugPrint('All data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}
