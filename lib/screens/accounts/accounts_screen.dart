import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/format_utils.dart';
import '../../utils/app_constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/dialog_utils.dart';
import '../../models/account.dart';

/// Accounts screen for managing bank accounts and financial accounts
/// This screen will show all accounts with balances and management options
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: const Color(0xFF006E1F), // Dark green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ExpenseProvider>(
                context,
                listen: false,
              ).loadAccounts();
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final accounts = provider.accounts;

          if (accounts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Total Balance Card
              _buildTotalBalanceCard(provider),

              // Accounts List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Container(
                      constraints: const BoxConstraints(
                        maxWidth: double.infinity,
                      ),
                      child: _buildAccountCard(account, provider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Accounts Yet',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first account to start tracking your finances',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _showAddAccountDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(ExpenseProvider provider) {
    final totalBalance = provider.totalBalance;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF006E1F), // Solid dark green
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006E1F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.9),
                size: AppConstants.iconSizeMedium,
              ),
              const SizedBox(width: 12),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            FormatUtils.formatCurrency(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppConstants.fontSizeXXXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.accounts.length} ${provider.accounts.length == 1 ? 'Account' : 'Accounts'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppConstants.fontSizeMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Account account, ExpenseProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Color(
              FormatUtils.parseColorString(account.color),
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          child: Icon(
            _getIconData(account.icon),
            color: Color(FormatUtils.parseColorString(account.color)),
            size: AppConstants.iconSizeLarge,
          ),
        ),
        title: Text(
          account.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeLarge,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.type.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (account.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'PRIMARY',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            if (account.description?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(
                account.description!,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: AppConstants.fontSizeSmall,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FormatUtils.formatCurrency(account.balance),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeLarge,
                    color:
                        account.balance >= 0
                            ? AppConstants.successColor
                            : AppConstants.errorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Balance',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editAccount(account);
                    break;
                  case 'delete':
                    _deleteAccount(account, provider);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        onTap: () {
          _showAccountDetails(account);
        },
      ),
    );
  }

  void _editAccount(Account account) {
    // TODO: Navigate to edit account screen
    CustomSnackBar.showInfo(context, 'Edit account coming soon');
  }

  Future<void> _deleteAccount(Account account, ExpenseProvider provider) async {
    final result = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete "${account.name}"? This action cannot be undone.',
      titleIcon: Icons.delete_outline,
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (result == true) {
      try {
        await provider.deleteAccount(account.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(AppConstants.successAccountDeleted),
              backgroundColor: AppConstants.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'checking';
    String selectedColor = '#6C63FF';
    String selectedIcon = 'account_balance';
    bool isPrimary = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => DialogUtils.createModernDialog(
                  title: 'Add New Account',
                  titleIcon: Icons.add_card,
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DialogUtils.createDialogTextField(
                          controller: nameController,
                          labelText: 'Account Name',
                          hintText: 'e.g., Main Checking',
                          prefixIcon: Icons.account_balance,
                        ),
                        DialogUtils.createDialogDropdown<String>(
                          value: selectedType,
                          labelText: 'Account Type',
                          prefixIcon: Icons.category_outlined,
                          items: const [
                            DropdownMenuItem(
                              value: 'checking',
                              child: Text('Checking'),
                            ),
                            DropdownMenuItem(
                              value: 'savings',
                              child: Text('Savings'),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Text('Credit Card'),
                            ),
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'investment',
                              child: Text('Investment'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                        DialogUtils.createDialogTextField(
                          controller: balanceController,
                          labelText: 'Initial Balance',
                          hintText: '0.00',
                          prefixIcon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                        DialogUtils.createDialogTextField(
                          controller: descriptionController,
                          labelText: 'Description (Optional)',
                          hintText: 'Brief description of the account',
                          prefixIcon: Icons.description_outlined,
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isPrimary,
                                activeColor: AppConstants.primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    isPrimary = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'Set as primary account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    DialogUtils.createSecondaryButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    DialogUtils.createPrimaryButton(
                      text: 'Add Account',
                      icon: Icons.add,
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          CustomSnackBar.showError(
                            context,
                            'Please enter an account name',
                          );
                          return;
                        }

                        final balance =
                            double.tryParse(balanceController.text) ?? 0.0;
                        final account = Account(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          type: selectedType,
                          balance: balance,
                          description:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                          color: selectedColor,
                          icon: selectedIcon,
                          isPrimary: isPrimary,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        final navigator = Navigator.of(context);
                        Provider.of<ExpenseProvider>(context, listen: false)
                            .addAccount(account)
                            .then((_) {
                              if (mounted) {
                                navigator.pop();
                                CustomSnackBar.showSuccess(
                                  context,
                                  'Account added successfully!',
                                );
                              }
                            })
                            .catchError((error) {
                              if (mounted) {
                                CustomSnackBar.showError(
                                  context,
                                  'Error adding account: $error',
                                );
                              }
                            });
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAccountDetails(Account account) {
    showDialog(
      context: context,
      builder:
          (context) => DialogUtils.createModernDialog(
            title: account.name,
            titleIcon: Icons.info_outline,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', account.type.toUpperCase()),
                _buildDetailRow(
                  'Balance',
                  FormatUtils.formatCurrency(account.balance),
                ),
                if (account.description?.isNotEmpty == true)
                  _buildDetailRow('Description', account.description!),
                _buildDetailRow(
                  'Primary Account',
                  account.isPrimary ? 'Yes' : 'No',
                ),
                _buildDetailRow(
                  'Created',
                  FormatUtils.formatDate(account.createdAt),
                ),
              ],
            ),
            actions: [
              DialogUtils.createSecondaryButton(
                text: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              DialogUtils.createPrimaryButton(
                text: 'Edit',
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).pop();
                  CustomSnackBar.showInfo(
                    context,
                    'Edit account feature coming soon!',
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'account_balance': Icons.account_balance,
      'account_balance_wallet': Icons.account_balance_wallet,
      'savings': Icons.savings,
      'credit_card': Icons.credit_card,
      'attach_money': Icons.attach_money,
      'paid': Icons.paid,
      'wallet': Icons.wallet,
    };
    return iconMap[iconName] ?? Icons.account_balance_wallet;
  }
}
