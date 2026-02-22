import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';

/// All Budgets Overview Screen
/// View all budgets without creation/editing capabilities
class AllBudgetsScreen extends StatefulWidget {
  const AllBudgetsScreen({super.key});

  @override
  State<AllBudgetsScreen> createState() => _AllBudgetsScreenState();
}

class _AllBudgetsScreenState extends State<AllBudgetsScreen> {
  String _selectedMonth = 'All time';
  String _sortBy = 'Name';

  final List<String> _sortOptions = ['Name', 'Amount', 'Progress'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'All Budgets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF006E1F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Sort button only
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder:
                (context) =>
                    _sortOptions.map((option) {
                      return PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              _getSortIcon(option),
                              color: const Color(0xFF006E1F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('Sort by $option'),
                            if (_sortBy == option) ...[
                              const Spacer(),
                              const Icon(
                                Icons.check,
                                color: Color(0xFF006E1F),
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final budgets = _getFilteredAndSortedBudgets(provider.activeBudgets);
          return Column(
            children: [
              // Month Filter Chips
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      _buildMonthChip('All time', Icons.all_inclusive),
                      const SizedBox(width: 6),
                      _buildMonthChip('This month', Icons.calendar_month),
                      const SizedBox(width: 6),
                      _buildMonthChip('Last month', Icons.calendar_today),
                      const SizedBox(width: 6),
                      _buildMonthChip('This year', Icons.date_range),
                      const SizedBox(width: 6),
                      _buildMonthChip('Last year', Icons.history),
                    ],
                  ),
                ),
              ),
              // Budgets List
              Expanded(child: _buildBudgetsView(budgets, provider)),
            ],
          );
        },
      ),
    );
  }

  /// Get filtered and sorted budgets
  List<dynamic> _getFilteredAndSortedBudgets(List<dynamic> budgets) {
    final now = DateTime.now();

    // Filter budgets by creation month
    List<dynamic> filteredBudgets =
        budgets.where((budget) {
          final createdAt = budget.createdAt as DateTime;

          switch (_selectedMonth) {
            case 'This month':
              return createdAt.year == now.year && createdAt.month == now.month;
            case 'Last month':
              final lastMonth = DateTime(now.year, now.month - 1);
              return createdAt.year == lastMonth.year &&
                  createdAt.month == lastMonth.month;
            case 'This year':
              return createdAt.year == now.year;
            case 'Last year':
              return createdAt.year == now.year - 1;
            default: // All time
              return true;
          }
        }).toList();

    // Sort budgets
    filteredBudgets.sort((a, b) {
      switch (_sortBy) {
        case 'Amount':
          return b.amount.compareTo(a.amount);
        case 'Progress':
          return b.progressPercentage.compareTo(a.progressPercentage);
        default: // Name
          return a.name.compareTo(b.name);
      }
    });

    return filteredBudgets;
  }

  /// Build month filter chip
  Widget _buildMonthChip(String period, IconData icon) {
    final isSelected = _selectedMonth == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonth = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006E1F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF006E1F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color:
                  isSelected
                      ? Colors.white
                      : const Color(0xFF006E1F).withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              period,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white
                        : const Color(0xFF006E1F).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the main budgets view
  Widget _buildBudgetsView(List<dynamic> budgets, ExpenseProvider provider) {
    if (budgets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        return _buildBudgetCard(budget, provider);
      },
    );
  }

  /// Build budget card
  Widget _buildBudgetCard(dynamic budget, ExpenseProvider provider) {
    final progress = budget.progressPercentage;
    final isNearLimit = progress >= 0.8; // 80% threshold for alerts
    final isExceeded = budget.isExceeded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isExceeded
                ? Colors.red.withOpacity(0.05)
                : isNearLimit
                ? Colors.orange.withOpacity(0.05)
                : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isExceeded
                  ? Colors.red.withOpacity(0.3)
                  : isNearLimit
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (isExceeded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EXCEEDED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isNearLimit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isExceeded
                  ? Colors.red
                  : isNearLimit
                  ? Colors.orange
                  : const Color(0xFF006E1F),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${FormatUtils.formatCurrency(budget.spent)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                'Limit: ${FormatUtils.formatCurrency(budget.amount)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% used',
                style: TextStyle(
                  fontSize: 12,
                  color: isExceeded ? Colors.red : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Remaining: ${FormatUtils.formatCurrency(budget.remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      budget.remaining > 0
                          ? const Color(0xFF006E1F)
                          : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No budgets found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedMonth == 'All time'
                  ? 'Create your first budget to start tracking expenses'
                  : 'No budgets found for $_selectedMonth',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Budget',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006E1F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get sort icon
  IconData _getSortIcon(String sort) {
    switch (sort) {
      case 'Amount':
        return Icons.paid;
      case 'Progress':
        return Icons.timeline;
      default:
        return Icons.sort_by_alpha;
    }
  }
}
