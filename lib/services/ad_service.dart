import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Google Mobile Ads configuration and initialization
class AdService {
  // Debug flag - set to false for production
  static const bool _isDebug = false; // Changed to false for real ads

  // App ID and Ad Unit IDs
  static const String _appId = 'ca-app-pub-7182836201397606~6919734040';

  // Test ad unit IDs (always work for testing)
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Production ad unit IDs
  static const String _prodBannerAdUnitId =
      'ca-app-pub-7182836201397606/4438309856';

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('Mobile Ads SDK initialized');
  }

  /// Get app ID
  static String get appId => _appId;

  /// Get banner ad unit ID (test ID in debug mode, production ID in release)
  static String get bannerAdUnitId {
    if (_isDebug || kDebugMode) {
      debugPrint('Using test banner ad unit ID for development');
      return _testBannerAdUnitId;
    } else {
      debugPrint('Using production banner ad unit ID');
      return _prodBannerAdUnitId;
    }
  }

  /// Update request configuration
  static RequestConfiguration get requestConfiguration => RequestConfiguration(
    testDeviceIds: [], // Add test device IDs here for testing
    maxAdContentRating: MaxAdContentRating.g,
  );

  /// Configure request settings
  static void configureAds() {
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  }
}
