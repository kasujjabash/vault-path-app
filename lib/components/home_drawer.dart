import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

/// Home screen drawer component with user profile and navigation options
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Simple Header with User Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Profile Circle
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF006E1F),
                        backgroundImage:
                            authService.currentUser?.photoURL != null
                                ? NetworkImage(
                                  authService.currentUser!.photoURL!,
                                )
                                : null,
                        child:
                            authService.currentUser?.photoURL == null
                                ? Text(
                                  (authService.userDisplayName?.isNotEmpty ==
                                          true)
                                      ? authService.userDisplayName![0]
                                          .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Name
                            Text(
                              authService.userDisplayName ?? 'User',
                              style: const TextStyle(
                                color: Color(0xFF006E1F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Email
                            if (authService.userEmail != null)
                              Text(
                                authService.userEmail!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Profile Item
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'View your profile & stats',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/profile');
                  },
                ),

                // Settings Item
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App settings & preferences',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/more');
                  },
                ),

                const Spacer(),

                // Sign Out Button at Bottom
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSignOutDialog(context, authService),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF006E1F).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF006E1F), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
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
                  foregroundColor: Colors.grey.shade700,
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
