import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/format_utils.dart';
import '../more/about_screen.dart';

/// Profile screen showing user information and statistics
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF006E1F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<AuthService, ExpenseProvider>(
        builder: (context, authService, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                _buildUserInfoCard(authService),

                const SizedBox(height: 24),

                // Financial Summary Cards that were previously in Analytics
                _buildFinancialSummary(provider),

                const SizedBox(height: 24),

                // Account Statistics
                _buildAccountStats(provider),

                const SizedBox(height: 24),

                // Category Statistics
                _buildCategoryStats(provider),

                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(context, authService),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(AuthService authService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006E1F), Color(0xFF00A040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006E1F).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              (authService.userDisplayName?.isNotEmpty == true)
                  ? authService.userDisplayName![0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            authService.userDisplayName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email
          if (authService.userEmail != null)
            Text(
              authService.userEmail!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),

          const SizedBox(height: 16),

          // Membership Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Free Member',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(ExpenseProvider provider) {
    return FutureBuilder<Map<String, double>>(
      future: _getFinancialSummary(provider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final totalIncome = data['income'] ?? 0.0;
        final totalExpenses = data['expenses'] ?? 0.0;
        final savingsRate =
            totalIncome > 0
                ? ((totalIncome - totalExpenses) / totalIncome)
                : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006E1F),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Monthly Income',
                    FormatUtils.formatCurrency(totalIncome),
                    Icons.trending_up,
                    AppConstants.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Monthly Expenses',
                    FormatUtils.formatCurrency(totalExpenses),
                    Icons.trending_down,
                    AppConstants.errorColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildStatCard(
              'Savings Rate',
              '${(savingsRate * 100).toStringAsFixed(1)}%',
              savingsRate > 0.2 ? Icons.savings : Icons.warning,
              savingsRate > 0.2
                  ? AppConstants.successColor
                  : AppConstants.warningColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountStats(ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAccountStatItem(
                  'Total Accounts',
                  '${provider.accounts.length}',
                  Icons.account_balance,
                ),
              ),
              Expanded(
                child: _buildAccountStatItem(
                  'Total Balance',
                  FormatUtils.formatCurrency(provider.totalBalance),
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAccountStatItem(
                  'Categories',
                  '${provider.categories.length}',
                  Icons.category,
                ),
              ),
              Expanded(
                child: _buildAccountStatItem(
                  'Transactions',
                  '${provider.transactions.length}',
                  Icons.receipt_long,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthService authService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile('Export Data', Icons.download, () {
            // TODO: Implement export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon!')),
            );
          }),
          _buildSettingsTile('Backup & Sync', Icons.cloud_upload, () {
            // TODO: Implement backup
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup feature coming soon!')),
            );
          }),
          _buildSettingsTile('Privacy Policy', Icons.privacy_tip, () {
            // TODO: Navigate to privacy policy
          }),
          _buildSettingsTile('About', Icons.info, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          }),
          _buildSettingsTile(
            'Sign Out',
            Icons.logout,
            () => _showSignOutDialog(context, authService),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF006E1F)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? AppConstants.errorColor : const Color(0xFF006E1F),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppConstants.errorColor : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<Map<String, double>> _getFinancialSummary(
    ExpenseProvider provider,
  ) async {
    final income = await provider.getCurrentMonthIncome();
    final expenses = await provider.getCurrentMonthExpenses();

    return {'income': income, 'expenses': expenses};
  }

  void _showSignOutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await authService.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
