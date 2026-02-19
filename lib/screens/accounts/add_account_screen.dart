import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/account.dart';
import '../../providers/expense_provider.dart';
import '../../services/currency_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';

/// Add Account Screen for creating new accounts
/// Allows users to create various types of financial accounts
class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedAccountType = AppConstants.accountTypeChecking;
  Color _selectedColor = AppConstants.primaryColor;
  Currency? _selectedCurrency; // Will be set in initState
  bool _isLoading = false;

  // Available account types
  final List<Map<String, dynamic>> _accountTypes = [
    {
      'value': AppConstants.accountTypeChecking,
      'label': 'Checking Account',
      'icon': Icons.account_balance,
    },
    {
      'value': AppConstants.accountTypeSavings,
      'label': 'Savings Account',
      'icon': Icons.savings,
    },
    {
      'value': AppConstants.accountTypeCredit,
      'label': 'Credit Card',
      'icon': Icons.credit_card,
    },
    {
      'value': AppConstants.accountTypeCash,
      'label': 'Cash',
      'icon': Icons.money,
    },
    {
      'value': AppConstants.accountTypeInvestment,
      'label': 'Investment',
      'icon': Icons.trending_up,
    },
  ];

  // Available colors
  final List<Color> _availableColors = [
    AppConstants.primaryColor,
    AppConstants.accentColor,
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF673AB7), // Deep Purple
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    // Set USD as default currency
    setState(() {
      _selectedCurrency = Currency.usd; // Default to USD
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Get icon name for account type
  String _getIconForAccountType(String accountType) {
    switch (accountType) {
      case 'checking':
        return 'account_balance';
      case 'savings':
        return 'savings';
      case 'credit':
        return 'credit_card';
      case 'cash':
        return 'money';
      case 'investment':
        return 'trending_up';
      default:
        return 'account_balance_wallet';
    }
  }

  /// Save the new account
  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      final account = Account(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedAccountType,
        balance: double.tryParse(_balanceController.text.trim()) ?? 0.0,
        color: '0x${_selectedColor.toARGB32().toRadixString(16).toUpperCase()}',
        description: _descriptionController.text.trim(),
        icon: _getIconForAccountType(_selectedAccountType),
        isPrimary: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addAccount(account);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.successAccountAdded),
            backgroundColor: AppConstants.successColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Error saving account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving account: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
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
        title: const Text('Add Account'),
        backgroundColor: const Color(0xFF006E1F), // Dark green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAccount,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Name
              _buildSection(
                title: 'Account Name',
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Chase Checking',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppConstants.errorEmptyField;
                    }
                    if (value.trim().length > AppConstants.maxNameLength) {
                      return 'Name must be ${AppConstants.maxNameLength} characters or less';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
              ),

              const SizedBox(height: 24),

              // Account Type
              _buildSection(
                title: 'Account Type',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children:
                        _accountTypes.map((type) {
                          final isSelected =
                              _selectedAccountType == type['value'];
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppConstants.primaryColor.withOpacity(
                                        0.1,
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: Icon(
                                type['icon'] as IconData,
                                color:
                                    isSelected
                                        ? AppConstants.primaryColor
                                        : Colors.grey.shade600,
                              ),
                              title: Text(
                                type['label'] as String,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  color:
                                      isSelected
                                          ? AppConstants.primaryColor
                                          : Colors.grey.shade800,
                                ),
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check_circle,
                                        color: AppConstants.primaryColor,
                                      )
                                      : null,
                              onTap: () {
                                setState(() {
                                  _selectedAccountType =
                                      type['value'] as String;
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Initial Balance
              _buildSection(
                title: 'Initial Balance',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(
                        hintText:
                            _selectedCurrency != null
                                ? '0${_selectedCurrency!.code == 'UGX' ? '' : '.00'}'
                                : '0',
                        prefixIcon: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Text(
                            _selectedCurrency?.symbol ?? 'UGX',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        labelText: 'Amount',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final amount = double.tryParse(value.trim());
                          if (amount == null) {
                            return AppConstants.errorInvalidAmount;
                          }
                          if (amount > AppConstants.maxAmount) {
                            return 'Amount cannot exceed ${FormatUtils.formatCurrency(AppConstants.maxAmount)}';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<CurrencyService>(
                      builder: (context, currencyService, child) {
                        return DropdownButtonFormField<Currency>(
                          initialValue: _selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            prefixIcon: Icon(Icons.monetization_on),
                          ),
                          items:
                              currencyService.supportedCurrencies.map((
                                currency,
                              ) {
                                return DropdownMenuItem<Currency>(
                                  value: currency,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color:
                                              currency.code == 'UGX'
                                                  ? Colors.green.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.blue.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          currency.symbol,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color:
                                                currency.code == 'UGX'
                                                    ? Colors.green.shade700
                                                    : Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${currency.code} - ${currency.name}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (Currency? newCurrency) {
                            setState(() {
                              _selectedCurrency = newCurrency;
                            });
                            // Update the currency service as well
                            if (newCurrency != null) {
                              currencyService.setCurrency(newCurrency);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select currency';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Color
              _buildSection(
                title: 'Account Color',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Selected Color',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            _availableColors.map((color) {
                              final isSelected = _selectedColor == color;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade300,
                                      width: isSelected ? 3 : 2,
                                    ),
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                          : null,
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description (Optional)
              _buildSection(
                title: 'Description (Optional)',
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Add notes about this account...',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                  maxLength: AppConstants.maxDescriptionLength,
                  validator: (value) {
                    if (value != null &&
                        value.trim().length >
                            AppConstants.maxDescriptionLength) {
                      return 'Description must be ${AppConstants.maxDescriptionLength} characters or less';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
