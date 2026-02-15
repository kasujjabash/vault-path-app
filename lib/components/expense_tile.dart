import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart' as trans;
import '../providers/expense_provider.dart';
import '../utils/format_utils.dart';

/// Reusable expense tile component for displaying transactions
/// Provides consistent design across the app with clean layout
class ExpenseTile extends StatelessWidget {
  final trans.Transaction transaction;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDate;
  final bool showDivider;

  const ExpenseTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.trailing,
    this.showDate = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getCategoryColor(),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Name
                      Consumer<ExpenseProvider>(
                        builder: (context, provider, child) {
                          final category = provider.findCategoryById(
                            transaction.categoryId,
                          );
                          return Text(
                            category?.name ?? 'Transaction',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 4),

                      // Date and Time Row
                      if (showDate)
                        Row(
                          children: [
                            Text(
                              _formatDate(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Amount and Trailing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == 'income' ? '+' : '-'}${FormatUtils.formatCurrency(transaction.amount.abs())}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            transaction.type == 'income'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 4),
                      trailing!,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 80),
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  /// Get category color based on transaction type and category
  Color _getCategoryColor() {
    if (transaction.type == 'income') {
      return Colors.green;
    }

    // Color mapping for different expense categories
    switch (transaction.title.toLowerCase()) {
      case 'food':
      case 'restaurants':
      case 'groceries':
        return Colors.orange;
      case 'transport':
      case 'transportation':
      case 'travel':
        return Colors.blue;
      case 'shopping':
      case 'retail':
        return Colors.purple;
      case 'entertainment':
      case 'fun':
        return Colors.pink;
      case 'health':
      case 'medical':
        return Colors.red;
      case 'education':
        return Colors.indigo;
      case 'bills':
      case 'utilities':
        return Colors.brown;
      case 'electronics':
        return const Color(0xFF006E1F);
      case 'drinks':
        return Colors.amber;
      case 'rent':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  /// Get category icon based on transaction type and category
  IconData _getCategoryIcon() {
    if (transaction.type == 'income') {
      return Icons.trending_up;
    }

    // Icon mapping for different expense categories
    switch (transaction.title.toLowerCase()) {
      case 'food':
      case 'restaurants':
      case 'groceries':
        return Icons.restaurant;
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'travel':
        return Icons.flight;
      case 'shopping':
      case 'retail':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'fun':
        return Icons.movie;
      case 'health':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'bills':
      case 'utilities':
        return Icons.receipt_long;
      case 'electronics':
        return Icons.devices;
      case 'drinks':
        return Icons.local_cafe;
      case 'rent':
        return Icons.home;
      default:
        return Icons.account_balance_wallet;
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  /// Format time for display
  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
