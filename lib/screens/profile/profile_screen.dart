import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_sync_service.dart';
import '../../services/premium_service.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/custom_snackbar.dart';
import '../more/about_screen.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Section
                _buildUserInfoSection(authService),

                const SizedBox(height: 24),

                // Profile Actions
                _buildSectionTitle('Account'),
                const SizedBox(height: 12),

                if (authService.isSignedIn) ...[
                  _buildProfileItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _showEditProfileDialog(context, authService),
                  ),
                  _buildProfileItem(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    subtitle: 'Export your transactions',
                    onTap: () => context.go('/transactions'),
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionTitle('App'),
                const SizedBox(height: 12),

                _buildProfileItem(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup & Sync',
                  subtitle: 'Sync your data across devices',
                  onTap: () => _showSyncDialog(context),
                ),
                _buildProfileItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      ),
                ),

                if (authService.isSignedIn) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account Actions'),
                  const SizedBox(height: 12),

                  _buildProfileItem(
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

  Widget _buildUserInfoSection(AuthService authService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                if (authService.userEmail != null)
                  Text(
                    authService.userEmail!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
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
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
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
      builder: (ctx) => DialogUtils.createModernDialog(
        ctx,
        title: 'Edit Profile',
        titleIcon: Icons.person_outline,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogUtils.createDialogTextField(
              ctx,
              controller: nameController,
              labelText: 'Display Name',
              hintText: 'Enter your display name',
              prefixIcon: Icons.person_outlined,
            ),
            const SizedBox(height: 8),
            DialogUtils.createDialogText(
              ctx,
              'Email: ${authService.userEmail ?? 'N/A'}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          DialogUtils.createSecondaryButton(
            ctx,
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          const SizedBox(width: 8),
          DialogUtils.createPrimaryButton(
            text: 'Save',
            icon: Icons.save_outlined,
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final success = await authService.updateProfile(name);
              if (mounted) {
                if (success) {
                  CustomSnackBar.showSuccess(this.context, 'Profile updated!');
                } else {
                  CustomSnackBar.showError(
                    this.context,
                    authService.error ?? 'Failed to update profile.',
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    final syncService = FirebaseSyncService();
    final premiumService = PremiumService();
    final isPremium = premiumService.isPremium;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor:
              Theme.of(ctx).brightness == Brightness.dark
                  ? Theme.of(ctx).colorScheme.surface
                  : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.cloud_sync_outlined, color: Theme.of(ctx).colorScheme.secondary),
              const SizedBox(width: 10),
              Text(
                'Backup & Sync',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isPremium) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Theme.of(ctx).colorScheme.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cloud sync is a Premium feature. Upgrade to sync across all your devices.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _syncStatusRow(ctx, syncService),
                const SizedBox(height: 12),
                Text(
                  'Your transactions, accounts, budgets and categories are synced automatically when you are online.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
            if (isPremium)
              ElevatedButton.icon(
                icon: syncService.isSyncing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync, size: 18),
                label: Text(syncService.isSyncing ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: syncService.isSyncing
                    ? null
                    : () async {
                        setDialogState(() {});
                        final nav = Navigator.of(ctx);
                        try {
                          await syncService.syncNow();
                          if (mounted) {
                            nav.pop();
                            CustomSnackBar.showSuccess(this.context, 'Sync completed!');
                          }
                        } catch (e) {
                          if (mounted) {
                            nav.pop();
                            final msg = e.toString().replaceFirst('Exception: ', '');
                            CustomSnackBar.showError(this.context, msg);
                          }
                        }
                      },
              ),
          ],
        ),
      ),
    );
  }

  Widget _syncStatusRow(BuildContext context, FirebaseSyncService syncService) {
    final lastSync = syncService.lastSyncTime;
    final isOnline = syncService.isOnline;
    return Row(
      children: [
        Icon(
          isOnline ? Icons.wifi : Icons.wifi_off,
          size: 18,
          color: isOnline ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (lastSync != null)
          Text(
            'Last sync: ${_formatSyncTime(lastSync)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showSignOutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).colorScheme.surface,
            title: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
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
