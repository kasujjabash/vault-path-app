import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/transaction.dart';
import '../utils/format_utils.dart';
import '../utils/custom_snackbar.dart';

/// Enhanced transaction list item with swipe-to-delete functionality
/// Simple design matching screenshot layout
class SwipeableTransactionItem extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onDeleted;

  const SwipeableTransactionItem({
    super.key,
    required this.transaction,
    this.onDeleted,
  });

  @override
  State<SwipeableTransactionItem> createState() =>
      _SwipeableTransactionItemState();
}

class _SwipeableTransactionItemState extends State<SwipeableTransactionItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Handle swipe to delete with confirmation only
  Future<bool> _confirmDismiss(DismissDirection direction) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Transaction',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            widget.transaction.type == 'expense'
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color:
                              widget.transaction.type == 'expense'
                                  ? Colors.red.shade200
                                  : Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.transaction.type == 'expense'
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        color:
                            widget.transaction.type == 'expense'
                                ? Colors.red.shade600
                                : Colors.green.shade600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.transaction.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FormatUtils.formatCurrency(
                              widget.transaction.amount,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.transaction.type == 'expense'
                                      ? Colors.red.shade600
                                      : Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'This action cannot be undone. The amount will be adjusted in your balance.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    // Return the user's choice - true will trigger onDismissed callback
    // false will reset the dismissible to original position
    return shouldDelete ?? false;
  }

  /// Perform the actual deletion and return success status
  Future<bool> _performDeletion() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      // Perform deletion and wait for it to complete
      final success = await provider.deleteTransactionWithFeedback(
        widget.transaction,
      );

      if (mounted && success) {
        // Delay the UI update slightly to ensure database operations complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Call onDeleted callback to update parent list
        widget.onDeleted?.call();

        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Transaction deleted successfully',
            type: SnackBarType.success,
          );
        }

        return true;
      } else if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to delete transaction',
          type: SnackBarType.error,
        );
        return false;
      }

      return success;
    } catch (e) {
      debugPrint('Error performing deletion: $e');
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error deleting transaction',
          type: SnackBarType.error,
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final category = provider.findCategoryById(widget.transaction.categoryId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(widget.transaction.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: _confirmDismiss,
        onDismissed: (direction) async {
          // This callback is called when the dismiss animation completes
          // Now perform the actual deletion
          debugPrint('Transaction dismissed: ${widget.transaction.id}');
          await _performDeletion();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 24),
              SizedBox(height: 2),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTransactionIcon(category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category?.name ?? 'Transaction',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.formatDate(widget.transaction.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.transaction.type == 'expense'
                            ? '- ${FormatUtils.formatCurrency(widget.transaction.amount)}'
                            : '+ ${FormatUtils.formatCurrency(widget.transaction.amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.transaction.type == 'expense'
                                  ? Colors.red.shade600
                                  : Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.formatTime(widget.transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            ],
          ),
        ),
      ),
    );
  }

  /// Build transaction icon based on type and category
  Widget _buildTransactionIcon(dynamic category) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    if (widget.transaction.type == 'expense') {
      iconData = Icons.remove_circle_outline;
      iconColor = Colors.red.shade600;
      backgroundColor = Colors.red.shade50;
    } else {
      iconData = Icons.add_circle_outline;
      iconColor = Colors.green.shade600;
      backgroundColor = Colors.green.shade50;
    }

    // Try to use category icon if available
    if (category != null) {
      try {
        iconColor = Color(FormatUtils.parseColorString(category.color));
        backgroundColor = iconColor.withOpacity(0.1);

        // Map category icon names to IconData
        switch (category.icon.toLowerCase()) {
          case 'restaurant':
          case 'food':
            iconData = Icons.restaurant;
            break;
          case 'directions_car':
          case 'car':
            iconData = Icons.directions_car;
            break;
          case 'shopping_bag':
          case 'shopping':
            iconData = Icons.shopping_bag;
            break;
          case 'movie':
          case 'entertainment':
            iconData = Icons.movie;
            break;
          case 'receipt':
          case 'bills':
            iconData = Icons.receipt;
            break;
          case 'local_hospital':
          case 'health':
            iconData = Icons.local_hospital;
            break;
          case 'school':
          case 'education':
            iconData = Icons.school;
            break;
          case 'flight':
          case 'travel':
            iconData = Icons.flight;
            break;
          case 'work':
            iconData = Icons.work;
            break;
          case 'laptop':
            iconData = Icons.laptop;
            break;
          case 'trending_up':
            iconData = Icons.trending_up;
            break;
          default:
            iconData = Icons.category;
        }
      } catch (e) {
        // Keep default colors if category color parsing fails
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
}
