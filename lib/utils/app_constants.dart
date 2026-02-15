import 'package:flutter/material.dart';

/// Constants used throughout the application
/// This class contains all the app-wide constants for consistency
class AppConstants {
  // App Information
  static const String appName = 'Budjar';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Modern Expense Tracker';

  // Database
  static const String databaseName = 'budjar.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDarkMode = 'dark_mode';
  static const String keyDefaultCurrency = 'default_currency';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyAutoBackup = 'auto_backup';
  static const String keyPremiumUser = 'premium_user';

  // Transaction Types
  static const String transactionTypeExpense = 'expense';
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeTransfer = 'transfer';

  // Account Types
  static const String accountTypeChecking = 'checking';
  static const String accountTypeSavings = 'savings';
  static const String accountTypeCredit = 'credit';
  static const String accountTypeCash = 'cash';
  static const String accountTypeInvestment = 'investment';

  // Category Types
  static const String categoryTypeExpense = 'expense';
  static const String categoryTypeIncome = 'income';

  // Budget Periods
  static const String budgetPeriodWeekly = 'weekly';
  static const String budgetPeriodMonthly = 'monthly';
  static const String budgetPeriodYearly = 'yearly';

  // Date Ranges for Analytics
  static const String dateRangeToday = 'today';
  static const String dateRangeWeek = 'week';
  static const String dateRangeMonth = 'month';
  static const String dateRangeYear = 'year';
  static const String dateRangeCustom = 'custom';

  // Premium Features
  static const List<String> premiumFeatures = [
    'Unlimited Accounts',
    'Advanced Analytics',
    'Export Data',
    'Cloud Backup',
    'Custom Categories',
    'Budget Alerts',
    'Recurring Transactions',
    'Investment Tracking',
  ];

  // Limits for Free Users
  static const int maxAccountsFree = 3;
  static const int maxCategoriesFree = 10;
  static const int maxBudgetsFree = 5;

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFFEAA7),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
    Color(0xFFF7DC6F),
    Color(0xFFBB8FCE),
    Color(0xFF85C1E9),
    Color(0xFF58D68D),
    Color(0xFFF8C471),
    Color(0xFFF1948A),
    Color(0xFF82E0AA),
    Color(0xFFFF6B6B),
  ];

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Typography
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 32.0;

  // Navigation
  static const List<String> bottomNavItems = [
    'Home',
    'Expense',
    'Budget',
    'Report',
  ];

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorDatabase = 'Database error. Please restart the app.';
  static const String errorInvalidAmount = 'Please enter a valid amount.';
  static const String errorEmptyField = 'This field is required.';
  static const String errorAccountLimit =
      'Free users can only create 3 accounts.';
  static const String errorCategoryLimit =
      'Free users can only create 10 categories.';
  static const String errorBudgetLimit =
      'Free users can only create 5 budgets.';

  // Success Messages
  static const String successTransactionAdded =
      'Transaction added successfully.';
  static const String successTransactionUpdated =
      'Transaction updated successfully.';
  static const String successTransactionDeleted =
      'Transaction deleted successfully.';
  static const String successAccountAdded = 'Account added successfully.';
  static const String successAccountUpdated = 'Account updated successfully.';
  static const String successAccountDeleted = 'Account deleted successfully.';
  static const String successCategoryAdded = 'Category added successfully.';
  static const String successCategoryUpdated = 'Category updated successfully.';
  static const String successCategoryDeleted = 'Category deleted successfully.';
  static const String successBudgetAdded = 'Budget added successfully.';
  static const String successBudgetUpdated = 'Budget updated successfully.';
  static const String successBudgetDeleted = 'Budget deleted successfully.';

  // Validation
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 50;
  static const double maxAmount = 999999999.99;
  static const double minAmount = 0.01;

  // Regular Expressions
  static final RegExp amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
  static final RegExp nameRegex = RegExp(r'^[a-zA-Z0-9\s]+$');

  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  // Premium
  static const double premiumPrice = 4.99;
  static const String premiumPeriod = 'month';

  // Backup
  static const String backupFileExtension = '.budjar';
  static const String exportFileExtension = '.csv';

  // Notifications
  static const String notificationChannelId = 'budjar_notifications';
  static const String notificationChannelName = 'Budjar Notifications';
  static const String notificationChannelDescription =
      'Notifications for budget alerts and reminders';

  // Theme
  static const Color primaryColor = Color(
    0xFF006E1F,
  ); // Dark green for primary elements
  static const Color secondaryColor = Color(
    0xFFD4E5D3,
  ); // Light green for backgrounds
  static const Color accentColor = Color(0xFFE8F6E8); // Very light green accent
  static const Color errorColor = Color(0xFFD32F2F); // Darker red
  static const Color successColor = Color(0xFF006E1F); // Dark green for success
  static const Color warningColor = Color(0xFFFFB74D);

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF00A040);
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkSurfaceColor = Color(0xFF2D2D2D);
  static const Color darkOnSurfaceColor = Color(0xFFE1E1E1);

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightOnSurfaceColor = Color(0xFF1A1A1A);
}
