import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';

/// Utility class for formatting currency, dates, and other data
/// This class provides consistent formatting throughout the app
class FormatUtils {
  // Date formatters
  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormatter = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormatter = DateFormat(
    'MMM dd, yyyy hh:mm a',
  );
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormatter = DateFormat('dd/MM/yyyy');

  /// Format amount as currency string
  static String formatCurrency(double amount, [Currency? currency]) {
    final currentCurrency = currency ?? CurrencyService().currentCurrency;
    final formatter = NumberFormat.currency(
      symbol: currentCurrency.symbol,
      decimalDigits:
          currentCurrency.code == 'UGX' ? 0 : 2, // UGX doesn't use decimals
    );
    return formatter.format(amount);
  }

  /// Format amount as currency string with specific currency
  static String formatCurrencyWithCurrency(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: currency.code == 'UGX' ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Format amount as currency string with optional sign
  static String formatCurrencyWithSign(
    double amount, {
    Currency? currency,
    bool showPositiveSign = false,
  }) {
    final currentCurrency = currency ?? CurrencyService().currentCurrency;
    final formatter = NumberFormat.currency(
      symbol: currentCurrency.symbol,
      decimalDigits: currentCurrency.code == 'UGX' ? 0 : 2,
    );

    final formatted = formatter.format(amount.abs());
    if (amount > 0 && showPositiveSign) {
      return '+$formatted';
    } else if (amount < 0) {
      return '-$formatted';
    }
    return formatted;
  }

  /// Format date as readable string
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Format time as readable string
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Format date and time as readable string
  static String formatDateTime(DateTime date) {
    return _dateTimeFormatter.format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return _monthYearFormatter.format(date);
  }

  /// Format date in short format
  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  /// Get relative date string (Today, Yesterday, etc.)
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else if (inputDate == tomorrow) {
      return 'Tomorrow';
    } else if (inputDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day of week
    } else {
      return formatDate(date);
    }
  }

  /// Format number with K, M suffixes for large numbers
  static String formatCompactNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Format account type for display
  static String formatAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return 'Checking Account';
      case 'savings':
        return 'Savings Account';
      case 'credit':
        return 'Credit Card';
      case 'cash':
        return 'Cash';
      case 'investment':
        return 'Investment Account';
      default:
        return capitalize(type);
    }
  }

  /// Format transaction type for display
  static String formatTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'expense':
        return 'Expense';
      case 'income':
        return 'Income';
      case 'transfer':
        return 'Transfer';
      default:
        return capitalize(type);
    }
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get month name from month number
  static String getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  /// Get short month name from month number
  static String getShortMonthName(int month) {
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
    return months[month - 1];
  }

  /// Parse color string to Color object - FIXED: Handle various formats safely
  static int parseColorString(String? colorString) {
    // Return default green color if string is null or empty
    if (colorString == null || colorString.isEmpty) {
      return 0xFF006E1F; // Default green color
    }

    // Clean the color string
    String cleanString = colorString.trim();

    // Remove common prefixes and handle malformed formats
    if (cleanString.startsWith('#')) {
      cleanString = cleanString.substring(1);
    } else if (cleanString.startsWith('0x') || cleanString.startsWith('0X')) {
      cleanString = cleanString.substring(2);
    } else if (cleanString.startsWith('x') || cleanString.startsWith('X')) {
      // Handle malformed "x" prefix (should be "0x")
      cleanString = cleanString.substring(1);
    }

    // Ensure we have a valid hex string
    if (cleanString.isEmpty) {
      return 0xFF006E1F; // Default green color
    }

    // Add FF for alpha if not present (6 digit hex)
    if (cleanString.length == 6) {
      cleanString = 'FF$cleanString';
    } else if (cleanString.length == 8) {
      // Already has alpha channel
    } else if (cleanString.length == 7) {
      // Likely missing a leading zero, try to fix by adding one
      cleanString = '0$cleanString';
    } else {
      // Invalid length, return default
      return 0xFF006E1F; // Default green color
    }

    // Validate that all characters are valid hex
    final RegExp hexPattern = RegExp(r'^[0-9A-Fa-f]+$');
    if (!hexPattern.hasMatch(cleanString)) {
      return 0xFF006E1F; // Default green color
    }

    try {
      return int.parse(cleanString, radix: 16);
    } catch (e) {
      // If parsing still fails, return default color
      return 0xFF006E1F; // Default green color
    }
  }

  /// Convert Color to hex string
  static String colorToHex(int color) {
    return '#${color.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Format amount as compact currency string for charts
  static String formatCurrencyCompact(double amount) {
    final currency = CurrencyService().currentCurrency;

    if (amount == 0) return '${currency.symbol}0';

    if (amount >= 1000000) {
      return '${currency.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${currency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '${currency.symbol}${amount.toStringAsFixed(0)}';
    }
  }
}

/// Reactive currency display widget that automatically updates when currency changes
class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool showSign;

  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.style,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
        final formattedAmount =
            showSign
                ? FormatUtils.formatCurrencyWithSign(
                  amount,
                  currency: currencyService.currentCurrency,
                )
                : FormatUtils.formatCurrencyWithCurrency(
                  amount,
                  currencyService.currentCurrency,
                );

        return Text(formattedAmount, style: style);
      },
    );
  }
}
