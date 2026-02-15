import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/expense_provider.dart';
import '../../models/transaction.dart';
import '../../models/category.dart' as models;
import '../../models/account.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';
import '../../utils/custom_snackbar.dart';

/// Manual input screen with calculator interface for adding transactions
class ManualInputScreen extends StatefulWidget {
  const ManualInputScreen({super.key});

  @override
  State<ManualInputScreen> createState() => _ManualInputScreenState();
}

class _ManualInputScreenState extends State<ManualInputScreen> {
  String _displayAmount = '0';
  String _calculatedAmount = '';
  String _selectedType = 'expense'; // 'income' or 'expense'
  Account? _selectedAccount;
  models.Category? _selectedCategory;
  String _description = '';
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF006E1F), // Dark green
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _canSaveTransaction() ? _saveTransaction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _canSaveTransaction()
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                foregroundColor:
                    _canSaveTransaction()
                        ? AppConstants.primaryColor
                        : Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Amount Display
            Container(
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
                children: [
                  Text(
                    _selectedType == 'income'
                        ? 'Income Amount'
                        : 'Expense Amount',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormatUtils.formatCurrency(
                      double.tryParse(_displayAmount) ?? 0,
                    ),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_calculatedAmount.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _calculatedAmount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Transaction Type Selector
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color:
                              _selectedType == 'expense'
                                  ? AppConstants.errorColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              color:
                                  _selectedType == 'expense'
                                      ? Colors.white
                                      : AppConstants.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expense',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedType == 'expense'
                                        ? Colors.white
                                        : AppConstants.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color:
                              _selectedType == 'income'
                                  ? AppConstants.successColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color:
                                  _selectedType == 'income'
                                      ? Colors.white
                                      : AppConstants.successColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedType == 'income'
                                        ? Colors.white
                                        : AppConstants.successColor,
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

            // Account and Category Selection
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAccountSelection(),
                    _buildCategorySelection(),
                    _buildDescriptionField(),
                  ],
                ),
              ),
            ),

            // Calculator
            _buildCalculator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelection() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (provider.accounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No accounts available. Please add an account first.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                ...provider.accounts.map((account) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          FormatUtils.parseColorString(account.color),
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Color(
                          FormatUtils.parseColorString(account.color),
                        ),
                        size: 20,
                      ),
                    ),
                    title: Text(account.name),
                    subtitle: Text(FormatUtils.formatCurrency(account.balance)),
                    trailing: Radio<Account>(
                      value: account,
                      groupValue: _selectedAccount,
                      onChanged: (Account? value) {
                        setState(() {
                          _selectedAccount = value;
                        });
                      },
                      activeColor: AppConstants.primaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAccount = account;
                      });
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySelection() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              ...provider.categories.map((category) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(
                        FormatUtils.parseColorString(category.color),
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.category,
                      color: Color(
                        FormatUtils.parseColorString(category.color),
                      ),
                      size: 20,
                    ),
                  ),
                  title: Text(category.name),
                  trailing: Radio<models.Category>(
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (models.Category? value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
            'Description (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Enter transaction description...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppConstants.primaryColor),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calculator Label
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Calculator Grid - 4 rows for expense app
          ...List.generate(4, (rowIndex) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(4, (colIndex) {
                  final button = _getCalculatorButton(rowIndex, colIndex);
                  if (button.isEmpty) return const SizedBox.shrink();

                  // Special handling for 0 button (spans two columns)
                  if (button == '0' && rowIndex == 3) {
                    return Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildCalculatorButton(button),
                      ),
                    );
                  }

                  // Skip second column for 0 button row
                  if (rowIndex == 3 && colIndex == 1) {
                    return const SizedBox.shrink();
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildCalculatorButton(button),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getCalculatorButton(int row, int col) {
    final buttons = [
      ['C', '/', '*', '⌫'],
      ['7', '8', '9', '+'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '.'],
      ['0', '', '', '='],
    ];

    // Handle special cases for clean layout
    if (row == 3 && col >= 2) {
      if (col == 2) return '3';
      if (col == 3) return '.';
    }

    if (row == 3 && col == 3) return '.';
    if (row == 4 && col >= 1 && col <= 2) return ''; // Empty for 0 button span
    if (row == 4 && col == 3) return '=';

    return buttons[row][col];
  }

  Widget _buildCalculatorButton(String text) {
    final isOperator = ['+', '-', '*', '/', '='].contains(text);
    final isClear = text == 'C';
    final isDelete = text == '⌫';
    final isEquals = text == '=';
    final isNumber = RegExp(r'^[0-9.]$').hasMatch(text);

    Color buttonColor;
    Color textColor;
    double fontSize = 24;
    FontWeight fontWeight = FontWeight.w600;

    if (isEquals) {
      buttonColor = AppConstants.primaryColor;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isOperator && !isEquals) {
      buttonColor = AppConstants.primaryColor.withOpacity(0.1);
      textColor = AppConstants.primaryColor;
      fontWeight = FontWeight.bold;
    } else if (isClear) {
      buttonColor = Colors.red.shade50;
      textColor = Colors.red.shade600;
      fontWeight = FontWeight.bold;
    } else if (isDelete) {
      buttonColor = Colors.orange.shade50;
      textColor = Colors.orange.shade600;
      fontSize = 22;
    } else if (isNumber) {
      buttonColor = const Color(0xFFF8F9FA);
      textColor = const Color(0xFF2D3436);
    } else {
      buttonColor = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
    }

    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleCalculatorInput(text),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isEquals ? AppConstants.primaryColor : Colors.grey.shade200,
              width: isEquals ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCalculatorInput(String input) {
    setState(() {
      if (input == 'C') {
        _displayAmount = '0';
        _calculatedAmount = '';
      } else if (input == '⌫') {
        if (_displayAmount.length > 1) {
          _displayAmount = _displayAmount.substring(
            0,
            _displayAmount.length - 1,
          );
        } else {
          _displayAmount = '0';
        }
      } else if (input == '=') {
        try {
          // Simple calculator logic - replace with proper expression evaluator
          _calculatedAmount = _displayAmount;
          final result = _evaluateExpression(_displayAmount);
          _displayAmount = result.toString();
        } catch (e) {
          _displayAmount = 'Error';
        }
      } else if (['+', '-', '*', '/'].contains(input)) {
        // Handle operators - prevent multiple operators in a row
        if (_displayAmount.isNotEmpty &&
            ![
              '+',
              '-',
              '*',
              '/',
            ].contains(_displayAmount[_displayAmount.length - 1])) {
          _displayAmount += input;
        }
      } else if (input == '.') {
        // Handle decimal point - only one per number
        final lastOperatorIndex = _displayAmount.lastIndexOfAny([
          '+',
          '-',
          '*',
          '/',
        ]);
        final currentNumber =
            lastOperatorIndex == -1
                ? _displayAmount
                : _displayAmount.substring(lastOperatorIndex + 1);

        if (!currentNumber.contains('.')) {
          if (_displayAmount == '0') {
            _displayAmount = '0.';
          } else {
            _displayAmount += '.';
          }
        }
      } else {
        // Handle numbers
        if (_displayAmount == '0' || _displayAmount == 'Error') {
          _displayAmount = input;
        } else {
          _displayAmount += input;
        }
      }
    });
  }

  double _evaluateExpression(String expression) {
    // Simple expression evaluator for basic calculations
    try {
      // Remove any spaces and validate
      expression = expression.replaceAll(' ', '');

      // For now, just return the parsed number if it's a simple number
      if (RegExp(r'^[\d.]+$').hasMatch(expression)) {
        return double.parse(expression);
      }

      // Basic calculator operations - simplified for expense apps
      List<String> operators = ['+', '-', '*', '/'];
      for (String op in operators) {
        if (expression.contains(op)) {
          List<String> parts = expression.split(op);
          if (parts.length == 2) {
            double left = double.parse(parts[0]);
            double right = double.parse(parts[1]);
            switch (op) {
              case '+':
                return left + right;
              case '-':
                return left - right;
              case '*':
                return left * right;
              case '/':
                return right != 0 ? left / right : 0;
            }
          }
        }
      }

      return double.parse(expression);
    } catch (e) {
      return 0.0;
    }
  }

  bool _canSaveTransaction() {
    final amount = double.tryParse(_displayAmount) ?? 0;
    return amount > 0 && _selectedAccount != null && _selectedCategory != null;
  }

  Future<void> _saveTransaction() async {
    if (!_canSaveTransaction()) return;

    try {
      final amount = double.parse(_displayAmount);
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        title: _description.isEmpty ? 'Manual transaction' : _description,
        description: _description.isEmpty ? null : _description,
        categoryId: _selectedCategory!.id,
        accountId: _selectedAccount!.id,
        type: _selectedType,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addTransaction(transaction);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Transaction added successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context,
          'Error adding transaction: ${e.toString()}',
        );
      }
    }
  }
}

// Extension moved outside the class
extension StringExtension on String {
  int lastIndexOfAny(List<String> characters) {
    int lastIndex = -1;
    for (String char in characters) {
      int index = lastIndexOf(char);
      if (index > lastIndex) {
        lastIndex = index;
      }
    }
    return lastIndex;
  }
}
