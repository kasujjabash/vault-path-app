import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/format_utils.dart';
import '../utils/app_constants.dart';

/// Widget displaying a list of recent transactions
/// Shows the most recent transactions with basic details
class RecentTransactionsList extends StatelessWidget {
  final int limit;

  const RecentTransactionsList({super.key, this.limit = 10});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions.take(limit).toList();

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final account = provider.findAccountById(transaction.accountId);
              final category = provider.findCategoryById(
                transaction.categoryId,
              );

              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        category != null
                            ? Color(
                              FormatUtils.parseColorString(category.color),
                            ).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Icon(
                    _getIconData(category?.icon ?? 'category'),
                    color:
                        category != null
                            ? Color(
                              FormatUtils.parseColorString(category.color),
                            )
                            : Colors.grey,
                    size: AppConstants.iconSizeMedium,
                  ),
                ),
                title: Consumer<ExpenseProvider>(
                  builder: (context, provider, child) {
                    final category = provider.findCategoryById(
                      transaction.categoryId,
                    );
                    return Text(
                      category?.name ?? 'Transaction',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                subtitle: Text(
                  '${category?.name ?? 'Unknown'} • ${account?.name ?? 'Unknown'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatUtils.formatCurrencyWithSign(
                        transaction.type == 'income'
                            ? transaction.amount
                            : -transaction.amount,
                        showPositiveSign: true,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                        color:
                            transaction.type == 'income'
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                      ),
                    ),
                    Text(
                      FormatUtils.getRelativeDateString(transaction.date),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: AppConstants.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Build empty state when no transactions exist
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first transaction',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get icon data from icon name string
  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'movie': Icons.movie,
      'receipt': Icons.receipt,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'flight': Icons.flight,
      'face': Icons.face,
      'category': Icons.category,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'attach_money': Icons.attach_money,
      'account_balance_wallet': Icons.account_balance_wallet,
      'account_balance': Icons.account_balance,
      'savings': Icons.savings,
      'credit_card': Icons.credit_card,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
