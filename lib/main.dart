import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/expense_provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_sync_service.dart';
import 'services/currency_service.dart';
import 'router/app_router.dart';

/// Main entry point of the Budjar expense tracker application
/// This app helps users track their expenses, manage budgets, and analyze spending patterns
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;

  try {
    debugPrint('Initializing Firebase...');

    // For web, ensure Firebase JS SDK is loaded first
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Initialize Firebase for all platforms
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Wait for Firebase to be fully ready
    await Future.delayed(const Duration(milliseconds: 500));

    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    firebaseInitialized = false;
    debugPrint('App will continue in offline mode');
  }

  runApp(BudjarApp(firebaseEnabled: firebaseInitialized));
}

class BudjarApp extends StatelessWidget {
  final bool firebaseEnabled;

  const BudjarApp({super.key, this.firebaseEnabled = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // Currency service - Initialize early
        ChangeNotifierProvider(create: (context) => CurrencyService()),

        // Auth service - Create and initialize properly
        ChangeNotifierProvider(create: (context) => AuthService()),

        // Firebase sync service - conditional creation
        ChangeNotifierProvider(create: (context) => FirebaseSyncService()),

        // Main expense provider
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Initialize auth service safely
          final authService = context.read<AuthService>();
          final currencyService = context.read<CurrencyService>();

          if (!authService.isInitialized) {
            Future.microtask(() {
              authService.initialize(firebaseEnabled: firebaseEnabled);
            });
          }

          // Initialize currency service
          Future.microtask(() {
            currencyService.initialize();
          });

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp.router(
                title: 'Budjar',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.createRouter(authService),
              );
            },
          );
        },
      ),
    );
  }
}
