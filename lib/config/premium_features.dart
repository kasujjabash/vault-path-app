class PremiumFeatures {
  PremiumFeatures._();

  // ============================================================
  // FEATURE IDENTIFIERS (used in-app to gate features)
  // ============================================================
  static const String budgetCreation = 'budget_creation';
  static const String pdfExport = 'pdf_export';
  static const String advancedCharts = 'advanced_charts';
  static const String cloudSync = 'cloud_sync';
  static const String unlimitedCategories = 'unlimited_categories';

  // ============================================================
  // GOOGLE PLAY IN-APP PURCHASE PRODUCT IDs
  // Configure these EXACTLY in Google Play Console under
  // Monetize > Products > Subscriptions / In-app products
  // ============================================================

  /// Monthly subscription — recurring billing every 30 days
  static const String monthlySubscriptionId = 'vault_path_premium_monthly';

  /// Yearly subscription — recurring billing every 12 months
  static const String yearlySubscriptionId = 'vault_path_premium_yearly';

  /// One-time lifetime purchase — no recurring charges
  static const String lifetimePurchaseId = 'vault_path_premium_lifetime';

  // ============================================================
  // DISPLAY NAMES (shown in UI)
  // ============================================================
  static const Map<String, String> featureDisplayNames = {
    budgetCreation: 'Budget Creation',
    pdfExport: 'PDF Export',
    advancedCharts: 'Advanced Charts',
    cloudSync: 'Cloud Sync',
    unlimitedCategories: 'Unlimited Categories',
  };

  // ============================================================
  // PREMIUM BENEFITS LIST (shown in upgrade prompts)
  // ============================================================
  static const List<String> premiumBenefits = [
    'Create unlimited budgets',
    'Export transactions as PDF',
    'Advanced charts (line, bar, daily)',
    'Cloud sync across all devices',
    'Unlimited custom categories',
    'Ad-free experience',
  ];
}
