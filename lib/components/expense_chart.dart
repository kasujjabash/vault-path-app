import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/format_utils.dart';
import '../utils/app_constants.dart';

/// Expense chart widget showing spending breakdown by category
/// Displays a beautiful pie chart with category-wise expense distribution
class ExpenseChart extends StatefulWidget {
  const ExpenseChart({super.key});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  Map<String, double> _spendingData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpendingData();
  }

  /// Load spending data by category for current month
  Future<void> _loadSpendingData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final data = await provider.getCurrentMonthSpendingByCategory();

      setState(() {
        _spendingData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading spending data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _spendingData.isEmpty
              ? _buildEmptyState()
              : _buildChart(),
    );
  }

  /// Build the pie chart
  Widget _buildChart() {
    final total = _spendingData.values.fold(0.0, (sum, value) => sum + value);

    if (total == 0) {
      return _buildEmptyState();
    }

    return Row(
      children: [
        // Chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections:
                  _spendingData.entries.map((entry) {
                    final index = _spendingData.keys.toList().indexOf(
                      entry.key,
                    );
                    final color =
                        AppConstants.chartColors[index %
                            AppConstants.chartColors.length];
                    final percentage = entry.value / total;

                    return PieChartSectionData(
                      value: entry.value,
                      title: '${(percentage * 100).toStringAsFixed(1)}%',
                      color: color,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _spendingData.entries.map((entry) {
                  final index = _spendingData.keys.toList().indexOf(entry.key);
                  final color =
                      AppConstants.chartColors[index %
                          AppConstants.chartColors.length];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeSmall,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                FormatUtils.formatCurrency(entry.value),
                                style: TextStyle(
                                  fontSize: AppConstants.fontSizeSmall,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build empty state when no data available
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'No spending data',
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add some expenses to see your spending breakdown',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
