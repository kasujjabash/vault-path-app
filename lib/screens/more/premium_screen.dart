import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

/// Premium subscription screen for Vault Path Premium
/// Displays subscription options with features and pricing
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'yearly'; // Default to yearly plan

  final List<Map<String, dynamic>> _premiumFeatures = [
    {'icon': Icons.all_inclusive, 'title': 'Unlimited access'},
    {'icon': Icons.block, 'title': 'Ad free experience'},
    {'icon': Icons.favorite, 'title': 'Support a Uganda dev'},
    {'icon': Icons.priority_high, 'title': 'Priority support'},
  ];

  final List<Map<String, dynamic>> _pricingOptions = [
    {
      'id': 'monthly',
      'price': '\$1.09',
      'period': 'Monthly',
      'description': 'Billed monthly',
    },
    {
      'id': 'yearly',
      'price': '\$7.99',
      'period': 'Yearly',
      'description': 'Billed annually • Save 40%',
      'popular': true,
    },
    {
      'id': 'lifetime',
      'price': '\$17.99',
      'period': 'Lifetime',
      'description': 'Pay once, own forever',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.borderRadiusLarge),
          topRight: Radius.circular(AppConstants.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white54 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Entire content scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Content
                  Padding(
                    padding: AppConstants.paddingMedium,
                    child: Column(
                      children: [
                        // Features list
                        _buildFeaturesList(),
                        const SizedBox(height: 32),

                        // Pricing options
                        _buildPricingOptions(),
                        const SizedBox(height: 24),

                        // Bottom action buttons
                        _buildBottomActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: AppConstants.paddingMedium,
      child: Column(
        children: [
          // Premium icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryColor, Color(0xFF00A040)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
            child: const Icon(
              Icons.diamond,
              size: AppConstants.iconSizeLarge,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Vault Path Premium',
            style: TextStyle(
              fontSize: AppConstants.fontSizeXXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Subscribe to get the full experience',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),

        ..._premiumFeatures.map(
          (feature) =>
              _buildFeatureItem(icon: feature['icon'], title: feature['title']),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryColor,
              size: AppConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),

        ..._pricingOptions.map((option) => _buildPricingOption(option)),
      ],
    );
  }

  Widget _buildPricingOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedPlan == option['id'];
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = option['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? theme.colorScheme.surface : Colors.white,
          border: Border.all(
            color:
                isSelected
                    ? AppConstants.primaryColor
                    : (isDarkMode
                        ? theme.colorScheme.outline.withOpacity(0.3)
                        : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: (isDarkMode ? Colors.black : Colors.grey)
                          .withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? AppConstants.primaryColor
                          : (isDarkMode
                              ? theme.colorScheme.outline.withOpacity(0.5)
                              : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 16),

            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['price'],
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeXLarge,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option['description'],
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Period
            Text(
              option['period'],
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        // Subscribe button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleSubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
            ),
            child: Text(
              'Subscribe Now',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Maybe Later',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _handleSubscribe() {
    // Handle subscription logic here
    // For now, just show a placeholder
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Subscription'),
            content: Text(
              'Selected plan: $_selectedPlan\n\nSubscription functionality would be implemented here.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

/// Function to show premium screen as modal bottom sheet
void showPremiumScreen(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return const PremiumScreen();
    },
  );
}
