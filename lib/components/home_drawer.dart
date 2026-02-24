import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

/// Home screen drawer component with user profile and navigation options
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, ExpenseProvider>(
      builder: (context, authService, expenseProvider, child) {
        return Drawer(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          child: SafeArea(
            child: Column(
              children: [
                // Clean Header without background color
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/profile');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Enhanced Profile Circle with Shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryDark,
                            backgroundImage:
                                authService.currentUser?.photoURL != null
                                    ? NetworkImage(
                                      authService.currentUser!.photoURL!,
                                    )
                                    : null,
                            child:
                                authService.currentUser?.photoURL == null
                                    ? Text(
                                      (authService
                                                  .userDisplayName
                                                  ?.isNotEmpty ==
                                              true)
                                          ? authService.userDisplayName![0]
                                              .toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Enhanced User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Name with better styling
                              Text(
                                authService.userDisplayName ?? 'Welcome User',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Email with icon
                              if (authService.userEmail != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        authService.userEmail!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Stats Section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryDark.withValues(alpha: 0.2),
                    ),
                  ),
                  child: _buildQuickStats(context, expenseProvider),
                ),

                // Enhanced Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Navigation Section
                      _buildSectionHeader(context, 'Navigation'),
                      _buildDrawerItem(
                        context,
                        icon: Icons.category_rounded,
                        title: 'Categories',
                        subtitle: 'Manage expense categories',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/categories');
                        },
                      ),

                      // Settings Section
                      _buildSectionHeader(context, 'Settings'),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        subtitle: 'App settings & preferences',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/more');
                        },
                      ),
                    ],
                  ),
                ),

                // Enhanced Sign Out Button
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSignOutDialog(context, authService),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        foregroundColor: Theme.of(context).colorScheme.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build styled drawer item with icon, title and subtitle
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with dark green background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build section header for drawer
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Build quick stats widget
  Widget _buildQuickStats(BuildContext context, ExpenseProvider provider) {
    final thisMonthExpenses = provider.transactions
        .where(
          (t) =>
              t.type == 'expense' &&
              t.date.month == DateTime.now().month &&
              t.date.year == DateTime.now().year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final thisMonthIncome = provider.transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.month == DateTime.now().month &&
              t.date.year == DateTime.now().year,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = thisMonthIncome - thisMonthExpenses;

    return Column(
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.insights_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'This Month',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stats Row
        Row(
          children: [
            // Balance
            Expanded(
              child: _buildStatItem(
                context,
                'Balance',
                balance.abs(),
                balance >= 0 ? Icons.trending_up : Icons.trending_down,
                balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            // Expenses
            Expanded(
              child: _buildStatItem(
                context,
                'Spent',
                thisMonthExpenses,
                Icons.arrow_downward,
                Colors.red.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Show add transaction options
  void _showAddTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAddOption(
                      context,
                      Icons.trending_up,
                      'Income',
                      'Record money received',
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        context.push('/add-transaction?type=income');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAddOption(
                      context,
                      Icons.trending_down,
                      'Expense',
                      'Record money spent',
                      Colors.red,
                      () {
                        Navigator.pop(context);
                        context.push('/add-transaction?type=expense');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Build quick add option
  Widget _buildQuickAddOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog for sign out
  void _showSignOutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              // Sign Out Button
              ElevatedButton(
                onPressed: () async {
                  // Close dialog first
                  Navigator.of(context).pop();

                  // Handle sign out and navigation safely
                  try {
                    await authService.signOut();

                    // Use pushReplacement to avoid navigation stack issues
                    if (context.mounted) {
                      context.pushReplacement('/auth');
                    }
                  } catch (e) {
                    // If there's an error, just close the drawer and show the auth screen
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close drawer
                      context.go('/auth');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
}
