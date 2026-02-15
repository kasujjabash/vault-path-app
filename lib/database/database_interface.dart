import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/budget.dart';

/// Abstract interface for database operations
/// This allows us to swap between different storage implementations
/// (SQLite for mobile, SharedPreferences for web, Firebase for sync)
abstract class DatabaseInterface {
  // Initialization
  Future<void> initialize();
  Future<void> close();

  // Account operations
  Future<List<Account>> getAccounts();
  Future<void> insertAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<Account?> getAccount(String id);

  // Category operations
  Future<List<Category>> getCategories();
  Future<void> insertCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getCategoriesByType(String type);

  // Transaction operations
  Future<List<Transaction>> getTransactions({int? limit, int? offset});
  Future<void> insertTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<Transaction>> getTransactionsByAccount(String accountId);

  // Budget operations
  Future<List<Budget>> getBudgets();
  Future<void> insertBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<List<Budget>> getActiveBudgets();

  // Analytics operations
  Future<double> getTotalBalance();
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate);
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate);
  Future<Map<String, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  );

  // Additional utility methods
  Future<void> initializeDatabase();
  Future<Transaction?> getTransaction(String id);
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);
  Future<Budget?> getBudget(String id);
  Future<List<Budget>> getBudgetsByCategory(String categoryId);
  Future<double> getCategoryExpenses(
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<Map<String, double>> getMonthlyExpenseTrends(int months);
  Future<double> getAccountBalance(String accountId);
  Future<Map<String, double>> getAccountBalances();
  Future<List<Transaction>> searchTransactions(String query);
  Future<Map<String, dynamic>> exportData();
  Future<void> importData(Map<String, dynamic> data);
  Future<void> clearAllData();
  Future<void> initializeDefaultData();
  Future<bool> isDatabaseEmpty();
}
