import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../providers/expense_provider.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/custom_snackbar.dart';
import 'premium_screen.dart';

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
                _buildSectionTitle(context, 'Premium'),
                const SizedBox(height: 12),

                _buildPremiumItem(context),

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

  Widget _buildPremiumItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006E1F), Color(0xFF00A040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006E1F).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showPremiumScreen(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Premium icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vault Path Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock unlimited features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
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
    applicationName: 'Vault Path',
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
  showDialog(
    context: context,
    builder:
        (context) => _CurrencySelectionDialog(currencyService: currencyService),
  );
}

/// Stateful currency selection dialog with save functionality
class _CurrencySelectionDialog extends StatefulWidget {
  final CurrencyService currencyService;

  const _CurrencySelectionDialog({required this.currencyService});

  @override
  State<_CurrencySelectionDialog> createState() =>
      _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<_CurrencySelectionDialog> {
  Currency? _selectedCurrency;
  bool _isApplying = false;
  Timer? _refreshTimer;
  Timer? _finalMessageTimer;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currencyService.currentCurrency;
  }

  @override
  void dispose() {
    // Cancel any pending timers to prevent accessing context after disposal
    _refreshTimer?.cancel();
    _finalMessageTimer?.cancel();
    super.dispose();
  }

  Future<void> _applyCurrency() async {
    if (_selectedCurrency == null ||
        _selectedCurrency!.code ==
            widget.currencyService.currentCurrency.code) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    setState(() {
      _isApplying = true;
    });

    try {
      // Apply the currency change
      await widget.currencyService.setCurrency(_selectedCurrency!);

      if (!mounted) return;

      Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Currency changed to ${_selectedCurrency!.name}'),
                const Spacer(),
                const Icon(Icons.refresh, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                const Text('Updated!'),
              ],
            ),
            backgroundColor: const Color(0xFF006E1F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Force refresh providers with a brief delay
        _refreshTimer = Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          try {
            final expenseProvider = Provider.of<ExpenseProvider>(
              context,
              listen: false,
            );
            expenseProvider.loadTransactions();
            widget.currencyService.forceRefresh();
          } catch (e) {
            debugPrint('Error refreshing providers: $e');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isApplying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: 650,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006E1F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.currency_exchange,
                    color: Color(0xFF006E1F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your preferred currency and save',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF006E1F).withOpacity(0.1),
                    const Color(0xFF00B830).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF006E1F).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF006E1F), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This will update currency for all transactions and displays. Click "Apply Changes" to save.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF006E1F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Currency list
            Expanded(
              child: ListView.builder(
                itemCount: widget.currencyService.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency =
                      widget.currencyService.supportedCurrencies[index];
                  final isSelected = currency.code == _selectedCurrency?.code;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF006E1F).withOpacity(0.08)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF006E1F)
                                : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            _selectedCurrency = currency;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Currency symbol with gradient
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        isSelected
                                            ? [
                                              const Color(0xFF006E1F),
                                              const Color(0xFF00B830),
                                            ]
                                            : [
                                              Colors.grey.shade200,
                                              Colors.grey.shade300,
                                            ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF006E1F,
                                              ).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Center(
                                  child: Text(
                                    currency.symbol,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Currency details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                        color:
                                            isSelected
                                                ? const Color(0xFF006E1F)
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currency.code} • ${currency.symbol}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            isSelected
                                                ? const Color(
                                                  0xFF006E1F,
                                                ).withOpacity(0.8)
                                                : Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Selection indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF006E1F)
                                          : Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.check
                                      : Icons.radio_button_unchecked,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isApplying ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              _isApplying
                                  ? Colors.grey
                                  : const Color(0xFF006E1F),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color:
                            _isApplying ? Colors.grey : const Color(0xFF006E1F),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Apply button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006E1F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child:
                        _isApplying
                            ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Applying...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Apply Changes',
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
          ],
        ),
      ),
    );
  }
}
