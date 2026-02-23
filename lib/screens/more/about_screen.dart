import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('About Vault Path'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/vault_path_icon.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vault Path',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track Smarter. Spend Wiser.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Introduction
            _buildContentSection(
              context,
              '',
              'Managing money should not feel stressful or confusing. Many people struggle to understand where their money goes because of small daily expenses, forgotten subscriptions, or unplanned spending. Without clear records, building good financial habits becomes difficult.\n\nVault Path was created to solve this challenge.',
            ),

            // The Challenge
            _buildContentSection(
              context,
              'The Challenge',
              'In everyday life, expenses happen quickly — transport, food, bills, and unexpected costs. When spending is not tracked, it becomes easy to lose control of finances without even realizing it. Many existing expense trackers are complicated or require too much setup, which discourages consistency.',
              icon: Icons.warning_amber_outlined,
            ),

            // The Solution
            _buildContentSection(
              context,
              'The Solution',
              'Vault Path provides a simple and practical way to track expenses without complexity. The app helps you record spending quickly, stay organized, and clearly understand your financial habits. By seeing where your money goes, you can make better decisions and plan confidently for the future.',
              icon: Icons.lightbulb_outline,
            ),

            // Features
            _buildContentSection(
              context,
              'What Vault Path Helps You Do',
              '',
              icon: Icons.check_circle_outline,
              features: [
                'Track expenses easily and consistently',
                'Understand your spending habits',
                'Stay organized without complicated tools',
                'Build better financial discipline',
                'Work toward your personal financial goals',
              ],
            ),

            _buildQuoteSection(context),

            // About the App
            _buildContentSection(
              context,
              'About the App',
              'Vault Path is designed with simplicity and focus in mind. The goal is to make expense tracking accessible for everyone, whether you are managing daily spending, saving for something important, or learning to build stronger financial habits.',
              icon: Icons.phone_android,
            ),

            // About the Developer
            _buildContentSection(
              context,
              'About the Developer',
              'Vault Path is built by Bashir Kasujja, a mobile developer passionate about creating simple digital solutions that solve real everyday problems. Through thoughtful design and practical features, the mission is to help people use technology to improve productivity, organization, and financial awareness.',
              icon: Icons.person_outline,
            ),

            // Version Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 8, bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    String title,
    String content, {
    IconData? icon,
    List<String>? features,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primaryDark, size: 24),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (content.isNotEmpty) ...[
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ],

          if (features != null && features.isNotEmpty) ...[
            if (content.isNotEmpty) const SizedBox(height: 16),
            ...features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Vault Path is more than an expense tracker — it is a guide toward smarter financial decisions, one step at a time.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
