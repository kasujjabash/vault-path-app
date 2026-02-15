import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../models/category_spending_data.dart';
import '../../models/transaction.dart';
import '../../utils/format_utils.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CategorySpendingData> _expenseCategories = [];
  List<CategorySpendingData> _incomeCategories = [];
  double _totalExpenses = 0.0;
  double _totalIncome = 0.0;
  String _viewMode = 'transactions'; // 'transactions' or 'categories'
  String _chartType = 'pie'; // 'pie' or 'line'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    try {
      // Load expense data
      final expenseSpendingData =
          await provider.getCategorySpendingWithPercentages();
      _expenseCategories = expenseSpendingData;
      _totalExpenses = _expenseCategories.fold(
        0.0,
        (sum, cat) => sum + cat.amount,
      );

      // Load income data
      final incomeTransactions =
          provider.transactions.where((t) => t.type == 'income').toList();
      _incomeCategories = _getCategorySpendingData(
        incomeTransactions,
        provider,
      );
      _totalIncome = _incomeCategories.fold(
        0.0,
        (sum, cat) => sum + cat.amount,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  List<CategorySpendingData> _getCategorySpendingData(
    List<Transaction> transactions,
    ExpenseProvider provider,
  ) {
    if (transactions.isEmpty) return [];

    final Map<String, double> spendingByCategory = {};
    for (var transaction in transactions) {
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
      final category = provider.findCategoryById(entry.key);
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

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // App's consistent background
      appBar: AppBar(
        backgroundColor: const Color(0xFF006E1F), // App's dark green
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false, // Following app's pattern
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF006E1F),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              tabs: const [Tab(text: 'Expenses'), Tab(text: 'Income')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildExpenseTabContent(), _buildIncomeTabContent()],
      ),
    );
  }

  Widget _buildExpenseTabContent() {
    return _viewMode == 'categories' 
        ? _buildCategoryProgressView(_expenseCategories, 'expense')
        : _buildTransactionView(_expenseCategories, 'expense');
  }

  Widget _buildTransactionView(List<CategorySpendingData> categories, String type) {
    final isExpense = type == 'expense';
    final total = isExpense ? _totalExpenses : _totalIncome;
    final categoriesData = isExpense ? _expenseCategories : _incomeCategories;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Total Display with Dropdown Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExpense ? 'Total Expenses' : 'Total Income',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FormatUtils.formatCurrency(total),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : const Color(0xFF006E1F),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    // View Mode Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _viewMode,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _viewMode = value;
                            });
                          }
                        },
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        items: const [
                          DropdownMenuItem(
                            value: 'transactions',
                            child: Text('Transactions'),
                          ),
                          DropdownMenuItem(
                            value: 'categories',
                            child: Text('Categories'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Chart Type Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _chartType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _chartType = value;
                            });
                          }
                        },
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        items: const [
                          DropdownMenuItem(
                            value: 'pie',
                            child: Text('Pie Chart'),
                          ),
                          DropdownMenuItem(
                            value: 'line',
                            child: Text('Line Chart'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Chart Display
          if (categoriesData.isNotEmpty) ...[
            _chartType == 'pie' 
              ? _buildPieChart(categoriesData, type) 
              : _buildLineChart(categoriesData, type),
            const SizedBox(height: 32),

            // Category Labels - Bottom Horizontal Scroll
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesData.length,
                itemBuilder: (context, index) {
                  final data = categoriesData[index];
                  final colors = isExpense 
                    ? [
                        const Color(0xFFE57373),
                        const Color(0xFFFFB74D),
                        const Color(0xFF64B5F6),
                        const Color(0xFFAED581),
                        const Color(0xFFBA68C8),
                        const Color(0xFF4DB6AC),
                      ]
                    : [
                        const Color(0xFF006E1F),
                        const Color(0xFF4CAF50),
                        const Color(0xFF8BC34A),
                        const Color(0xFF009688),
                        const Color(0xFF00BCD4),
                        const Color(0xFF2196F3),
                      ];
                  return Container(
                    margin: const EdgeInsets.only(right: 24),
                    width: 70,
                    child: Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.categoryName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.formatCurrency(data.amount),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Content based on view mode
            _viewMode == 'transactions' 
              ? (isExpense ? _buildTransactionSection() : _buildIncomeTransactionSection())
              : _buildCategoryProgressView(categoriesData, type),
          ] else ...[
            const SizedBox(height: 100),
            Icon(
              isExpense ? Icons.pie_chart_outline : Icons.trending_up,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isExpense ? 'No expenses yet' : 'No income yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncomeTabContent() {
    return _viewMode == 'categories'
        ? _buildCategoryProgressView(_incomeCategories, 'income')
        : _buildIncomeTransactionView();
  }

  Widget _buildIncomeTransactionView() {
    return _buildTransactionView(_incomeCategories, 'income');
  }

  Widget _buildIncomeTransactionSection() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final incomeTransactions =
        provider.transactions.where((t) => t.type == 'income').toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final recentIncomeTransactions = incomeTransactions.take(5).toList();

    if (recentIncomeTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Income',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...recentIncomeTransactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            final category = provider.findCategoryById(transaction.categoryId);

            return Container(
              margin: EdgeInsets.only(
                bottom: index == recentIncomeTransactions.length - 1 ? 0 : 12,
              ),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (category?.color != null
                              ? Color(
                                int.parse(
                                  category!.color.replaceFirst('#', '0xFF'),
                                ),
                              )
                              : const Color(0xFF006E1F))
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category?.icon ?? 'trending_up'),
                      color:
                          category?.color != null
                              ? Color(
                                int.parse(
                                  category!.color.replaceFirst('#', '0xFF'),
                                ),
                              )
                              : const Color(0xFF006E1F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Transaction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              category?.name ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              FormatUtils.formatDate(transaction.date),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    '+${FormatUtils.formatCurrency(transaction.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006E1F), // Green for income
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final recentTransactions =
        provider.transactions
            .where((t) => t.type == 'expense')
            .take(3)
            .toList();

    if (recentTransactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full transactions
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006E1F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...recentTransactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            final isLast = index == recentTransactions.length - 1;
            return _buildTransactionTile(transaction, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFD32F2F,
                  ).withValues(alpha: 0.1), // App's error color with opacity
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFFD32F2F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        final category = provider.findCategoryById(transaction.categoryId);
                        return Text(
                          category?.name ?? 'Transaction',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      FormatUtils.formatDate(transaction.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- ${FormatUtils.formatCurrency(transaction.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatUtils.formatTime(transaction.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryProgressView(List<CategorySpendingData> categories, String type) {
    final total = type == 'expense' ? _totalExpenses : _totalIncome;
    final isExpense = type == 'expense';
    
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            children: [
              // Total Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      isExpense ? 'Total Expenses' : 'Total Income',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FormatUtils.formatCurrency(total),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : const Color(0xFF006E1F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Category Progress List
              if (categories.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isExpense ? 'Expense' : 'Income'} Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isLast = index == categories.length - 1;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.categoryName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${category.percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: category.percentage / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isExpense
                                                ? Colors.red.shade400
                                                : const Color(0xFF006E1F),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    FormatUtils.formatCurrency(category.amount),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isExpense
                                          ? Colors.red.shade600
                                          : const Color(0xFF006E1F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isExpense ? Icons.receipt_long : Icons.trending_up,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isExpense ? 'No expenses yet' : 'No income yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isExpense
                            ? 'Start tracking your expenses to see category breakdown'
                            : 'Start tracking your income to see category breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon data from icon name string
  IconData _getCategoryIcon(String iconName) {
    const iconMap = {
      // Expense category icons
      'restaurant': Icons.restaurant,
      'fastfood': Icons.fastfood,
      'directions_car': Icons.directions_car,
      'directions_bus': Icons.directions_bus,
      'shopping_bag': Icons.shopping_bag,
      'checkroom': Icons.checkroom,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'flight': Icons.flight,
      'spa': Icons.spa,
      'category': Icons.category,
      // Income category icons
      'handshake': Icons.handshake,
      'attach_money': Icons.attach_money,
      'work_outline': Icons.work_outline,
      'work': Icons.work,
      'savings': Icons.savings,
      'elderly': Icons.elderly,
      'trending_up': Icons.trending_up,
      'payment': Icons.payment,
      'show_chart': Icons.show_chart,
      // Account icons
      'account_balance_wallet': Icons.account_balance_wallet,
      'account_balance': Icons.account_balance,
      'credit_card': Icons.credit_card,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Widget _buildPieChart(List<CategorySpendingData> categories, String type) {
    final colors = type == 'expense' 
      ? [
          const Color(0xFF6B73FF),
          const Color(0xFF9B59B6),
          const Color(0xFFE74C3C),
          const Color(0xFFF39C12),
          const Color(0xFF2ECC71),
          const Color(0xFF1ABC9C),
        ]
      : [
          const Color(0xFF006E1F),
          const Color(0xFF4CAF50),
          const Color(0xFF8BC34A),
          const Color(0xFF009688),
          const Color(0xFF00BCD4),
          const Color(0xFF2196F3),
        ];
        
    return Center(
      child: SizedBox(
        height: 280,
        width: 280,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 80,
            sections: categories.take(6).map((data) {
              final index = categories.indexOf(data);
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: data.amount,
                title: '${data.percentage.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<CategorySpendingData> categories, String type) {
    final colors = type == 'expense' 
      ? [
          const Color(0xFF6B73FF),
          const Color(0xFF9B59B6),
          const Color(0xFFE74C3C),
          const Color(0xFFF39C12),
          const Color(0xFF2ECC71),
          const Color(0xFF1ABC9C),
        ]
      : [
          const Color(0xFF006E1F),
          const Color(0xFF4CAF50),
          const Color(0xFF8BC34A),
          const Color(0xFF009688),
          const Color(0xFF00BCD4),
          const Color(0xFF2196F3),
        ];
        
    return SizedBox(
      height: 280,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: categories.isNotEmpty 
            ? categories.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.1
            : 100,
          lineBarsData: [
            LineChartBarData(
              spots: categories.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
              isCurved: true,
              color: colors.first,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: colors.first.withOpacity(0.1),
              ),
              dotData: const FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < categories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        categories[value.toInt()].categoryName.length > 8
                          ? '${categories[value.toInt()].categoryName.substring(0, 8)}...'
                          : categories[value.toInt()].categoryName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    FormatUtils.formatCurrency(value).replaceAll(RegExp(r'\.00'), ''),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: categories.isNotEmpty 
              ? categories.map((e) => e.amount).reduce((a, b) => a > b ? a : b) / 5
              : 20,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}
