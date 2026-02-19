import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/expense_provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_sync_service.dart';
import 'services/currency_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
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

    // Verify Firebase is properly initialized by checking if an app exists
    if (Firebase.apps.isNotEmpty) {
      firebaseInitialized = true;
      debugPrint('Firebase initialized successfully');
    } else {
      throw Exception('Firebase apps list is empty after initialization');
    }
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    firebaseInitialized = false;
    debugPrint('App will continue in offline mode');
  }

  // Initialize Mobile Ads
  try {
    debugPrint('Initializing Mobile Ads...');
    await AdService.initialize();
    AdService.configureAds();
    debugPrint('Mobile Ads initialized successfully');
  } catch (e) {
    debugPrint('Mobile Ads initialization failed: $e');
  }

  runApp(VaultPathApp(firebaseEnabled: firebaseInitialized));
}

class VaultPathApp extends StatelessWidget {
  final bool firebaseEnabled;

  const VaultPathApp({super.key, this.firebaseEnabled = false});

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

        // Notification service - Initialize early
        ChangeNotifierProvider(create: (context) => NotificationService()),

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
          final notificationService = context.read<NotificationService>();

          // Initialize services in sequence to avoid race conditions
          if (!authService.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await authService.initialize(firebaseEnabled: firebaseEnabled);
                await currencyService.initialize();

                if (!notificationService.isInitialized) {
                  await notificationService.initialize();
                  await notificationService.setAppInstallDate();

                  // Schedule follow-up welcome notification for new users
                  // This will run in the background after a delay
                  notificationService.scheduleFollowUpWelcomeNotification();
                }
              } catch (e) {
                debugPrint('Error initializing services: $e');
              }
            });
          }

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp.router(
                title: 'Vault Path',
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
