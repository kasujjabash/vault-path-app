import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../components/banner_ad_widget.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Financial Report Carousel Screen with personalized insights
class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Money quotes for the final screen
  final List<String> _moneyQuotes = [
    "A penny saved is a penny earned.",
    "It's not how much money you make, but how much you save.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Don't save what is left after spending, but spend what is left after saving.",
    "The real measure of your wealth is how much you'd be worth if you lost all your money.",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide status bar for true full screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Main PageView
              PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildIncomeScreen(provider),
                  _buildExpenseScreen(provider),
                  _buildBudgetScreen(provider),
                  _buildFinalScreen(),
                ],
              ),

              // Close button (X) - positioned for full screen
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    // Restore status bar when closing
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Page indicator dots
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Swipe indicator
              if (_currentPage < 3)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Swipe for more insights',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build income insights screen
  Widget _buildIncomeScreen(ExpenseProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getIncomeInsights(provider),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final monthlyIncome = data['monthlyIncome'] ?? 0.0;
        final biggestIncomeSource = data['biggestIncomeSource'] ?? 'Unknown';
        final biggestIncomeAmount = data['biggestIncomeAmount'] ?? 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, size: 80, color: Colors.white),

                const SizedBox(height: 40),

                const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'You Earned',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  FormatUtils.formatCurrency(monthlyIncome),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                if (biggestIncomeSource != 'Unknown') ...[
                  Text(
                    'Your biggest income is from',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '$biggestIncomeSource • ${FormatUtils.formatCurrency(biggestIncomeAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Add more income transactions to see insights',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build expense insights screen
  Widget _buildExpenseScreen(ExpenseProvider provider) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getExpenseInsights(provider),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final monthlyExpenses = data['monthlyExpenses'] ?? 0.0;
        final biggestExpenseCategory =
            data['biggestExpenseCategory'] ?? 'Unknown';
        final biggestExpenseAmount = data['biggestExpenseAmount'] ?? 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF5722), Color(0xFFD84315)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_down, size: 80, color: Colors.white),

                const SizedBox(height: 40),

                const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'You Spent',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  FormatUtils.formatCurrency(monthlyExpenses),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                if (biggestExpenseCategory != 'Unknown') ...[
                  Text(
                    'Your biggest spending is from',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '$biggestExpenseCategory • ${FormatUtils.formatCurrency(biggestExpenseAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Add more expense transactions to see insights',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build budget insights screen
  Widget _buildBudgetScreen(ExpenseProvider provider) {
    final activeBudgets = provider.activeBudgets;
    final exceededBudgets =
        activeBudgets.where((budget) => budget.isExceeded).length;
    final totalBudgets = activeBudgets.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              exceededBudgets > 0
                  ? Icons.warning_rounded
                  : Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),

            const SizedBox(height: 40),

            const Text(
              'Budget Status',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            if (totalBudgets == 0) ...[
              const Text(
                'No Active Budgets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Create a budget to start tracking your spending goals',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                '$exceededBudgets of $totalBudgets',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                exceededBudgets == 0
                    ? 'Budgets are on track! 🎉'
                    : exceededBudgets == 1
                    ? 'Budget exceeded'
                    : 'Budgets exceeded',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (exceededBudgets > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    exceededBudgets == 1
                        ? 'Review your spending habits'
                        : 'Consider adjusting your budgets',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Great job staying within budget!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 30),

            // Banner Ad
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  /// Build final screen with money quote
  Widget _buildFinalScreen() {
    final randomQuote = (_moneyQuotes..shuffle()).first;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006E1F), Color(0xFF004D16)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.format_quote, size: 80, color: Colors.white),

            const SizedBox(height: 40),

            Text(
              randomQuote,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () {
                // Restore status bar when closing
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                Navigator.of(context).pop();
                context.go('/analytics'); // Navigate to detailed reports
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006E1F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See More Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get income insights data
  Future<Map<String, dynamic>> _getIncomeInsights(
    ExpenseProvider provider,
  ) async {
    final monthlyIncome = await provider.getCurrentMonthIncome();
    final incomeTransactions =
        provider.transactions
            .where((t) => t.type == 'income')
            .where((t) => _isCurrentMonth(t.date))
            .toList();

    String biggestIncomeSource = 'Unknown';
    double biggestIncomeAmount = 0.0;

    if (incomeTransactions.isNotEmpty) {
      // Group by category and sum amounts
      final categoryTotals = <String, double>{};
      for (final transaction in incomeTransactions) {
        final category = provider.findCategoryById(transaction.categoryId);
        final categoryName = category?.name ?? 'Other';
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
      }

      // Find biggest category
      if (categoryTotals.isNotEmpty) {
        final biggest = categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        biggestIncomeSource = biggest.key;
        biggestIncomeAmount = biggest.value;
      }
    }

    return {
      'monthlyIncome': monthlyIncome,
      'biggestIncomeSource': biggestIncomeSource,
      'biggestIncomeAmount': biggestIncomeAmount,
    };
  }

  /// Get expense insights data
  Future<Map<String, dynamic>> _getExpenseInsights(
    ExpenseProvider provider,
  ) async {
    final monthlyExpenses = await provider.getCurrentMonthExpenses();
    final expenseTransactions =
        provider.transactions
            .where((t) => t.type == 'expense')
            .where((t) => _isCurrentMonth(t.date))
            .toList();

    String biggestExpenseCategory = 'Unknown';
    double biggestExpenseAmount = 0.0;

    if (expenseTransactions.isNotEmpty) {
      // Group by category and sum amounts
      final categoryTotals = <String, double>{};
      for (final transaction in expenseTransactions) {
        final category = provider.findCategoryById(transaction.categoryId);
        final categoryName = category?.name ?? 'Other';
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
      }

      // Find biggest category
      if (categoryTotals.isNotEmpty) {
        final biggest = categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        biggestExpenseCategory = biggest.key;
        biggestExpenseAmount = biggest.value;
      }
    }

    return {
      'monthlyExpenses': monthlyExpenses,
      'biggestExpenseCategory': biggestExpenseCategory,
      'biggestExpenseAmount': biggestExpenseAmount,
    };
  }

  /// Check if date is in current month
  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}
