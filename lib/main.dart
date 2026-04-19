import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/expense_provider.dart';
import 'services/auth_service.dart';
import 'services/firebase_sync_service.dart';
import 'services/currency_service.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/premium_service.dart';
import 'router/app_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// FCM background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message: ${message.notification?.title}');
}

/// Main entry point of the Budjar expense tracker application
/// This app helps users track their expenses, manage budgets, and analyze spending patterns
void main() {
  runZonedGuarded(_appMain, (error, stack) {
    // Any uncaught exception (including PlatformException from Firebase) lands here
    debugPrint('Unhandled error caught by zone: $error');
  });
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize timezone data for scheduled notifications
  tz.initializeTimeZones();

  // Register FCM background handler before Firebase initializes
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Catch Flutter framework errors without crashing
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter error: ${details.exception}');
  };

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

        // Premium service - Initialize early
        ChangeNotifierProvider(create: (context) => PremiumService()),

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
          final premiumService = context.read<PremiumService>();

          // Initialize services in sequence to avoid race conditions
          if (!authService.isInitialized) {
            // Capture providers before async gaps to avoid BuildContext across async warning
            final expenseProvider = context.read<ExpenseProvider>();
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await authService.initialize(firebaseEnabled: firebaseEnabled);
                await currencyService.initialize();
                await premiumService.initialize();

                // Initialize notification service before anything that posts notifications
                if (!notificationService.isInitialized) {
                  await notificationService.initialize();
                  await notificationService.setAppInstallDate();
                  notificationService.scheduleFollowUpWelcomeNotification();
                }

                // Process any due recurring transactions (once per app launch)
                Future<void> runRecurring() async {
                  await expenseProvider.processRecurringTransactions(
                    notificationService,
                  );
                }

                if (expenseProvider.isInitialized) {
                  await runRecurring();
                } else {
                  // One-shot listener — removes itself after firing
                  late final VoidCallback listener;
                  listener = () async {
                    if (expenseProvider.isInitialized) {
                      expenseProvider.removeListener(listener);
                      await runRecurring();
                    }
                  };
                  expenseProvider.addListener(listener);
                }

                // Check monthly spending summary (fires on last day of month)
                if (expenseProvider.isInitialized) {
                  await notificationService.checkMonthlySummary(
                    expenseProvider.transactions,
                  );
                }
              } catch (e) {
                debugPrint('Error initializing services: $e');
              }
            });
          }

          // Create router once outside Consumer to prevent recreation on theme change
          final router = AppRouter.createRouter(authService);
          

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp.router(
                title: 'Vault Path',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
