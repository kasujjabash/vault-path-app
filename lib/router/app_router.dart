import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/budgets/budget_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/accounts/accounts_screen.dart';
import '../screens/accounts/add_account_screen.dart';
import '../screens/accounts/choose_account_screen.dart';
import '../screens/transactions/manual_input_screen.dart';
import '../screens/analytics/expense_details_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/notifications_screen.dart';
import '../services/auth_service.dart';

/// App Router configuration using go_router
/// This handles all navigation throughout the app with auth protection
class AppRouter {
  static GoRouter createRouter(AuthService authService) => GoRouter(
    initialLocation: '/login',
    refreshListenable: authService, // Listen to auth state changes
    redirect: (context, state) {
      final isSignedIn = authService.isSignedIn;

      // Define auth routes
      const authRoutes = ['/login', '/register'];
      final isAuthRoute = authRoutes.contains(state.matchedLocation);

      // If not signed in and not on auth route, redirect to login
      if (!isSignedIn && !isAuthRoute) {
        return '/login';
      }

      // If signed in and on auth route, redirect to home
      if (isSignedIn && isAuthRoute) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Shell route for the main navigation structure (protected)
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // Home route
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Transactions route
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),

          // Budget route
          GoRoute(
            path: '/budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetScreen(),
          ),

          // Analytics route (Reports)
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),

          // Accounts route
          GoRoute(
            path: '/accounts',
            name: 'accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
        ],
      ),

      // Standalone routes (not part of the shell, but still protected)
      GoRoute(
        path: '/add-transaction',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),

      GoRoute(
        path: '/add-account',
        name: 'add-account',
        builder: (context, state) => const AddAccountScreen(),
      ),

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/choose-account',
        name: 'choose-account',
        builder: (context, state) => const ChooseAccountScreen(),
      ),

      GoRoute(
        path: '/manual-input',
        name: 'manual-input',
        builder: (context, state) => const ManualInputScreen(),
      ),

      GoRoute(
        path: '/expense-details',
        name: 'expense-details',
        builder: (context, state) => const ExpenseDetailsScreen(),
      ),

      GoRoute(
        path: '/more',
        name: 'more',
        builder: (context, state) => const MoreScreen(),
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],

    // Error page
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Page not found: ${state.uri.path}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
  );
}
