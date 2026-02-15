import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/category_spending_data.dart';

/// Beautiful donut chart showing expense breakdown by category with real colors
/// Updates dynamically when expenses are added or deleted
class ExpenseDonutChart extends StatefulWidget {
  final double size;
  final bool showLegend;
  final bool showCenterText;

  const ExpenseDonutChart({
    super.key,
    this.size = 280,
    this.showLegend = true,
    this.showCenterText = true,
  });

  @override
  State<ExpenseDonutChart> createState() => _ExpenseDonutChartState();
}

class _ExpenseDonutChartState extends State<ExpenseDonutChart>
    with SingleTickerProviderStateMixin {
  List<CategorySpendingData> _spendingData = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _loadSpendingData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load spending data and calculate percentages
  Future<void> _loadSpendingData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final data = await provider.getCategorySpendingWithPercentages();

      if (mounted) {
        setState(() {
          _spendingData = data;
          _isLoading = false;
        });

        if (data.isNotEmpty) {
          _animationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _spendingData = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Reload data when provider transactions change
        if (provider.transactions.isNotEmpty &&
            _spendingData.isEmpty &&
            !_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadSpendingData();
          });
        }

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(
              0xFFE8F5E8,
            ), // Light green background like screenshot
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _spendingData.isEmpty
                  ? _buildEmptyState()
                  : Row(
                    children: [
                      // Chart on the left - bigger for complete circle
                      Expanded(
                        flex: 1,
                        child: SizedBox(height: 180, child: _buildDonutChart()),
                      ),
                      const SizedBox(width: 20),
                      // Labels on the right
                      Expanded(flex: 1, child: _buildSideLabels()),
                    ],
                  ),
        );
      },
    );
  }

  /// Build the animated complete circle chart - attractive with distinct colors
  Widget _buildDonutChart() {
    // Predefined attractive colors for top 4 categories
    final List<Color> chartColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 0, // Complete circle, not donut
            startDegreeOffset: -90,
            sections:
                _spendingData.take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return PieChartSectionData(
                    color: chartColors[index % chartColors.length],
                    value: data.amount * _animation.value,
                    title: '', // Clean - no text inside
                    radius: 80, // Larger radius for complete circle
                    titleStyle: const TextStyle(fontSize: 0),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  /// Build side labels with matching distinct colors
  Widget _buildSideLabels() {
    final double total = _spendingData.fold(
      0,
      (sum, data) => sum + data.amount,
    );

    // Same attractive colors as the chart
    final List<Color> chartColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _spendingData.take(4).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final percentage = ((data.amount / total) * 100);
            final color = chartColors[index % chartColors.length];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // Color indicator circle with shadow
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Percentage and category text with better styling
                  Expanded(
                    child: Text(
                      '${percentage.toStringAsFixed(1)}% - ${data.categoryName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Build empty state when no expenses are available
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF006E1F).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.pie_chart_outline,
            size: 50,
            color: Color(0xFF006E1F),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No Expenses Yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF006E1F),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add some expenses to see\nyour spending breakdown',
          style: TextStyle(fontSize: 14, color: Color(0xFF006E1F), height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Add sample data for demonstration
            _addSampleData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006E1F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add Sample Data',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// Add sample data for demonstration
  void _addSampleData() {
    setState(() {
      _spendingData = [
        CategorySpendingData(
          categoryId: '1',
          categoryName: 'Electronics',
          amount: 470.0,
          percentage: 47.0,
          color: '#8B5A3C',
        ),
        CategorySpendingData(
          categoryId: '2',
          categoryName: 'Drinks',
          amount: 240.0,
          percentage: 24.0,
          color: '#FF6B35',
        ),
        CategorySpendingData(
          categoryId: '3',
          categoryName: 'Travel',
          amount: 149.0,
          percentage: 14.9,
          color: '#4285F4',
        ),
        CategorySpendingData(
          categoryId: '4',
          categoryName: 'Rent',
          amount: 66.0,
          percentage: 6.6,
          color: '#674EA7',
        ),
      ];
      _isLoading = false;
    });
    _animationController.forward();
  }
}
