import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/savings_goal.dart';
import '../../utils/format_utils.dart';

class AllBudgetsScreen extends StatefulWidget {
  const AllBudgetsScreen({super.key});

  @override
  State<AllBudgetsScreen> createState() => _AllBudgetsScreenState();
}

class _AllBudgetsScreenState extends State<AllBudgetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMonth = 'All time';
  String _sortBy = 'Name';

  final List<String> _sortOptions = ['Name', 'Amount', 'Progress'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        title: Text(
          'All Budgets & Savings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Theme.of(context).appBarTheme.foregroundColor),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => _sortOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(_getSortIcon(option),
                        color: Theme.of(context).colorScheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text('Sort by $option'),
                    if (_sortBy == option) ...[
                      const Spacer(),
                      Icon(Icons.check,
                          color: Theme.of(context).colorScheme.secondary, size: 16),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).appBarTheme.foregroundColor,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor:
              Theme.of(context).appBarTheme.foregroundColor!.withValues(alpha: 0.55),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Budgets'),
            Tab(text: 'Savings Goals'),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBudgetsTab(provider),
              _buildSavingsGoalsTab(provider),
            ],
          );
        },
      ),
    );
  }

  // ─── BUDGETS TAB ─────────────────────────────────────────────────────────

  Widget _buildBudgetsTab(ExpenseProvider provider) {
    final budgets = _getFilteredAndSortedBudgets(provider.activeBudgets);
    return Column(
      children: [
        _buildMonthFilterRow(),
        Expanded(child: budgets.isEmpty ? _buildEmptyState(isBudgets: true) : _buildBudgetsList(budgets)),
      ],
    );
  }

  Widget _buildMonthFilterRow() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
    );
  }

  Widget _buildMonthChip(String period, IconData icon) {
    final isSelected = _selectedMonth == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedMonth = period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)
                  : Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              period,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondary
                    : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsList(List<dynamic> budgets) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: budgets.length,
      itemBuilder: (context, index) => _buildBudgetCard(budgets[index]),
    );
  }

  Widget _buildBudgetCard(dynamic budget) {
    final progress = budget.progressPercentage;
    final isNearLimit = progress >= 0.8;
    final isExceeded = budget.isExceeded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExceeded
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
              : isNearLimit
                  ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isExceeded)
                _statusBadge('EXCEEDED', Theme.of(context).colorScheme.error,
                    Theme.of(context).colorScheme.onError)
              else if (isNearLimit)
                _statusBadge('ALERT', const Color(0xFFFFB74D), Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isExceeded
                  ? Theme.of(context).colorScheme.error
                  : isNearLimit
                      ? const Color(0xFFFFB74D)
                      : Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF7DDB7D)
                          : const Color(0xFF006E1F),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: ${FormatUtils.formatCurrency(budget.spent)}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              Text('Limit: ${FormatUtils.formatCurrency(budget.amount)}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% used',
                style: TextStyle(
                  fontSize: 12,
                  color: isExceeded
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Remaining: ${FormatUtils.formatCurrency(budget.remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  color: budget.remaining > 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── SAVINGS GOALS TAB ───────────────────────────────────────────────────

  Widget _buildSavingsGoalsTab(ExpenseProvider provider) {
    final goals = _getFilteredAndSortedGoals(provider.savingsGoals);
    return Column(
      children: [
        _buildMonthFilterRow(),
        Expanded(
          child: goals.isEmpty
              ? _buildEmptyState(isBudgets: false)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: goals.length,
                  itemBuilder: (context, index) => _buildGoalCard(goals[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = goal.progressPercentage;
    final Color progressColor = goal.isCompleted
        ? const Color(0xFF006E1F)
        : goal.isOverdue
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goal.isCompleted
              ? const Color(0xFF006E1F).withValues(alpha: 0.4)
              : goal.isOverdue
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: goal.isCompleted ? 2 : 1,
        ),
        color: goal.isCompleted
            ? const Color(0xFF006E1F).withValues(alpha: isDark ? 0.12 : 0.04)
            : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (goal.deadline != null)
                      Text(
                        goal.isCompleted
                            ? 'Goal achieved! 🎉'
                            : goal.isOverdue
                                ? 'Overdue by ${goal.daysLeft!.abs()} days'
                                : '${goal.daysLeft} days left',
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isCompleted
                              ? (isDark ? Colors.white : const Color(0xFF006E1F))
                              : goal.isOverdue
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (goal.isCompleted)
                _statusBadge('COMPLETE', const Color(0xFF006E1F), Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${FormatUtils.formatCurrency(goal.savedAmount)} saved',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              Text(
                'Target: ${FormatUtils.formatCurrency(goal.targetAmount)}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}% of goal',
                style: TextStyle(
                    fontSize: 12, color: progressColor, fontWeight: FontWeight.w500),
              ),
              Text(
                goal.isCompleted ? 'Completed!' : '${FormatUtils.formatCurrency(goal.remaining)} to go',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Widget _statusBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState({required bool isBudgets}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBudgets ? Icons.account_balance_wallet_outlined : Icons.flag_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              isBudgets ? 'No budgets found' : 'No savings goals yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              isBudgets
                  ? (_selectedMonth == 'All time'
                      ? 'Create your first budget to start tracking expenses'
                      : 'No budgets found for $_selectedMonth')
                  : 'Add savings goals from the Budget screen',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(isBudgets ? 'Go Back & Create' : 'Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _getFilteredAndSortedBudgets(List<dynamic> budgets) {
    final now = DateTime.now();
    List<dynamic> filtered = budgets.where((budget) {
      final createdAt = budget.createdAt as DateTime;
      switch (_selectedMonth) {
        case 'This month':
          return createdAt.year == now.year && createdAt.month == now.month;
        case 'Last month':
          final lastMonth = DateTime(now.year, now.month - 1);
          return createdAt.year == lastMonth.year && createdAt.month == lastMonth.month;
        case 'This year':
          return createdAt.year == now.year;
        case 'Last year':
          return createdAt.year == now.year - 1;
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Amount':
          return b.amount.compareTo(a.amount);
        case 'Progress':
          return b.progressPercentage.compareTo(a.progressPercentage);
        default:
          return a.name.compareTo(b.name);
      }
    });
    return filtered;
  }

  List<SavingsGoal> _getFilteredAndSortedGoals(List<SavingsGoal> goals) {
    final now = DateTime.now();
    List<SavingsGoal> filtered = goals.where((goal) {
      switch (_selectedMonth) {
        case 'This month':
          return goal.createdAt.year == now.year && goal.createdAt.month == now.month;
        case 'Last month':
          final lastMonth = DateTime(now.year, now.month - 1);
          return goal.createdAt.year == lastMonth.year &&
              goal.createdAt.month == lastMonth.month;
        case 'This year':
          return goal.createdAt.year == now.year;
        case 'Last year':
          return goal.createdAt.year == now.year - 1;
        default:
          return true;
      }
    }).toList();

    switch (_sortBy) {
      case 'Amount':
        filtered.sort((a, b) => b.targetAmount.compareTo(a.targetAmount));
      case 'Progress':
        filtered.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
    }
    return filtered;
  }

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
