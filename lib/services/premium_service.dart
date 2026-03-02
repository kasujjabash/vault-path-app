import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium Service
/// Manages premium user status and restrictions
class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _premiumKey = 'is_premium_user';
  bool _isPremium = false;
  bool _isInitialized = false;

  // Getters
  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;

  /// Initialize premium service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      _isInitialized = true;
      debugPrint('PremiumService initialized - isPremium: $_isPremium');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize PremiumService: $e');
      _isInitialized = true;
    }
  }

  /// Set premium status
  Future<void> setPremium(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, value);
      _isPremium = value;
      debugPrint('Premium status updated: $_isPremium');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set premium status: $e');
    }
  }

  /// Check if Firebase sync is allowed
  bool canUseFirebaseSync() {
    if (!_isInitialized) return false;
    return _isPremium;
  }

  /// Get error message for non-premium users trying to use Firebase sync
  String getFirebaseSyncErrorMessage() {
    return 'Cloud sync is a premium feature. Upgrade to premium to sync your data across devices. Your data is still safely stored locally on this device.';
  }

  /// Check if user can use premium feature
  bool canUsePremiumFeature(String featureName) {
    if (!_isInitialized) return false;
    return _isPremium;
  }

  /// Get premium feature restriction message
  String getPremiumFeatureMessage(String featureName) {
    return '$featureName is a premium feature. Upgrade to premium to unlock this functionality.';
  }

  /// Simulate premium purchase (for testing)
  Future<void> simulatePremiumUpgrade() async {
    debugPrint('Simulating premium upgrade...');
    await setPremium(true);
  }

  /// Reset to free tier (for testing)
  Future<void> resetToFreeTier() async {
    debugPrint('Resetting to free tier...');
    await setPremium(false);
  }
}
