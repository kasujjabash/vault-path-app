import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_sync_service.dart';
import '../theme/app_theme.dart';

/// Main screen with bottom navigation and drawer
/// This screen manages navigation between different sections of the app
class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isInitialized = false;
  int _currentIndex = 0;

  // Navigation routes for bottom nav
  final List<String> _routes = ['/', '/transactions', '/budgets', '/analytics'];

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  /// Update current index based on current route
  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    final index = _routes.indexOf(location);
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  /// Initialize the app with default data
  Future<void> _initializeApp() async {
    if (_isInitialized) return;

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final syncService = Provider.of<FirebaseSyncService>(
        context,
        listen: false,
      );

      // Initialize auth service first
      await authService.initialize();

      // Initialize provider in background to show UI faster
      unawaited(provider.initialize());

      // Initialize sync service if user is signed in and Firebase is fully functional
      // Only initialize sync if not in mock mode
      if (authService.isSignedIn &&
          authService.currentUser?.uid != null &&
          !authService.error.toString().contains('Firebase')) {
        unawaited(syncService.initialize(authService.currentUser!.uid));
      } else {
        debugPrint(
          'Skipping sync service initialization - using local storage only',
        );
      }

      // Mark as initialized immediately to show UI
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Still show UI even if init fails
        });
      }
    }
  }

  /// Handle bottom navigation tap
  void _onTabTapped(int index) {
    if (index < _routes.length) {
      context.go(_routes[index]);
    }
  }

  /// Build custom navigation item with light green background for active state
  Widget _buildCustomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4E5D3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF006E1F) : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? const Color(0xFF006E1F) : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build add button as navigation item with green circular background
  Widget _buildAddNavItem() {
    return GestureDetector(
      onTap: _showAddOptionsMenu,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF006E1F),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add',
            style: TextStyle(
              color: Color(0xFF006E1F),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Show add options menu with income, expense, and account options
  void _showAddOptionsMenu() {
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006E1F),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuOption(
                icon: Icons.trending_up,
                title: 'Add Income',
                subtitle: 'Record money received',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add-transaction?type=income');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.trending_down,
                title: 'Add Expense',
                subtitle: 'Record money spent',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add-transaction?type=expense');
                },
              ),
              const SizedBox(height: 12),
              _buildMenuOption(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Add Account',
                subtitle: 'Create new account',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/add-account');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Build menu option widget
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4E5D3).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF006E1F).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF006E1F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006E1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF006E1F),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Show sign out confirmation dialog
  void _showSignOutDialog(AuthService authService) {
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
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await authService.signOut();
                  // Router will automatically redirect to login when auth state changes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  /// Show about dialog
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Vault Path',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: const [
        Text(
          'A modern expense tracker to help you manage your finances smartly.',
        ),
      ],
    );
  }

  /// Build unique and modern drawer with profile screen
  Widget _buildDrawer() {
    return Consumer2<AuthService, ExpenseProvider>(
      builder: (context, authService, provider, child) {
        return Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              // Modern Drawer Header with Gradient
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF006E1F), Color(0xFF00A040)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Avatar with Animation
                        Hero(
                          tag: 'profile-avatar',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              (authService.userDisplayName?.isNotEmpty == true)
                                  ? authService.userDisplayName![0]
                                      .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          authService.userDisplayName ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Email
                        if (authService.userEmail != null)
                          Text(
                            authService.userEmail!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Drawer Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildModernDrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      subtitle: 'View your profile & stats',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/profile');
                      },
                    ),

                    const Divider(height: 1),

                    _buildModernDrawerItem(
                      icon: Icons.account_balance,
                      title: 'Accounts',
                      subtitle: 'Manage your accounts',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/accounts');
                      },
                    ),

                    _buildModernDrawerItem(
                      icon: Icons.category,
                      title: 'Categories',
                      subtitle: 'Manage categories',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navigate to categories page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Categories page coming soon!'),
                          ),
                        );
                      },
                    ),

                    _buildModernDrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App settings & preferences',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/more');
                      },
                    ),

                    const Divider(height: 1),

                    // Sync Status Card
                    Consumer<FirebaseSyncService>(
                      builder: (context, syncService, child) {
                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                syncService.isOnline
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  syncService.isOnline
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                syncService.isSyncing
                                    ? Icons.sync
                                    : (syncService.isOnline
                                        ? Icons.cloud_done
                                        : Icons.cloud_off),
                                color:
                                    syncService.isOnline
                                        ? Colors.green
                                        : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sync Status',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Text(
                                      syncService.isOnline
                                          ? (syncService.isSyncing
                                              ? 'Syncing...'
                                              : 'Connected')
                                          : 'Offline',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // About Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showAboutDialog();
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('About Vault Path'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF006E1F),
                          side: const BorderSide(color: Color(0xFF006E1F)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sign Out Button at Bottom
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showSignOutDialog(authService),
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

              // Footer - Developed by bApp
              Container(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Column(
                  children: [
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Developed with ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: Colors.red.shade400,
                        ),
                        Text(
                          ' by ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'bApp',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF006E1F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernDrawerItem({
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        // Show loading screen while initializing
        if (!_isInitialized || provider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Vault Path...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          drawer: _buildDrawer(),
          body: widget.child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 85,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCustomNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                      isActive: _currentIndex == 0,
                    ),
                    _buildCustomNavItem(
                      icon: Icons.trending_down_outlined,
                      activeIcon: Icons.trending_down,
                      label: 'Expenses',
                      index: 1,
                      isActive: _currentIndex == 1,
                    ),
                    // Add button integrated into navigation
                    _buildAddNavItem(),
                    _buildCustomNavItem(
                      icon: Icons.account_balance_outlined,
                      activeIcon: Icons.account_balance,
                      label: 'Budgets',
                      index: 2,
                      isActive: _currentIndex == 2,
                    ),
                    _buildCustomNavItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'Reports',
                      index: 3,
                      isActive: _currentIndex == 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
