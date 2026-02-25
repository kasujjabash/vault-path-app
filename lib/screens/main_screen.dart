import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_sync_service.dart';
import '../theme/app_theme.dart';
import '../components/home_drawer.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 4 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color:
                isActive
                    ? (Theme.of(context).brightness == Brightness.light
                        ? Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.2)
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.8))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color:
                    isActive
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).colorScheme.secondary)
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                size: isSmallScreen ? 20 : 24,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        isActive
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).colorScheme.secondary)
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build add button as navigation item with green circular background
  Widget _buildAddNavItem() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return Expanded(
      child: GestureDetector(
        onTap: _showAddOptionsMenu,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSecondary,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Add',
              style: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          drawer: const HomeDrawer(),
          body: widget.child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Theme.of(context).colorScheme.surface,
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
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
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
