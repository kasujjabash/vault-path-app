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
  String _viewMode = 'Transactions';
  String _chartType = 'pie';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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
      _incomeCategories = _getIncomeSpendingWithPercentages(incomeTransactions);
      _totalIncome = _incomeCategories.fold(
        0.0,
        (sum, cat) => sum + cat.amount,
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    }
  }

  List<CategorySpendingData> _getIncomeSpendingWithPercentages(
    List<Transaction> transactions,
  ) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final Map<String, double> spendingByCategory = {};

    for (final transaction in transactions) {
      spendingByCategory[transaction.categoryId] =
          (spendingByCategory[transaction.categoryId] ?? 0) +
          transaction.amount;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF006E1F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildAmountAndChartControls(),
            _buildChartSection(),
            _buildTabSection(),
            _viewMode == 'Categories'
                ? _buildCategoriesList()
                : _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  // Header Section with Dropdown
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
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
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              items: const [
                DropdownMenuItem(
                  value: 'Transactions',
                  child: Text('Transactions'),
                ),
                DropdownMenuItem(
                  value: 'Categories',
                  child: Text('Categories'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Amount Display with Chart Controls
  Widget _buildAmountAndChartControls() {
    final total = _tabController.index == 0 ? _totalExpenses : _totalIncome;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            FormatUtils.formatCurrency(total),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Row(
            children: [
              _buildChartToggle(Icons.trending_up, 'line'),
              const SizedBox(width: 8),
              _buildChartToggle(Icons.bar_chart, 'bar'),
              const SizedBox(width: 8),
              _buildChartToggle(Icons.pie_chart, 'pie'),
            ],
          ),
        ],
      ),
    );
  }

  // Chart Section
  Widget _buildChartSection() {
    final categoriesData =
        _tabController.index == 0 ? _expenseCategories : _incomeCategories;
    final type = _tabController.index == 0 ? 'expense' : 'income';

    if (categoriesData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'expense' ? 'expenses' : 'income'} data available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (_chartType == 'pie')
            _buildPieChart(categoriesData, type)
          else if (_chartType == 'line')
            _buildLineChart(categoriesData, type)
          else
            _buildBarChart(categoriesData, type),
        ],
      ),
    );
  }

  // Tab Section (between chart and transactions)
  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _tabController.index == 0
                          ? const Color(0xFF006E1F)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _tabController.index == 0 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _tabController.index == 1
                          ? const Color(0xFF006E1F)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Income',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _tabController.index == 1 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Transactions List
  Widget _buildTransactionsList() {
    final type = _tabController.index == 0 ? 'expense' : 'income';
    final transactions = _getRecentTransactions(type);
    final typeDisplayName = type == 'expense' ? 'Expense' : 'Income';

    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No recent $typeDisplayName transactions',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header indicating what type of transactions are shown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$typeDisplayName Transactions (${transactions.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        // Transaction list
        ...transactions.map((transaction) {
          final provider = Provider.of<ExpenseProvider>(context, listen: false);
          final category = provider.findCategoryById(transaction.categoryId);

          return Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
                            : Colors.pink)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon ?? 'shopping_bag'),
                    color:
                        category?.color != null
                            ? Color(
                              int.parse(
                                category!.color.replaceFirst('#', '0xFF'),
                              ),
                            )
                            : Colors.pink,
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
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.formatDate(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  '${type == 'expense' ? '-' : '+'} ${FormatUtils.formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        type == 'expense'
                            ? Colors.red
                            : const Color(0xFF006E1F),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Get Recent Transactions
  List<Transaction> _getRecentTransactions(String type) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    // Always filter by the current tab type (expense or income)
    return provider.transactions.where((t) => t.type == type).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Categories List with Progress Bars
  Widget _buildCategoriesList() {
    final categoriesData =
        _tabController.index == 0 ? _expenseCategories : _incomeCategories;
    final typeDisplayName = _tabController.index == 0 ? 'Expense' : 'Income';

    if (categoriesData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No $typeDisplayName data available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header indicating what type of categories are shown
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '$typeDisplayName Categories (${categoriesData.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Categories list
          ...categoriesData.map((category) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Category name, icon, and amount
                  Row(
                    children: [
                      // Category icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(category.color.replaceFirst('#', '0xFF')),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(category.categoryName.toLowerCase()),
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category name
                      Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      // Amount in red
                      Text(
                        FormatUtils.formatCurrency(category.amount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar and percentage
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: category.percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(
                                    category.color.replaceFirst('#', '0xFF'),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
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
    );
  }

  // Chart Toggle Buttons
  Widget _buildChartToggle(IconData icon, String type) {
    final isSelected = _chartType == type;
    return GestureDetector(
      onTap: () => setState(() => _chartType = type),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006E1F) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  // Chart Building Methods
  Widget _buildPieChart(List<CategorySpendingData> categories, String type) {
    final colors = [
      const Color(0xFF006E1F), // Primary green
      const Color(0xFFFF6B35), // Orange/Red
      const Color(0xFF4169E1), // Blue
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF059669), // Teal
      const Color(0xFFB8860B), // Brown
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 220,
            width: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (
                    FlTouchEvent event,
                    PieTouchResponse? pieTouchResponse,
                  ) {
                    // Handle touch interaction
                  },
                ),
                sections:
                    categories.take(8).map((data) {
                      final index = categories.indexOf(data);

                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: data.amount,
                        title: '', // No percentage
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        titlePositionPercentageOffset: 0.7,
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Category Legend - Scrollable
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((data) {
                      final index = categories.indexOf(data);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 70,
                              child: Text(
                                data.categoryName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              FormatUtils.formatCurrencyCompact(data.amount),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<CategorySpendingData> categories, String type) {
    final colors = [
      const Color(0xFF006E1F),
      const Color(0xFFFF6B35),
      const Color(0xFF4169E1),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFB8860B),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];

    // Get max value for better scaling
    final maxValue =
        categories.isNotEmpty
            ? categories.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
            : 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex < categories.length) {
                    final category = categories[groupIndex];
                    return BarTooltipItem(
                      '${category.categoryName}\n${FormatUtils.formatCurrency(category.amount)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < categories.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          categories[index].categoryName.length > 6
                              ? '${categories[index].categoryName.substring(0, 6)}...'
                              : categories[index].categoryName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 35,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: maxValue / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      FormatUtils.formatCurrencyCompact(value),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
              drawVerticalLine: false,
              horizontalInterval: maxValue / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                left: BorderSide(color: Colors.grey.withOpacity(0.3)),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            barGroups:
                categories.take(8).map((data) {
                  final index = categories.indexOf(data);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.amount,
                        color: colors[index % colors.length],
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<CategorySpendingData> categories, String type) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    // Get last 30 days of data with proper time-based analysis
    Map<DateTime, double> dailyTotals = {};

    // Initialize all days with 0
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      dailyTotals[dateKey] = 0.0;
    }

    // Accumulate transactions by day
    final transactions = provider.transactions.where((t) => t.type == type);

    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      // Only include transactions from the last 30 days
      final daysDiff = DateTime.now().difference(transactionDate).inDays;
      if (daysDiff >= 0 && daysDiff < 30) {
        dailyTotals[transactionDate] =
            (dailyTotals[transactionDate] ?? 0) + transaction.amount;
      }
    }

    // Convert to FlSpot list with proper ordering
    List<FlSpot> spots = [];
    final sortedDates = dailyTotals.keys.toList()..sort();

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final amount = dailyTotals[date] ?? 0;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    // Calculate max value for proper scaling
    double maxY =
        spots.isEmpty
            ? 100
            : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 100;

    // Color based on transaction type
    final lineColor = type == 'expense' ? Colors.red : const Color(0xFF006E1F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: maxY / 4,
              verticalInterval: 7,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 7, // Show every 7 days
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < sortedDates.length) {
                      final date = sortedDates[value.toInt()];
                      final day = date.day;
                      final month = date.month;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '$day/$month',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
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
                  interval: maxY / 4,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        FormatUtils.formatCurrencyCompact(value),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: lineColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: lineColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: lineColor.withOpacity(0.1),
                ),
              ),
            ],
            minX: 0,
            maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 29,
            minY: 0,
            maxY: maxY * 1.2,
            // Add touch interaction
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    if (flSpot.x.toInt() < sortedDates.length) {
                      final date = sortedDates[flSpot.x.toInt()];
                      final amount = flSpot.y;
                      return LineTooltipItem(
                        '${FormatUtils.formatDate(date)}\n${FormatUtils.formatCurrency(amount)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'electronics': Icons.computer,
      'drinks': Icons.local_drink,
      'travel': Icons.flight,
      'rent': Icons.home,
      'water bill': Icons.water_drop,
      'coffee': Icons.coffee,
      'cloths': Icons.shopping_bag,
      'food': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'local_gas_station': Icons.local_gas_station,
      'home': Icons.home,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'movie': Icons.movie,
      'fitness_center': Icons.fitness_center,
      'shopping_bag': Icons.shopping_bag,
      'directions_car': Icons.directions_car,
      'flight': Icons.flight,
      'phone': Icons.phone,
      'electric_bolt': Icons.electric_bolt,
      'pets': Icons.pets,
      'checkroom': Icons.checkroom,
      'savings': Icons.savings,
      'trending_up': Icons.trending_up,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.category;
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF006E1F)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterDataByDate();
    }
  }

  void _filterDataByDate() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    // Filter transactions by selected date
    final filteredExpenses =
        provider.transactions
            .where(
              (t) => t.type == 'expense' && _isSameDate(t.date, _selectedDate),
            )
            .toList();

    final filteredIncome =
        provider.transactions
            .where(
              (t) => t.type == 'income' && _isSameDate(t.date, _selectedDate),
            )
            .toList();

    // Update categories with filtered data
    _expenseCategories = _getIncomeSpendingWithPercentages(filteredExpenses);
    _incomeCategories = _getIncomeSpendingWithPercentages(filteredIncome);

    _totalExpenses = _expenseCategories.fold(
      0.0,
      (sum, cat) => sum + cat.amount,
    );
    _totalIncome = _incomeCategories.fold(0.0, (sum, cat) => sum + cat.amount);

    setState(() {});
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
