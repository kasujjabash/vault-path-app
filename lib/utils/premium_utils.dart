import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import '../config/premium_features.dart';
import '../screens/more/premium_screen.dart';
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

  /// Show premium slide-in bottom sheet
  static void showPremiumBottomSheet(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF006E1F).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond,
                color: Color(0xFF006E1F),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$featureName is Premium',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Vault Path Premium to unlock this feature and more.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...PremiumFeatures.premiumBenefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF006E1F),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(benefit, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showPremiumScreen(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006E1F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upgrade to Premium',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
