import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_constants.dart';
import '../../utils/custom_snackbar.dart';
import '../../theme/app_theme.dart';

/// Screen for choosing different account creation methods
/// Includes bank sync, investments, file import, and manual input options
class ChooseAccountScreen extends StatelessWidget {
  const ChooseAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Add Account',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Choose Account Type',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you\'d like to add your account',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Bank Sync Option
              _buildAccountOption(
                context,
                title: 'Bank Sync',
                description:
                    'Automatically sync transactions from your bank account. Secure and up-to-date.',
                icon: Icons.account_balance,
                isPremium: true,
                onTap: () => _showUpgradeDialog(context, 'Bank Sync'),
              ),

              const SizedBox(height: 16),

              // Investments Option
              _buildAccountOption(
                context,
                title: 'Investments',
                description:
                    'Track your investment portfolios, stocks, and other financial instruments.',
                icon: Icons.trending_up,
                isPremium: true,
                onTap: () => _showUpgradeDialog(context, 'Investment Tracking'),
              ),

              const SizedBox(height: 16),

              // File Import Option
              _buildAccountOption(
                context,
                title: 'File Import',
                description:
                    'Import your transaction history from CSV, Excel, or bank statement files.',
                icon: Icons.upload_file,
                isPremium: true,
                onTap: () => _showUpgradeDialog(context, 'File Import'),
              ),

              const SizedBox(height: 16),

              // Manual Input Option
              _buildAccountOption(
                context,
                title: 'Manual Input',
                description:
                    'Create an account manually and add transactions using our calculator.',
                icon: Icons.edit,
                isPremium: false,
                onTap: () => context.push('/manual-input'),
              ),

              const SizedBox(height: 32),

              // Quick Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/add-account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Add Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isPremium,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isPremium
                  ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  )
                  : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isPremium
                        ? AppColors.primary.withOpacity(0.1)
                        : AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color:
                    isPremium ? AppColors.primary : AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text('Upgrade to Pro'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$feature is a premium feature.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock Pro features:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('🏦 Bank account synchronization'),
              _buildFeatureItem('📈 Investment portfolio tracking'),
              _buildFeatureItem('📁 File import capabilities'),
              _buildFeatureItem('📊 Advanced analytics & reports'),
              _buildFeatureItem('♾️ Unlimited accounts & categories'),
              _buildFeatureItem('☁️ Cloud sync across devices'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to upgrade screen
                CustomSnackBar.showInfo(
                  context,
                  'Upgrade feature coming soon!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    );
  }
}
