import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../services/firebase_sync_service.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/custom_snackbar.dart';
import '../../theme/app_theme.dart';
import 'premium_screen.dart';
import 'about_screen.dart';

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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF006E1F),
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

                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildThemeToggleItem(
                      context,
                      themeProvider: themeProvider,
                    );
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Support'),
                const SizedBox(height: 12),

                _buildSettingsItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(context),
                ),

                if (authService.isSignedIn) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Data Sync'),
                  const SizedBox(height: 12),

                  Consumer<FirebaseSyncService>(
                    builder: (context, syncService, child) {
                      return _buildSettingsItem(
                        context,
                        icon:
                            syncService.isSyncing
                                ? Icons.sync
                                : (syncService.isOnline
                                    ? Icons.cloud_done
                                    : Icons.cloud_off),
                        title:
                            syncService.isSyncing ? 'Syncing...' : 'Cloud Sync',
                        subtitle:
                            syncService.isSyncing
                                ? 'Syncing your data to cloud'
                                : (syncService.isOnline
                                    ? 'Last synced: ${_getLastSyncText(syncService)}'
                                    : 'Sync not available'),
                        onTap: () => _showSyncDialog(context),
                        trailing:
                            syncService.isSyncing
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : null,
                      );
                    },
                  ),

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
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isDestructive
                  ? Theme.of(context).colorScheme.error
                  : const Color(0xFF006E1F),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color:
                  isDestructive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
            ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggleItem(
    BuildContext context, {
    required ThemeProvider themeProvider,
  }) {
    String getThemeText() {
      switch (themeProvider.themeMode) {
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
        case ThemeMode.system:
          return 'System';
      }
    }

    String getThemeSubtitle() {
      switch (themeProvider.themeMode) {
        case ThemeMode.light:
          return 'Use light mode';
        case ThemeMode.dark:
          return 'Use dark mode';
        case ThemeMode.system:
          return 'Follow system settings';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: const Color(0xFF006E1F),
        ),
        title: const Text('Theme'),
        subtitle: Text(getThemeSubtitle()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getThemeText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF006E1F),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                // Toggle between light and dark mode
                // When switched to dark, set dark mode
                // When switched to light, set light mode
                themeProvider.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              activeThumbColor: const Color(0xFF006E1F),
            ),
          ],
        ),
        onTap: () {
          // Show theme selection dialog
          _showThemeDialog(context, themeProvider);
        },
      ),
    );
  }

  Widget _buildPremiumItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF006E1F).withOpacity(0.3),
          width: 2,
        ),
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
                    color: const Color(0xFF006E1F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.diamond,
                    color: const Color(0xFF006E1F),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vault Path Premium',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlock unlimited features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF006E1F),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).colorScheme.surface,
            title: Text(
              'Select Theme',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Light',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Use light mode',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF006E1F),
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'Dark',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Use dark mode',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF006E1F),
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(
                    'System',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Follow system settings',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  activeColor: const Color(0xFF006E1F),
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
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
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authService.userEmail ?? 'your email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
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

  void _showAboutDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    CurrencyService currencyService,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        color: const Color(0xFF006E1F),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Currency',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF006E1F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            currencyService.supportedCurrencies
                                .map(
                                  (currency) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            currencyService.currentCurrency ==
                                                    currency
                                                ? const Color(0xFF006E1F)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .outline
                                                    .withOpacity(0.3),
                                        width:
                                            currencyService.currentCurrency ==
                                                    currency
                                                ? 2
                                                : 1,
                                      ),
                                      color:
                                          currencyService.currentCurrency ==
                                                  currency
                                              ? const Color(
                                                0xFF006E1F,
                                              ).withOpacity(0.1)
                                              : Colors.transparent,
                                    ),
                                    child: ListTile(
                                      leading: Text(
                                        currency.symbol,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      title: Text(
                                        currency.name,
                                        style: TextStyle(
                                          fontWeight:
                                              currencyService.currentCurrency ==
                                                      currency
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              currencyService.currentCurrency ==
                                                      currency
                                                  ? const Color(0xFF006E1F)
                                                  : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        currency.code,
                                        style: TextStyle(
                                          color:
                                              currencyService.currentCurrency ==
                                                      currency
                                                  ? const Color(0xFF006E1F)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.6),
                                        ),
                                      ),
                                      trailing:
                                          currencyService.currentCurrency ==
                                                  currency
                                              ? Icon(
                                                Icons.check_circle,
                                                color: const Color(0xFF006E1F),
                                                size: 24,
                                              )
                                              : null,
                                      onTap: () async {
                                        await currencyService.setCurrency(
                                          currency,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Currency changed to ${currency.name}',
                                              ),
                                              backgroundColor: const Color(
                                                0xFF006E1F,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Get last sync text for display
  String _getLastSyncText(FirebaseSyncService syncService) {
    if (syncService.lastSyncTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(syncService.lastSyncTime!);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  /// Show sync dialog with manual sync option
  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cloud Sync'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your budget settings, transactions, and other data are automatically synced across all your devices.',
                ),
                const SizedBox(height: 16),
                Consumer<FirebaseSyncService>(
                  builder: (context, syncService, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${syncService.isOnline ? "Connected" : "Offline"}',
                          style: TextStyle(
                            color:
                                syncService.isOnline
                                    ? Colors.green
                                    : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (syncService.lastSyncTime != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Last sync: ${_getLastSyncText(syncService)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              Consumer<FirebaseSyncService>(
                builder: (context, syncService, child) {
                  return ElevatedButton(
                    onPressed:
                        syncService.isSyncing
                            ? null
                            : () async {
                              Navigator.of(context).pop();

                              // Show sync in progress
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Syncing your data...'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Trigger manual sync
                              await FirebaseSyncService().forceSyncSettings();

                              // Show result
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                    child: Text(
                      syncService.isSyncing ? 'Syncing...' : 'Sync Now',
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}
