import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../providers/expense_provider.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/custom_snackbar.dart';

/// More screen with settings, premium features, and additional options
/// This screen will contain settings, premium upgrade, and other app features
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
        backgroundColor: const Color(0xFF006E1F), // Dark green
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthService>(
            builder: (context, authService, child) {
              if (authService.isSignedIn) {
                return TextButton.icon(
                  onPressed: () => _showSignOutDialog(context, authService),
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }
              return TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                if (authService.isSignedIn) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(
                            0xFF006E1F,
                          ), // Dark green
                          child: Text(
                            (authService.userDisplayName?.isNotEmpty ?? false)
                                ? authService.userDisplayName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authService.userDisplayName ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authService.userEmail ?? '',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Settings Sections
                _buildSectionTitle(context, 'Account'),
                const SizedBox(height: 12),

                if (authService.isSignedIn) ...[
                  _buildSettingsItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _showEditProfileDialog(context, authService),
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => _showResetPasswordDialog(context, authService),
                  ),
                ] else ...[
                  _buildSettingsItem(
                    context,
                    icon: Icons.login,
                    title: 'Sign In',
                    subtitle: 'Access your account',
                    onTap: () => context.go('/login'),
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Preferences'),
                const SizedBox(height: 12),

                _buildSettingsItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  onTap:
                      () => _showComingSoonSnackBar(context, 'Notifications'),
                ),
                Consumer<CurrencyService>(
                  builder: (context, currencyService, child) {
                    return _buildSettingsItem(
                      context,
                      icon: Icons.monetization_on_outlined,
                      title: 'Currency',
                      subtitle:
                          '${currencyService.currentCurrency.name} (${currencyService.currentCurrency.symbol})',
                      onTap:
                          () => _showCurrencyDialog(context, currencyService),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'Choose your preferred theme',
                  onTap:
                      () => _showComingSoonSnackBar(context, 'Theme Settings'),
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Select your language',
                  onTap:
                      () =>
                          _showComingSoonSnackBar(context, 'Language Settings'),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Support'),
                const SizedBox(height: 12),

                _buildSettingsItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () => _showComingSoonSnackBar(context, 'Help Center'),
                ),
                _buildSettingsItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(context),
                ),

                if (authService.isSignedIn) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Account Actions'),
                  const SizedBox(height: 12),

                  _buildSettingsItem(
                    context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    onTap: () => _showSignOutDialog(context, authService),
                    isDestructive: true,
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Debug Tools'),
                const SizedBox(height: 12),

                _buildSettingsItem(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Clear All Data',
                  subtitle: 'Delete all transactions and reset balances',
                  onTap: () => _showClearDataDialog(context),
                  isDestructive: true,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF006E1F), // Dark green
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isDestructive
                  ? Theme.of(context).colorScheme.error
                  : const Color(0xFF006E1F), // Dark green
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthService authService) {
    final nameController = TextEditingController(
      text: authService.userDisplayName ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => DialogUtils.createModernDialog(
            title: 'Edit Profile',
            titleIcon: Icons.person_outline,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogUtils.createDialogTextField(
                  controller: nameController,
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                  prefixIcon: Icons.person_outlined,
                ),
                DialogUtils.createDialogText(
                  'Email: ${authService.userEmail ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              DialogUtils.createSecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              DialogUtils.createPrimaryButton(
                text: 'Save',
                icon: Icons.save_outlined,
                onPressed: () {
                  Navigator.pop(context);
                  CustomSnackBar.showInfo(
                    context,
                    'Profile update coming soon!',
                  );
                },
              ),
            ],
          ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder:
          (context) => DialogUtils.createModernDialog(
            title: 'Reset Password',
            titleIcon: Icons.lock_reset,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogUtils.createDialogText(
                  'A password reset email will be sent to:',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authService.userEmail ?? 'your email',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              DialogUtils.createSecondaryButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              DialogUtils.createPrimaryButton(
                text: 'Send Reset Email',
                icon: Icons.send,
                onPressed: () async {
                  Navigator.pop(context);
                  if (authService.userEmail != null) {
                    final success = await authService.resetPassword(
                      authService.userEmail!,
                    );
                    if (context.mounted) {
                      if (success) {
                        CustomSnackBar.showSuccess(
                          context,
                          'Password reset email sent!',
                        );
                      } else {
                        CustomSnackBar.showError(
                          context,
                          'Failed to send reset email',
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthService authService) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      titleIcon: Icons.logout,
      confirmText: 'Sign Out',
      isDestructive: true,
    ).then((confirmed) async {
      if (confirmed == true) {
        await authService.signOut();
        // Router will automatically redirect to login when auth state changes
      }
    });
  }
}

void _showAboutDialog(BuildContext context) {
  showAboutDialog(
    context: context,
    applicationName: 'Budjar',
    applicationVersion: '1.0.0',
    applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
    children: [
      const Text('Your smart expense tracker for better financial management.'),
    ],
  );
}

void _showComingSoonSnackBar(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature feature coming soon!'),
      action: SnackBarAction(label: 'OK', onPressed: () {}),
    ),
  );
}

void _showClearDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          '⚠️ Clear All Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• All transactions'),
            Text('• All budgets'),
            Text('• Custom categories'),
            Text('• Reset account balances to 0'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              try {
                await Provider.of<ExpenseProvider>(
                  context,
                  listen: false,
                ).clearAllData();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  CustomSnackBar.show(
                    context: context,
                    message: 'All data cleared successfully!',
                    type: SnackBarType.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  CustomSnackBar.show(
                    context: context,
                    message: 'Error clearing data: $e',
                    type: SnackBarType.error,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      );
    },
  );
}

void _showCurrencyDialog(
  BuildContext context,
  CurrencyService currencyService,
) {
  DialogUtils.showConfirmationDialog(
    context: context,
    title: 'Select Currency',
    message:
        'Choose your preferred currency for displaying amounts in the app.',
    confirmText: 'OK',
    titleIcon: Icons.currency_exchange,
  );
}
