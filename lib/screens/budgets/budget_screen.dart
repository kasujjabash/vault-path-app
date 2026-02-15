import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../models/budget.dart';
import 'package:uuid/uuid.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Budget Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF006E1F),
        foregroundColor: Colors.white,
        elevation: 0,
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
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: _receiveAlerts ? const Color(0xFF006E1F) : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Budget Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E1F),
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
                activeColor: const Color(0xFF006E1F),
              ),
            ],
          ),

          // Dotted line visual indicator
          if (_receiveAlerts) ...[
            const SizedBox(height: 16),
            CustomPaint(
              size: const Size(double.infinity, 2),
              painter: DottedLinePainter(
                color: const Color(0xFF006E1F).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_receiveAlerts) ...[
            Text(
              'Receive alert when it reaches ${_alertPercentage.round()}% of the spending',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
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
                activeColor: const Color(0xFF006E1F),
                inactiveColor: const Color(0xFFD4E5D3),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '50%',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  '100%',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
          const Row(
            children: [
              Icon(Icons.savings, color: Color(0xFF006E1F), size: 24),
              SizedBox(width: 12),
              Text(
                'Set Budget Limit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E1F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Select Category Dropdown
          const Text(
            'Select Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
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
          const Text(
            'Select Month',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
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
              const Text(
                'Budget Amount (\$)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                'Available: ${FormatUtils.formatCurrency(_totalBalance)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
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
              color: _totalBalance > 0 ? const Color(0xFF006E1F) : Colors.red,
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
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      _isBudgetValid() ? const Color(0xFF006E1F) : Colors.red,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),

          // Validation Warning
          if (!_isBudgetValid() && _limitController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getValidationMessage(),
                      style: const TextStyle(
                        color: Colors.red,
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
                backgroundColor: const Color(0xFF006E1F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
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
                  ? [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)]
                  : [const Color(0xFFD4E5D3), const Color(0xFFE8F5E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Row(
            children: [
              Icon(
                Icons.calculate,
                color: exceedsBalance ? Colors.red : const Color(0xFF006E1F),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Budget Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: exceedsBalance ? Colors.red : const Color(0xFF006E1F),
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
            _totalBalance > 0 ? const Color(0xFF006E1F) : Colors.red,
          ),

          const SizedBox(height: 8),

          // Budget Amount Display
          _buildCalculatorRow(
            'Budget Amount',
            FormatUtils.formatCurrency(budgetAmount),
            Icons.savings,
            exceedsBalance ? Colors.red : const Color(0xFF006E1F),
          ),

          const SizedBox(height: 8),

          // Monthly Income Display
          _buildCalculatorRow(
            'Monthly Income',
            FormatUtils.formatCurrency(_monthlyIncome),
            Icons.trending_up,
            Colors.green,
          ),

          const SizedBox(height: 8),

          // Percentage of Income
          _buildCalculatorRow(
            'Percentage of Income',
            '${savingsPercentage.toStringAsFixed(1)}%',
            Icons.pie_chart,
            Colors.orange,
          ),

          const SizedBox(height: 8),

          // Remaining Balance After Budget
          _buildCalculatorRow(
            'Remaining Balance',
            FormatUtils.formatCurrency(
              (_totalBalance - budgetAmount).clamp(0, double.infinity),
            ),
            Icons.money,
            (_totalBalance - budgetAmount) > 0 ? Colors.blue : Colors.red,
          ),

          // Warning Messages
          if (exceedsBalance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Unrealistic Budget! You cannot spend ${FormatUtils.formatCurrency(budgetAmount - _totalBalance)} more than your available balance.',
                      style: const TextStyle(
                        color: Colors.red,
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Budget exceeds monthly income by ${FormatUtils.formatCurrency(potentialSavings.abs())}. Consider adjusting your budget.',
                      style: const TextStyle(
                        color: Colors.orange,
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
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Build active budgets list
  Widget _buildActiveBudgets(ExpenseProvider provider) {
    final budgets = provider.activeBudgets;

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
          const Row(
            children: [
              Icon(Icons.list_alt, color: Color(0xFF006E1F), size: 24),
              SizedBox(width: 12),
              Text(
                'Active Budgets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E1F),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (budgets.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active budgets',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first budget to start tracking expenses',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...budgets
                .map((budget) => _buildBudgetCard(budget, provider))
                .toList(),
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
              else if (isNearLimit && _receiveAlerts)
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
      color: _isBudgetValid() ? Colors.green : Colors.red,
      size: 20,
    );
  }

  void _createBudget() async {
    if (_selectedCategoryId == null || _limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category and enter budget amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_limitController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount'),
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
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
            backgroundColor: const Color(0xFF006E1F),
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
            backgroundColor: Colors.red,
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
