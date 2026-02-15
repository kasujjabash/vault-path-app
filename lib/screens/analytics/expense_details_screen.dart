import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../models/category.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';

/// Detailed spending page showing comprehensive expenditure information
class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  Map<String, double> _categorySpending = {};
  double _totalSpent = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  Future<void> _loadSpendingData() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    try {
      final categorySpending =
          await provider.getCurrentMonthSpendingByCategory();
      final totalSpent = categorySpending.values.fold(0.0, (a, b) => a + b);

      if (mounted) {
        setState(() {
          _categorySpending = categorySpending;
          _totalSpent = totalSpent;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading spending data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Expense Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              )
              : _totalSpent == 0
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadSpendingData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTotalSpentCard(),
                      const SizedBox(height: 24),
                      _buildPieChart(),
                      const SizedBox(height: 24),
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 24),
                      _buildSpendingInsights(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No Expenses This Month',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding transactions to see your spending breakdown',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSpentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF006E1F), // Solid dark green
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006E1F).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spent This Month',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FormatUtils.formatCurrency(_totalSpent),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getCurrentMonthYear(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, child) {
                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _buildPieChartSections(provider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(ExpenseProvider provider) {
    final sections = <PieChartSectionData>[];

    for (var entry in _categorySpending.entries) {
      final categoryName = entry.key;
      final amount = entry.value;
      final percentage = (amount / _totalSpent * 100);

      final category = provider.categories.firstWhere(
        (c) => c.name == categoryName,
        orElse:
            () =>
                provider.categories.isNotEmpty
                    ? provider.categories.first
                    : Category(
                      id: 'default',
                      name: categoryName,
                      color: '#FF9800',
                      type: 'expense',
                      icon: 'category',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
      );

      sections.add(
        PieChartSectionData(
          color: Color(FormatUtils.parseColorString(category.color)),
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<ExpenseProvider>(
            builder: (context, provider, child) {
              final sortedEntries =
                  _categorySpending.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));

              return Column(
                children:
                    sortedEntries.map((entry) {
                      final categoryName = entry.key;
                      final amount = entry.value;
                      final percentage = (amount / _totalSpent * 100);

                      final category = provider.categories.firstWhere(
                        (c) => c.name == categoryName,
                        orElse:
                            () =>
                                provider.categories.isNotEmpty
                                    ? provider.categories.first
                                    : Category(
                                      id: 'default',
                                      name: categoryName,
                                      color: '#FF9800',
                                      type: 'expense',
                                      icon: 'category',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      FormatUtils.parseColorString(
                                        category.color,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      FormatUtils.formatCurrency(amount),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(
                                  FormatUtils.parseColorString(category.color),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildInsightCards(),
        ],
      ),
    );
  }

  List<Widget> _buildInsightCards() {
    final insights = <Widget>[];

    if (_categorySpending.isNotEmpty) {
      final topCategory = _categorySpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final topPercentage = (topCategory.value / _totalSpent * 100);

      insights.add(
        _buildInsightCard(
          Icons.trending_up,
          'Top Category',
          '${topCategory.key} (${topPercentage.toStringAsFixed(1)}%)',
          AppConstants.primaryColor,
        ),
      );

      final avgDaily = _totalSpent / DateTime.now().day;
      insights.add(
        _buildInsightCard(
          Icons.calendar_view_day,
          'Daily Average',
          FormatUtils.formatCurrency(avgDaily),
          AppConstants.successColor,
        ),
      );

      final categoryCount = _categorySpending.length;
      insights.add(
        _buildInsightCard(
          Icons.category,
          'Categories Used',
          '$categoryCount categories',
          Colors.orange,
        ),
      );
    }

    return insights;
  }

  Widget _buildInsightCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
