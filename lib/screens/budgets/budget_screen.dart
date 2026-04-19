import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../utils/app_constants.dart';
import '../../utils/premium_utils.dart';
import '../../services/premium_service.dart';
import '../../models/budget.dart';
import '../../models/savings_goal.dart';
import '../../services/firebase_sync_service.dart';
import '../../services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

/// Comprehensive Budget Management Screen
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _receiveAlerts = true;
  double _alertPercentage = 80.0;
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBudgetSettings();
    _loadBalance();
  }

  Color _getAdaptiveCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF2b3c29);
  }

  Color _getAdaptiveCardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black.withValues(alpha: 0.05)
        : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
  }

  Future<void> _loadBudgetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _receiveAlerts = prefs.getBool(AppConstants.keyBudgetAlertsEnabled) ?? true;
        _alertPercentage = prefs.getDouble(AppConstants.keyBudgetAlertPercentage) ?? 80.0;
      });
    } catch (e) {
      debugPrint('Error loading budget settings: $e');
    }
  }

  Future<void> _saveBudgetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyBudgetAlertsEnabled, _receiveAlerts);
      await prefs.setDouble(AppConstants.keyBudgetAlertPercentage, _alertPercentage);
      if (AuthService().isSignedIn) {
        FirebaseSyncService().syncSettingsToFirebase();
      }
    } catch (e) {
      debugPrint('Error saving budget settings: $e');
    }
  }

  Future<void> _loadBalance() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final income = await provider.getCurrentMonthIncome();
    final expenses = await provider.getCurrentMonthExpenses();
    setState(() {
      _totalBalance = income - expenses;
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
            onPressed: () => context.push('/all-budgets'),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActiveBudgets(provider),
                const SizedBox(height: 20),
                _buildSavingsGoalsSection(provider),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── ACTIVE BUDGETS ──────────────────────────────────────────────────────

  Widget _buildActiveBudgets(ExpenseProvider provider) {
    final budgets = provider.activeBudgets;

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
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showBudgetSheet(context, provider),
                icon: Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.secondary),
                label: Text(
                  'Add Budget',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active budgets',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Add Budget" to start tracking your spending',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...budgets.map((budget) => _buildBudgetCard(budget, provider)),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () => _showBudgetOptions(context, budget, provider),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
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
              Text(
                'Spent: ${FormatUtils.formatCurrency(budget.spent)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Limit: ${FormatUtils.formatCurrency(budget.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          if (_receiveAlerts) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  size: 13,
                  color: isNearLimit
                      ? const Color(0xFFFFB74D)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 4),
                Text(
                  'Alert at ${_alertPercentage.round()}% — ${FormatUtils.formatCurrency(budget.amount * _alertPercentage / 100)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isNearLimit
                        ? const Color(0xFFFFB74D)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showBudgetOptions(BuildContext context, dynamic budget, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              budget.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete Budget',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await provider.deleteBudget(budget.id);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${budget.name} deleted'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context, ExpenseProvider provider) {
    final categories = [...provider.expenseCategories];
    String? sheetCategoryId;
    String sheetMonth = 'Current Month';
    final limitController = TextEditingController();
    bool sheetReceiveAlerts = _receiveAlerts;
    double sheetAlertPercentage = _alertPercentage;

    const months = [
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

    bool isValid(String text) {
      final amount = double.tryParse(text) ?? 0.0;
      if (amount <= 0) return false;
      if (_totalBalance <= 0) return false;
      return amount <= _totalBalance;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.savings, color: Theme.of(context).colorScheme.secondary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Set Budget',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Select Category
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
                        value: sheetCategoryId,
                        hint: const Text('Choose a category'),
                        dropdownColor: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xFF2B3C29),
                        items: categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (value) => setSheetState(() => sheetCategoryId = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Month
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
                        value: sheetMonth,
                        dropdownColor: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color(0xFF2B3C29),
                        items: months.map((m) {
                          return DropdownMenuItem<String>(value: m, child: Text(m));
                        }).toList(),
                        onChanged: (value) => setSheetState(() => sheetMonth = value!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Budget Amount
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
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                      color: _totalBalance > 0
                          ? const Color(0xFF006E1F)
                          : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter budget amount',
                      prefixText: '\$ ',
                      suffixIcon: limitController.text.isEmpty
                          ? null
                          : Icon(
                              isValid(limitController.text) ? Icons.check_circle : Icons.error,
                              color: isValid(limitController.text)
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isValid(limitController.text)
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.error,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Validation warning
                  if (!isValid(limitController.text) && limitController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Theme.of(context).colorScheme.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _totalBalance <= 0
                                  ? 'No funds available. Add money to create budgets.'
                                  : 'Budget exceeds available balance of ${FormatUtils.formatCurrency(_totalBalance)}',
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

                  // Budget Alerts
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getAdaptiveCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: sheetReceiveAlerts
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Budget Alerts',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: sheetReceiveAlerts,
                              onChanged: (value) {
                                setSheetState(() => sheetReceiveAlerts = value);
                                setState(() => _receiveAlerts = value);
                                _saveBudgetSettings();
                              },
                              activeThumbColor: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                        if (sheetReceiveAlerts) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Alert at ${sheetAlertPercentage.round()}% — ${FormatUtils.formatCurrency((double.tryParse(limitController.text) ?? 0) * sheetAlertPercentage / 100)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 5.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                            ),
                            child: Slider(
                              value: sheetAlertPercentage,
                              min: 10.0,
                              max: 100.0,
                              divisions: 90,
                              activeColor: Theme.of(context).colorScheme.secondary,
                              inactiveColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                              label: '${sheetAlertPercentage.round()}%',
                              onChanged: (value) {
                                setSheetState(() => sheetAlertPercentage = value);
                                setState(() => _alertPercentage = value);
                                _saveBudgetSettings();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('10%', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                              Text('50%', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                              Text('100%', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: sheetCategoryId != null &&
                              limitController.text.isNotEmpty &&
                              isValid(limitController.text)
                          ? () async {
                              if (!PremiumService().isPremium) {
                                Navigator.pop(sheetCtx);
                                PremiumUtils.showPremiumBottomSheet(context, 'Budget Creation');
                                return;
                              }

                              final amount = double.tryParse(limitController.text);
                              if (amount == null || amount <= 0) return;

                              final selectedCategory = provider.expenseCategories
                                  .firstWhere((cat) => cat.id == sheetCategoryId);

                              final now = DateTime.now();
                              DateTime startDate, endDate;
                              if (sheetMonth == 'Current Month') {
                                startDate = DateTime(now.year, now.month, 1);
                                endDate = DateTime(now.year, now.month + 1, 0);
                              } else {
                                final monthIndex = months.indexOf(sheetMonth);
                                startDate = DateTime(now.year, monthIndex, 1);
                                endDate = DateTime(now.year, monthIndex + 1, 0);
                              }

                              final budget = Budget(
                                id: const Uuid().v4(),
                                categoryId: sheetCategoryId!,
                                name: '${selectedCategory.name} - $sheetMonth Budget',
                                amount: amount,
                                spent: 0.0,
                                period: 'monthly',
                                startDate: startDate,
                                endDate: endDate,
                                isActive: true,
                                notes:
                                    'Alert threshold: ${sheetReceiveAlerts ? '${sheetAlertPercentage.round()}%' : 'Disabled'}',
                                createdAt: now,
                                updatedAt: now,
                              );

                              final messenger = ScaffoldMessenger.of(context);
                              await provider.addBudget(budget);

                              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Budget created: ${FormatUtils.formatCurrency(amount)} for ${selectedCategory.name}',
                                    ),
                                    backgroundColor: AppConstants.successColor,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006E1F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Create Budget',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── SAVINGS GOALS ───────────────────────────────────────────────────────

  Widget _buildSavingsGoalsSection(ExpenseProvider provider) {
    final goals = provider.savingsGoals;
    final displayGoals = goals.take(2).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Icon(Icons.savings, color: Theme.of(context).colorScheme.secondary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Savings Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showGoalSheet(context, provider),
                icon: Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.secondary),
                label: Text(
                  'Add Goal',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No savings goals yet',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Goal" to set your first savings target',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            ...displayGoals.map((goal) => _buildGoalCard(goal, provider, isDark)),
            if (goals.length > 2)
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push('/all-budgets'),
                  icon: Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.secondary),
                  label: Text(
                    'View all ${goals.length} goals',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, ExpenseProvider provider, bool isDark) {
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
                    if (goal.deadline != null) ...[
                      const SizedBox(height: 2),
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
                  ],
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006E1F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'COMPLETE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () => _showGoalOptions(context, goal, provider),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Target: ${FormatUtils.formatCurrency(goal.targetAmount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (!goal.isCompleted) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% of goal',
                  style: TextStyle(
                    fontSize: 12,
                    color: progressColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${FormatUtils.formatCurrency(goal.remaining)} to go',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMoneySheet(context, goal, provider, withdraw: false),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Money'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: goal.savedAmount > 0
                        ? () => _showMoneySheet(context, goal, provider, withdraw: true)
                        : null,
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Withdraw'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showGoalOptions(BuildContext context, SavingsGoal goal, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(goal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Edit Goal'),
              onTap: () {
                Navigator.pop(context);
                _showGoalSheet(context, provider, existing: goal);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Delete Goal',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await provider.deleteSavingsGoal(goal.id);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${goal.name} deleted'),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMoneySheet(
    BuildContext context,
    SavingsGoal goal,
    ExpenseProvider provider, {
    required bool withdraw,
  }) {
    final controller = TextEditingController();
    final label = withdraw ? 'Withdraw' : 'Add Money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$label — ${goal.emoji} ${goal.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                withdraw
                    ? 'Saved: ${FormatUtils.formatCurrency(goal.savedAmount)}'
                    : 'Remaining: ${FormatUtils.formatCurrency(goal.remaining)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text);
                    if (amount == null || amount <= 0) return;
                    if (withdraw && amount > goal.savedAmount) return;
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    if (withdraw) {
                      await provider.withdrawFromSavingsGoal(goal.id, amount);
                    } else {
                      await provider.addToSavingsGoal(goal.id, amount);
                    }
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            withdraw
                                ? 'Withdrew ${FormatUtils.formatCurrency(amount)} from ${goal.name}'
                                : 'Added ${FormatUtils.formatCurrency(amount)} to ${goal.name}',
                          ),
                          backgroundColor: withdraw
                              ? AppConstants.errorColor
                              : AppConstants.successColor,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: withdraw
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF006E1F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalSheet(BuildContext context, ExpenseProvider provider, {SavingsGoal? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(
      text: existing != null ? existing.targetAmount.toStringAsFixed(0) : '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    String selectedEmoji = existing?.emoji ?? '🎯';
    DateTime? selectedDeadline = existing?.deadline;

    final emojis = ['🎯', '🏠', '🚗', '✈️', '📱', '💻', '🎓', '💍', '🏖️', '💰', '🛒', '🎁'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    existing != null ? 'Edit Goal' : 'New Savings Goal',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Icon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: emojis
                        .map((e) => GestureDetector(
                              onTap: () => setSheetState(() => selectedEmoji = e),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: selectedEmoji == e
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selectedEmoji == e
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(e, style: const TextStyle(fontSize: 22)),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Goal Name',
                      hintText: 'e.g. New Laptop, Vacation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                        builder: (ctx, child) {
                          final isDark = Theme.of(ctx).brightness == Brightness.dark;
                          return Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                                    primary: isDark
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF006E1F),
                                    onPrimary: Colors.white,
                                    onSurface: isDark ? Colors.white : Colors.black87,
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setSheetState(() => selectedDeadline = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedDeadline != null
                                  ? 'Deadline: ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                                  : 'Set deadline (optional)',
                              style: TextStyle(
                                color: selectedDeadline != null
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          if (selectedDeadline != null)
                            GestureDetector(
                              onTap: () => setSheetState(() => selectedDeadline = null),
                              child: Icon(Icons.close,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final target = double.tryParse(amountController.text);
                        if (name.isEmpty || target == null || target <= 0) return;

                        if (!PremiumService().isPremium) {
                          Navigator.pop(sheetCtx);
                          PremiumUtils.showPremiumBottomSheet(context, 'Savings Goals');
                          return;
                        }

                        final now = DateTime.now();
                        if (existing != null) {
                          await provider.updateSavingsGoal(existing.copyWith(
                            name: name,
                            targetAmount: target,
                            deadline: selectedDeadline,
                            clearDeadline: selectedDeadline == null,
                            emoji: selectedEmoji,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                            updatedAt: now,
                          ));
                        } else {
                          await provider.addSavingsGoal(SavingsGoal(
                            id: const Uuid().v4(),
                            name: name,
                            targetAmount: target,
                            emoji: selectedEmoji,
                            deadline: selectedDeadline,
                            notes: notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                            createdAt: now,
                            updatedAt: now,
                          ));
                        }
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006E1F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        existing != null ? 'Save Changes' : 'Create Goal',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DottedLinePainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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
