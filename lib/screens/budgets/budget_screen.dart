import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../models/budget.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

/// Comprehensive Budget Management Screen
/// Set spending limits, receive alerts, and track budget progress
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _receiveAlerts = true;
  double _alertPercentage = 80.0;
  String? _selectedCategoryId;
  String _selectedMonth = 'Current Month';
  final TextEditingController _limitController = TextEditingController();
  double _monthlyIncome = 0.0;
  double _totalBalance = 0.0;

  final List<String> _months = [
    'Current Month',
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

  @override
  void initState() {
    super.initState();
    _loadMonthlyIncome();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  /// Get adaptive card color - white in light mode, dark green in dark mode
  Color _getAdaptiveCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF2b3c29); // Dark green for dark mode
  }

  /// Get adaptive card shadow color
  Color _getAdaptiveCardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black.withOpacity(0.05)
        : Theme.of(context).colorScheme.secondary.withOpacity(0.1);
  }

  Future<void> _loadMonthlyIncome() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final income = await provider.getCurrentMonthIncome();
    final balance = provider.totalBalance;
    setState(() {
      _monthlyIncome = income;
      _totalBalance = balance;
    });
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
          'Budget Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/all-budgets');
            },
            icon: Icon(
              Icons.list_alt,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'View All Budgets',
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final categories = [...provider.expenseCategories];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Budgets List - Now at the top
                _buildActiveBudgets(provider),
                const SizedBox(height: 20),

                // Alert Toggle Section
                _buildAlertToggleCard(),
                const SizedBox(height: 20),

                // Set Budget Limit Card
                _buildSetLimitCard(categories),
                const SizedBox(height: 20),

                // Budget Calculator - Below budget creation
                _buildSavingsCalculator(),

                const SizedBox(height: 100), // Space for navigation
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build alert toggle card with dotted line visual
  Widget _buildAlertToggleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAdaptiveCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveCardShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color:
                    _receiveAlerts
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Switch(
                value: _receiveAlerts,
                onChanged: (value) {
                  setState(() {
                    _receiveAlerts = value;
                  });
                },
                activeThumbColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),

          // Dotted line visual indicator
          if (_receiveAlerts) ...[
            const SizedBox(height: 16),
            CustomPaint(
              size: const Size(double.infinity, 2),
              painter: DottedLinePainter(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_receiveAlerts) ...[
            Text(
              'Receive alert when it reaches ${_alertPercentage.round()}% of the spending',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Percentage Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: _alertPercentage,
                min: 10.0,
                max: 100.0,
                divisions: 90,
                activeColor: Theme.of(context).colorScheme.secondary,
                inactiveColor: Theme.of(
                  context,
                ).colorScheme.secondary.withOpacity(0.2),
                label: '${_alertPercentage.round()}%',
                onChanged: (value) {
                  setState(() {
                    _alertPercentage = value;
                  });
                },
              ),
            ),

            // Percentage labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10%',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '50%',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Build set budget limit card
  Widget _buildSetLimitCard(List<dynamic> categories) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAdaptiveCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveCardShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Set Budget Limit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Select Category Dropdown
          Text(
            'Select Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(context),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategoryId,
                hint: const Text('Choose a category'),
                items:
                    categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Select Month Dropdown
          Text(
            'Select Month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _getAdaptiveCardColor(context),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMonth,
                items:
                    _months.map((month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Budget Amount Input
          Row(
            children: [
              Text(
                'Budget Amount (\$)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Available: ${FormatUtils.formatCurrency(_totalBalance)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Available Balance: ${FormatUtils.formatCurrency(_totalBalance)}',
            style: TextStyle(
              fontSize: 12,
              color:
                  _totalBalance > 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {}); // Trigger rebuild to update button state
            },
            decoration: InputDecoration(
              hintText: 'Enter budget amount',
              prefixText: '\$ ',
              suffixIcon: _getBudgetValidationIcon(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      _isBudgetValid()
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              ),
            ),
          ),

          // Validation Warning
          if (!_isBudgetValid() && _limitController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getValidationMessage(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Create Budget Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _selectedCategoryId != null &&
                          _limitController.text.isNotEmpty &&
                          _isBudgetValid()
                      ? _createBudget
                      : null,
              style: ElevatedButton.styleFrom(
                // backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Colors.green,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // disabledBackgroundColor: Theme.of(context).colorScheme.outline,
              ),
              child: const Text(
                'Create Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build savings calculator
  Widget _buildSavingsCalculator() {
    final budgetAmount = double.tryParse(_limitController.text) ?? 0.0;
    final savingsPercentage =
        _monthlyIncome > 0 ? (budgetAmount / _monthlyIncome) * 100 : 0.0;
    final potentialSavings = _monthlyIncome - budgetAmount;
    final exceedsBalance = budgetAmount > _totalBalance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              exceedsBalance
                  ? [
                    Theme.of(context).colorScheme.error.withOpacity(0.1),
                    Theme.of(context).colorScheme.error.withOpacity(0.05),
                  ]
                  : [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveCardShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                color:
                    exceedsBalance
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      exceedsBalance
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Available Balance Display (Most Important)
          _buildCalculatorRow(
            'Available Balance',
            FormatUtils.formatCurrency(_totalBalance),
            Icons.account_balance_wallet,
            _totalBalance > 0
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.error,
          ),

          const SizedBox(height: 8),

          // Budget Amount Display
          _buildCalculatorRow(
            'Budget Amount',
            FormatUtils.formatCurrency(budgetAmount),
            Icons.savings,
            exceedsBalance
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
          ),

          const SizedBox(height: 8),

          // Monthly Income Display
          _buildCalculatorRow(
            'Monthly Income',
            FormatUtils.formatCurrency(_monthlyIncome),
            Icons.trending_up,
            Theme.of(context).colorScheme.secondary,
          ),

          const SizedBox(height: 8),

          // Percentage of Income
          _buildCalculatorRow(
            'Percentage of Income',
            '${savingsPercentage.toStringAsFixed(1)}%',
            Icons.pie_chart,
            Theme.of(context).colorScheme.tertiary,
          ),

          const SizedBox(height: 8),

          // Remaining Balance After Budget
          _buildCalculatorRow(
            'Remaining Balance',
            FormatUtils.formatCurrency(
              (_totalBalance - budgetAmount).clamp(0, double.infinity),
            ),
            Icons.money,
            (_totalBalance - budgetAmount) > 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),

          // Warning Messages
          if (exceedsBalance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unrealistic Budget! You cannot spend ${FormatUtils.formatCurrency(budgetAmount - _totalBalance)} more than your available balance.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (potentialSavings < 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Budget exceeds monthly income by ${FormatUtils.formatCurrency(potentialSavings.abs())}. Consider adjusting your budget.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculatorRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _getAdaptiveCardColor(context).withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getAdaptiveCardColor(context).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build active budgets list
  Widget _buildActiveBudgets(ExpenseProvider provider) {
    final budgets = provider.activeBudgets;
    final displayBudgets = budgets.take(2).toList(); // Limit to 2 budgets

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getAdaptiveCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveCardShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.list_alt,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Active Budgets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (budgets.length > 2)
                TextButton(
                  onPressed: () {
                    context.push('/all-budgets');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (displayBudgets.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active budgets',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first budget to start tracking expenses',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...displayBudgets.map(
              (budget) => _buildBudgetCard(budget, provider),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(dynamic budget, ExpenseProvider provider) {
    final progress = budget.progressPercentage;
    final isNearLimit = progress >= (_alertPercentage / 100);
    final isExceeded = budget.isExceeded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isExceeded
                  ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                  : isNearLimit
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'EXCEEDED',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isNearLimit && _receiveAlerts)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ALERT',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
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
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isExceeded
                  ? Theme.of(context).colorScheme.error
                  : isNearLimit
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${FormatUtils.formatCurrency(budget.spent)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                'Limit: ${FormatUtils.formatCurrency(budget.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
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
                  color:
                      isExceeded
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Remaining: ${FormatUtils.formatCurrency(budget.remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      budget.remaining > 0
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

  /// Check if budget amount is valid (not exceeding available balance)
  bool _isBudgetValid() {
    final budgetAmount = double.tryParse(_limitController.text) ?? 0.0;
    if (budgetAmount <= 0) return false;
    if (_totalBalance <= 0) return false;
    return budgetAmount <= _totalBalance;
  }

  /// Get validation message for invalid budget
  String _getValidationMessage() {
    final budgetAmount = double.tryParse(_limitController.text) ?? 0.0;
    if (_totalBalance <= 0) {
      return 'No funds available in accounts. Add money to create budgets.';
    }
    if (budgetAmount > _totalBalance) {
      final excess = budgetAmount - _totalBalance;
      return 'Budget exceeds available balance by ${FormatUtils.formatCurrency(excess)}';
    }
    return '';
  }

  /// Get validation icon for budget input field
  Widget? _getBudgetValidationIcon() {
    if (_limitController.text.isEmpty) return null;

    return Icon(
      _isBudgetValid() ? Icons.check_circle : Icons.error,
      color:
          _isBudgetValid()
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
      size: 20,
    );
  }

  void _createBudget() async {
    if (_selectedCategoryId == null || _limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category and enter budget amount'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(_limitController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid budget amount'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Check if budget exceeds available balance
    if (amount > _totalBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Budget amount cannot exceed available balance of ${FormatUtils.formatCurrency(_totalBalance)}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      // Find the selected category to get its name
      final selectedCategory = provider.expenseCategories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
      );

      // Calculate start and end dates based on selected month
      final now = DateTime.now();
      DateTime startDate, endDate;

      if (_selectedMonth == 'Current Month') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      } else {
        final monthIndex = _months.indexOf(_selectedMonth);
        startDate = DateTime(now.year, monthIndex, 1);
        endDate = DateTime(now.year, monthIndex + 1, 0);
      }

      // Create the budget
      final budget = Budget(
        id: const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        name: '${selectedCategory.name} - $_selectedMonth Budget',
        amount: amount,
        spent: 0.0,
        period: 'monthly',
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        notes:
            'Alert threshold: ${_receiveAlerts ? '${_alertPercentage.round()}%' : 'Disabled'}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the budget via the provider
      await provider.addBudget(budget);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Budget created: ${FormatUtils.formatCurrency(amount)} for ${selectedCategory.name}',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );

        // Clear form
        setState(() {
          _selectedCategoryId = null;
          _limitController.clear();
          _selectedMonth = 'Current Month';
        });
      }
    } catch (e) {
      debugPrint('Error creating budget: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating budget: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedLinePainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double currentX = 0.0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(currentX + dashWidth, size.height / 2),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
