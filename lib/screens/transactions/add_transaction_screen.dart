import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../services/notification_service.dart';
import '../../services/currency_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';
import '../../utils/custom_snackbar.dart';
import '../../models/transaction.dart' as trans;
import '../../models/category.dart' as models;
import '../../models/account.dart';

/// Modern Add Transaction Screen with clean interface
/// Pass [transaction] to open in edit mode
class AddTransactionScreen extends StatefulWidget {
  final trans.Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _transactionType = 'expense'; // Default to expense
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  String _repeatOption = 'Never';
  bool _isLoading = false;
  String? _amountError;

  // Custom category creation controllers
  final _categoryNameController = TextEditingController();
  Color _selectedCategoryColor = Colors.blue;
  String _selectedCategoryIcon = 'category';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Edit mode: pre-fill all fields from existing transaction
      if (widget.transaction != null) {
        final t = widget.transaction!;
        setState(() {
          _transactionType = t.type;
          _amountController.text =
              t.amount % 1 == 0
                  ? t.amount.toInt().toString()
                  : t.amount.toString();
          _noteController.text = t.description ?? '';
          _selectedCategoryId = t.categoryId;
          _selectedAccountId = t.accountId;
          _paymentMethod = (t.tags != null && t.tags!.isNotEmpty) ? t.tags! : 'Cash';
          _selectedDate = t.date;
          if (t.isRecurring && t.recurringPattern != null) {
            final p = t.recurringPattern!;
            _repeatOption = p[0].toUpperCase() + p.substring(1);
          }
        });
        return;
      }
      // Add mode: get type from URL query parameter
      final uri = GoRouterState.of(context).uri;
      final type = uri.queryParameters['type'];
      if (type != null && (type == 'income' || type == 'expense')) {
        setState(() {
          _transactionType = type;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : 'Add Transaction',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Type Toggle
                        _buildTransactionTypeToggle(),
                        const SizedBox(height: 32),

                        // Amount Field
                        _buildAmountSection(),
                        const SizedBox(height: 32),

                        // Category Selection
                        _buildCategorySelection(),
                        const SizedBox(height: 24),

                        // Date and Repeat Row
                        Row(
                          children: [
                            Expanded(child: _buildDateSelection()),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRepeatSelection()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Payment Method
                        _buildPaymentMethodSelection(),
                        const SizedBox(height: 32),

                        // Quick Note
                        _buildQuickNoteSection(),

                        const SizedBox(height: 120), // Space for save button
                      ],
                    ),
                  ),
                ),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Essential UI Builder Methods

  /// Build transaction type toggle (Expense/Income)
  Widget _buildTransactionTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 60,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _transactionType = 'expense'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          _transactionType == 'expense'
                              ? Colors.red.shade500
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color:
                              _transactionType == 'expense'
                                  ? Colors.white
                                  : Colors.red.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _transactionType == 'expense'
                                    ? Colors.white
                                    : Colors.red.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _transactionType = 'income'),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          _transactionType == 'income'
                              ? Colors.green.shade500
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color:
                              _transactionType == 'income'
                                  ? Colors.white
                                  : Colors.green.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _transactionType == 'income'
                                    ? Colors.white
                                    : Colors.green.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build amount input section
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _amountError != null
                  ? Colors.red.shade400
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return Center(
                      child: Text(
                        currencyService.currentCurrency.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() => _amountError = 'Please enter an amount');
                      return '';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      setState(() => _amountError = 'Please enter a valid amount');
                      return '';
                    }
                    setState(() => _amountError = null);
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        if (_amountError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _amountError!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build category selection - FIXED: Proper scrolling and icon colors
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showCategorySelector,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedCategoryId != null
                        ? _getCategoryName(_selectedCategoryId!)
                        : 'Select category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedCategoryId != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build date selection
  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                FormatUtils.formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build repeat selection
  Widget _buildRepeatSelection() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showRepeatOptions,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(Icons.repeat, color: Theme.of(context).colorScheme.secondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _repeatOption,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Build payment method selection
  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _showPaymentMethodOptions,
            borderRadius: BorderRadius.circular(30),
            child: Row(
              children: [
                Icon(
                  _getPaymentMethodIcon(_paymentMethod),
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _paymentMethod,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build quick note section
  Widget _buildQuickNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _noteController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  widget.transaction != null ? 'Update Transaction' : 'Save Transaction',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  // Essential Helper Methods

  /// Show category selector with simple list layout
  void _showCategorySelector() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories =
        _transactionType == 'income'
            ? provider.incomeCategories
            : provider.expenseCategories;

    debugPrint('Showing category selector for $_transactionType');
    debugPrint('Available categories: ${categories.length}');
    for (var cat in categories) {
      debugPrint('  Category: ${cat.name} (${cat.type}) - ${cat.id}');
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Select Category',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCreateCategoryDialog();
                        },
                        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                        tooltip: 'Add New Category',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                      maxWidth: double.maxFinite,
                    ),
                    child:
                        categories.isEmpty
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 64,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_transactionType categories found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add one to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showCreateCategoryDialog();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Add Category'),
                                ),
                              ],
                            )
                            : ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected =
                                    _selectedCategoryId == category.id;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withValues(alpha: 0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Color(
                                          FormatUtils.parseColorString(
                                            category.color,
                                          ),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getIconData(category.icon),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      category.name,
                                      style: TextStyle(
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            isSelected
                                                ? Theme.of(context).colorScheme.secondary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                    ),
                                    trailing:
                                        isSelected
                                            ? Icon(
                                              Icons.check,
                                              color: Theme.of(context).colorScheme.secondary,
                                            )
                                            : Icon(
                                              Icons.chevron_right,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId = category.id;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Show create category dialog
  void _showCreateCategoryDialog() {
    _categoryNameController.clear();
    _selectedCategoryColor = Colors.blue;
    _selectedCategoryIcon = 'category';

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create Category',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _categoryNameController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Choose Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                            Colors.red,
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.teal,
                          ].map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryColor = color;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border:
                                      _selectedCategoryColor == color
                                          ? Border.all(
                                            color: Theme.of(context).colorScheme.secondary,
                                            width: 3,
                                          )
                                          : Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.2),
                                            width: 1,
                                          ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _createCustomCategory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// Create custom category
  void _createCustomCategory() async {
    if (_categoryNameController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'Please enter a category name',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final categoryId = DateTime.now().millisecondsSinceEpoch.toString();

      final category = models.Category(
        id: categoryId,
        name: _categoryNameController.text.trim(),
        icon: _selectedCategoryIcon,
        color:
            '0x${_selectedCategoryColor.toARGB32().toRadixString(16).toUpperCase()}',
        type: _transactionType,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addCategory(category);

      if (mounted) {
        setState(() {
          _selectedCategoryId = categoryId;
        });

        Navigator.pop(context);
        CustomSnackBar.show(
          context: context,
          message: 'Category created successfully!',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to create category: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Get category name by ID
  String _getCategoryName(String categoryId) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories =
        _transactionType == 'income'
            ? provider.incomeCategories
            : provider.expenseCategories;

    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse:
          () => models.Category(
            id: '',
            name: 'Unknown Category',
            type: 'expense',
            color: 'FF006E1F',
            icon: 'category',
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
    return category.name;
  }

  /// Get or create a default account if none exists
  Future<String> _getOrCreateDefaultAccount(ExpenseProvider provider) async {
    if (provider.accounts.isNotEmpty) {
      return provider.accounts.first.id;
    }

    // Create a default account
    final defaultAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Main Account',
      type: 'cash',
      balance: 0.0,
      color: '#006E1F',
      icon: 'account_balance_wallet',
      isPrimary: true,
      description: 'Default account',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.addAccount(defaultAccount);
    return defaultAccount.id;
  }

  /// Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? const Color(0xFF2B3C29) : Colors.white;
        final onSurface = isDark ? Colors.white : Colors.black87;
        final base = isDark ? ThemeData.dark() : ThemeData.light();
        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: const Color(0xFF006E1F),
              onPrimary: Colors.white,
              secondary: const Color(0xFF006E1F),
              onSecondary: Colors.white,
              surface: surface,
              onSurface: onSurface,
              error: Colors.red,
              onError: Colors.white,
            ),
            dialogTheme: DialogThemeData(backgroundColor: surface),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : const Color(0xFF006E1F),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  DateTime _calculateNextDueDate(DateTime from, String pattern) {
    switch (pattern) {
      case 'Daily':
        return from.add(const Duration(days: 1));
      case 'Weekly':
        return from.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(from.year, from.month + 1, from.day);
      case 'Yearly':
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return from.add(const Duration(days: 1));
    }
  }

  /// Save transaction
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      CustomSnackBar.show(
        context: context,
        message: 'Please select a category',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final notificationService = context.read<NotificationService>();
      final amount = double.parse(_amountController.text);
      final accountId =
          _selectedAccountId ??
          (provider.accounts.isNotEmpty
              ? provider.accounts.first.id
              : await _getOrCreateDefaultAccount(provider));
      final categoryName = _getCategoryName(_selectedCategoryId!);
      final noteText = _noteController.text.trim();
      final isRecurring = _repeatOption != 'Never';

      if (widget.transaction != null) {
        // Edit mode: update existing transaction
        final old = widget.transaction!;
        final updated = trans.Transaction(
          id: old.id,
          amount: amount,
          categoryId: _selectedCategoryId!,
          accountId: accountId,
          type: _transactionType,
          title: noteText.isNotEmpty ? noteText : categoryName,
          description: noteText,
          date: _selectedDate,
          tags: _paymentMethod,
          isRecurring: isRecurring,
          recurringPattern: isRecurring ? _repeatOption.toLowerCase() : null,
          nextDueDate: isRecurring ? _calculateNextDueDate(_selectedDate, _repeatOption) : null,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        );
        await provider.updateTransaction(old, updated);

        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Transaction updated successfully!',
            type: SnackBarType.success,
          );
          Navigator.of(context).pop();
        }
      } else {
        // Add mode: create new transaction
        final transaction = trans.Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          categoryId: _selectedCategoryId!,
          accountId: accountId,
          type: _transactionType,
          title: noteText.isNotEmpty ? noteText : categoryName,
          description: noteText,
          date: _selectedDate,
          tags: _paymentMethod,
          isRecurring: isRecurring,
          recurringPattern: isRecurring ? _repeatOption.toLowerCase() : null,
          nextDueDate: isRecurring ? _calculateNextDueDate(_selectedDate, _repeatOption) : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await provider.addTransaction(
          transaction,
          notificationService: notificationService,
        );

        // Add notification for the new transaction
        if (_transactionType == 'income') {
          await notificationService.addIncomeNotification(
            amount,
            noteText.isEmpty ? categoryName : noteText,
          );
        } else {
          await notificationService.addExpenseNotification(
            amount,
            categoryName,
            noteText.isEmpty ? categoryName : noteText,
          );
        }

        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Transaction saved successfully!',
            type: SnackBarType.success,
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to save transaction: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Get payment method icon
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Credit Card':
        return Icons.credit_card;
      case 'Debit Card':
        return Icons.credit_card_outlined;
      case 'Mobile Money':
        return Icons.phone_android;
      case 'PayPal':
        return Icons.account_balance_wallet;
      case 'Cash':
      default:
        return Icons.payments;
    }
  }

  /// Show payment method selection dialog
  void _showPaymentMethodOptions() {
    final paymentMethods = [
      {'name': 'Cash', 'icon': Icons.payments},
      {'name': 'Credit Card', 'icon': Icons.credit_card},
      {'name': 'Debit Card', 'icon': Icons.credit_card_outlined},
      {'name': 'Mobile Money', 'icon': Icons.phone_android},
      {'name': 'PayPal', 'icon': Icons.account_balance_wallet},
    ];

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payment,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Payment Method',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...paymentMethods.map((method) {
                    final isSelected = _paymentMethod == method['name'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          method['icon'] as IconData,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          method['name'] as String,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                                : Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                        onTap: () {
                          setState(() {
                            _paymentMethod = method['name'] as String;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
    );
  }

  /// Show repeat options dialog
  void _showRepeatOptions() {
    final repeatOptions = ['Never', 'Daily', 'Weekly', 'Monthly', 'Yearly'];

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Repeat Option',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...repeatOptions.map((option) {
                    final isSelected = _repeatOption == option;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getRepeatIcon(option),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        title: Text(
                          option,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                                : Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                        onTap: () {
                          setState(() {
                            _repeatOption = option;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
    );
  }

  /// Get repeat option icon
  IconData _getRepeatIcon(String option) {
    switch (option) {
      case 'Never':
        return Icons.clear;
      case 'Daily':
        return Icons.today;
      case 'Weekly':
        return Icons.calendar_view_week;
      case 'Monthly':
        return Icons.calendar_view_month;
      case 'Yearly':
        return Icons.calendar_today;
      default:
        return Icons.repeat;
    }
  }

  /// Get icon data from string
  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'home': Icons.home,
      'work': Icons.work,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'category': Icons.category,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
