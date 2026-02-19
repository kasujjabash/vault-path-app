import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing Google Mobile Ads configuration and initialization
class AdService {
  // App ID and Ad Unit IDs
  static const String _appId = 'ca-app-pub-7182836201397606~6919734040';
  static const String _bannerAdUnitId =
      'ca-app-pub-7182836201397606/4438309856';

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Get app ID
  static String get appId => _appId;

  /// Get banner ad unit ID
  static String get bannerAdUnitId => _bannerAdUnitId;

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
