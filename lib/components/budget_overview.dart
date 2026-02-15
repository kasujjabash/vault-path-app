import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/format_utils.dart';
import '../utils/app_constants.dart';

/// Budget overview widget showing budget progress
/// Displays active budgets with spending progress and alerts
class BudgetOverview extends StatelessWidget {
  const BudgetOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final budgets = provider.activeBudgets.take(3).toList();

        if (budgets.isEmpty) {
          return _buildEmptyState(context);
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
          child: Column(
            children:
                budgets.map((budget) {
                  final category = provider.findCategoryById(budget.categoryId);
                  return _buildBudgetItem(context, budget, category);
                }).toList(),
          ),
        );
      },
    );
  }

  /// Build individual budget item
  Widget _buildBudgetItem(BuildContext context, budget, category) {
    final progress = budget.progressPercentage;
    final isNearLimit = budget.isNearLimit;
    final isExceeded = budget.isExceeded;

    Color progressColor = AppConstants.successColor;
    if (isExceeded) {
      progressColor = AppConstants.errorColor;
    } else if (isNearLimit) {
      progressColor = AppConstants.warningColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                          ? Color(FormatUtils.parseColorString(category.color))
                          : Colors.grey,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${FormatUtils.formatCurrency(budget.spent)} of ${FormatUtils.formatCurrency(budget.amount)}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                FormatUtils.formatPercentage(progress),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
          if (isExceeded || isNearLimit) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isExceeded ? Icons.warning : Icons.info,
                  size: AppConstants.iconSizeSmall,
                  color: progressColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isExceeded
                      ? 'Budget exceeded by ${FormatUtils.formatCurrency(budget.spent - budget.amount)}'
                      : 'Close to budget limit',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: progressColor,
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

  /// Build empty state when no budgets exist
  Widget _buildEmptyState(BuildContext context) {
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
            Icons.track_changes_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets set',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create budgets to track your spending',
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
