import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import 'custom_snackbar.dart';

/// Utility class for handling premium feature restrictions
class PremiumUtils {
  /// Show premium feature error message
  static void showPremiumError(BuildContext context, String featureName) {
    final premiumService = PremiumService();
    final message = premiumService.getPremiumFeatureMessage(featureName);

    CustomSnackBar.showError(context, message);
  }

  /// Show Firebase sync error for non-premium users
  static void showFirebaseSyncError(BuildContext context) {
    final premiumService = PremiumService();
    final message = premiumService.getFirebaseSyncErrorMessage();

    CustomSnackBar.showError(context, message);
  }

  /// Check if user can use feature and show error if not
  static bool checkPremiumFeature(BuildContext context, String featureName) {
    final premiumService = PremiumService();

    if (!premiumService.canUsePremiumFeature(featureName)) {
      showPremiumError(context, featureName);
      return false;
    }

    return true;
  }

  /// Check if user can use Firebase sync and show error if not
  static bool checkFirebaseSync(BuildContext context) {
    final premiumService = PremiumService();

    if (!premiumService.canUseFirebaseSync()) {
      showFirebaseSyncError(context);
      return false;
    }

    return true;
  }

  /// Show premium upgrade dialog
  static void showUpgradeDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Premium Feature',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$featureName is only available for premium users.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upgrade to premium to unlock:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text('• Cloud sync across devices'),
                const Text('• Advanced analytics'),
                const Text('• Unlimited categories'),
                const Text('• Priority support'),
                const Text('• Ad-free experience'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to premium screen
                  CustomSnackBar.showInfo(
                    context,
                    'Premium upgrade coming soon!',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006E1F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upgrade Now'),
              ),
            ],
          ),
    );
  }
}
