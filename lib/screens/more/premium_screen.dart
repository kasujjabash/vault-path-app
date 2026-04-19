import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/premium_features.dart';
import '../../services/premium_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/custom_snackbar.dart';

/// Premium subscription screen for Vault Path Premium
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'yearly';
  late bool _wasPremium;

  @override
  void initState() {
    super.initState();
    _wasPremium = PremiumService().isPremium;
  }

  final List<Map<String, dynamic>> _premiumFeatures = [
    {'icon': Icons.all_inclusive, 'title': 'Unlimited budgets & savings goals'},
    {'icon': Icons.sync, 'title': 'Cloud sync across all devices'},
    {'icon': Icons.bar_chart, 'title': 'Advanced charts & analytics'},
    {'icon': Icons.picture_as_pdf, 'title': 'Export transactions as PDF'},
    {'icon': Icons.block, 'title': 'Ad-free experience'},
    {'icon': Icons.favorite, 'title': 'Support a Uganda developer'},
  ];

  final List<Map<String, dynamic>> _pricingOptions = [
    {
      'id': 'monthly',
      'productId': PremiumFeatures.monthlySubscriptionId,
      'fallbackPrice': 'Loading...',
      'period': 'Monthly',
      'description': 'Billed monthly',
    },
    {
      'id': 'yearly',
      'productId': PremiumFeatures.yearlySubscriptionId,
      'fallbackPrice': 'Loading...',
      'period': 'Yearly',
      'description': 'Billed annually • Save 40%',
      'popular': true,
    },
    {
      'id': 'lifetime',
      'productId': PremiumFeatures.lifetimePurchaseId,
      'fallbackPrice': 'Loading...',
      'period': 'Lifetime',
      'description': 'Pay once, own forever',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PremiumService>(
      builder: (context, premiumService, child) {
        // Auto-close sheet when purchase completes
        if (premiumService.isPremium && !_wasPremium) {
          _wasPremium = premiumService.isPremium;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
              CustomSnackBar.showSuccess(context, 'Welcome to Vault Path Premium!');
            }
          });
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                  color: isDark ? Colors.white38 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildFeaturesList(),
                      const SizedBox(height: 28),
                      _buildPricingOptions(premiumService),
                      const SizedBox(height: 8),

                      // Error message
                      if (premiumService.purchaseError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            premiumService.purchaseError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      _buildBottomActions(premiumService),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF006E1F), Color(0xFF00A040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          child: const Icon(Icons.diamond, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Vault Path Premium',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF006E1F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Unlock the full experience',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you get',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        ..._premiumFeatures.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    f['icon'] as IconData,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    f['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOptions(PremiumService premiumService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your plan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        ..._pricingOptions.map((option) {
          final product = premiumService.getProduct(option['id'] as String);
          final price = product?.price ?? option['fallbackPrice'] as String;
          final isSelected = _selectedPlan == option['id'];
          final isPopular = option['popular'] == true;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = option['id'] as String),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF006E1F).withValues(alpha: 0.06)
                    : (isDark
                        ? Theme.of(context).colorScheme.surface
                        : Colors.white),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF006E1F)
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Radio
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF006E1F)
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF006E1F),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              option['period'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006E1F),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'POPULAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActions(PremiumService premiumService) {
    final isLoading = premiumService.isPurchasing;

    return Column(
      children: [
        // Subscribe button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handleSubscribe(premiumService),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006E1F),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF006E1F).withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Close
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
          child: const Text(
            'Maybe Later',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _handleSubscribe(PremiumService premiumService) async {
    // If store products aren't loaded yet, try loading them first
    if (premiumService.products.isEmpty && premiumService.isStoreAvailable) {
      await premiumService.loadProducts();
    }

    // Attempt purchase
    await premiumService.purchasePlan(_selectedPlan);
  }
}

/// Show the premium screen as a modal bottom sheet
void showPremiumScreen(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const PremiumScreen(),
  );
}
