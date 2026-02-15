import 'package:flutter/material.dart';
import '../utils/format_utils.dart';
import '../utils/app_constants.dart';

/// Summary card widget for displaying financial metrics
/// Shows income, expenses, and other key financial data with icons and colors
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isIncome;
  final Color? textColor;
  final bool isTransparent;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isIncome,
    this.textColor,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;
    final subtitleColor =
        textColor?.withValues(alpha: 0.8) ?? Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          isTransparent
              ? null
              : BoxDecoration(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      textColor != null
                          ? Colors.white.withValues(alpha: 0.2)
                          : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? color,
                  size: AppConstants.iconSizeMedium,
                ),
              ),
              const Spacer(),
              Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color:
                    textColor ??
                    (isIncome
                        ? AppConstants.successColor
                        : AppConstants.errorColor),
                size: AppConstants.iconSizeSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: subtitleColor,
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FormatUtils.formatCurrency(amount),
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
