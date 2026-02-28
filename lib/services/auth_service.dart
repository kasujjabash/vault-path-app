import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firebase_sync_service.dart';

/// Firebase Authentication Service
/// Handles user authentication with email/password and Google Sign-In
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  dynamic _user; // Can be User or MockUser
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _isMockMode = false; // For when Firebase is not available

  // Getters
  User? get currentUser => _isMockMode ? null : (_user ?? _auth?.currentUser);
  MockUser? get mockUser => _isMockMode ? _user as MockUser? : null;
  bool get isSignedIn => _isMockMode ? _user != null : currentUser != null;
  bool get isLoading => _isEmailLoading || _isGoogleLoading;
  bool get isEmailLoading => _isEmailLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  String? get userDisplayName =>
      _isMockMode
          ? mockUser?.displayName
          : currentUser?.displayName ?? currentUser?.email;
  String? get userEmail => _isMockMode ? mockUser?.email : currentUser?.email;

  /// Initialize the auth service
  Future<void> initialize({bool firebaseEnabled = true}) async {
    if (_isInitialized) return;

    if (!firebaseEnabled) {
      debugPrint('Firebase disabled - enabling mock mode for development');
      _isMockMode = true;
      _isInitialized = true;
      notifyListeners();
      return;
    }

    // Always try Firebase first since we have a real project now
    try {
      // Wait for Firebase to be fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify Firebase is actually initialized
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized - no apps found');
      }

      // Try to get FirebaseAuth instance with better error handling
      try {
        _auth = FirebaseAuth.instance;

        // Test if Firebase is actually working by trying to access current user
        final testUser = _auth?.currentUser;

        _user = testUser;
        _auth?.authStateChanges().listen(_onAuthStateChanged);
        _isInitialized = true;
        _isMockMode = false;
        debugPrint('AuthService initialized with Firebase');
        notifyListeners();
      } catch (firebaseError) {
        debugPrint('Firebase instance access failed: $firebaseError');

        // Check if it's a network-related error
        if (firebaseError.toString().contains('network') ||
            firebaseError.toString().contains('Network') ||
            firebaseError.toString().contains('connection') ||
            firebaseError.toString().contains('timeout')) {
          debugPrint('Network issue detected during Firebase initialization');
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Failed to initialize AuthService with Firebase: $e');
      // Fall back to mock mode if Firebase fails
      debugPrint('Enabling mock mode due to Firebase error');
      _isMockMode = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Handle auth state changes
  void _onAuthStateChanged(User? user) {
    _user = user;
    _clearError();
    notifyListeners();
    debugPrint('Auth state changed: ${user?.email ?? 'signed out'}');

    // Initialize or cleanup sync service based on auth state
    if (user != null) {
      // User signed in - initialize sync service
      FirebaseSyncService()
          .initialize(user.uid)
          .then((_) {
            debugPrint(
              'Firebase sync service initialized for user: ${user.uid}',
            );
          })
          .catchError((e) {
            debugPrint('Failed to initialize sync service: $e');
          });
    } else {
      // User signed out - cleanup sync service if needed
      debugPrint('User signed out - sync service will be cleaned up');
    }
  }

  /// Set email sign-in loading state
  void _setEmailLoading(bool loading) {
    _isEmailLoading = loading;
    notifyListeners();
  }

  /// Set Google sign-in loading state
  void _setGoogleLoading(bool loading) {
    _isGoogleLoading = loading;
    notifyListeners();
  }

  /// Set error message with optional context for better user guidance
  void _setError(String error, {String? context}) {
    String fullMessage = error;

    // Add contextual suggestions based on the error and context
    if (context == 'register' && error.contains('already registered')) {
      fullMessage +=
          '\n\nTip: Use the "Sign In" button below to access your existing account.';
    } else if (context == 'login' && error.contains('No account found')) {
      fullMessage += '\n\nTip: Use the "Sign Up" link to create a new account.';
    } else if (error.contains('password') && error.contains('weak')) {
      fullMessage +=
          '\n\nTip: Try using a mix of letters, numbers, and symbols.';
    } else if (error.contains('Network error') ||
        error.contains('connection')) {
      fullMessage += '\n\nTip: Check your WiFi or mobile data connection.';
    }

    _error = fullMessage;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Public method to clear error
  void clearError() {
    _clearError();
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    if (_isMockMode) {
      _setEmailLoading(true);
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      // Mock user for development
      if (email.isNotEmpty && password.isNotEmpty) {
        // Create a mock user-like object
        _user = MockUser(email: email, displayName: email.split('@').first);
        debugPrint('Mock sign in successful for: $email');
        _setEmailLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password', context: 'login');
        _setEmailLoading(false);
        return false;
      }
    }

    if (_auth == null) {
      _setError(
        'Authentication service not available. Please check Firebase setup.',
        context: 'login',
      );
      return false;
    }

    try {
      _setEmailLoading(true);
      _clearError();

      // Validate input before attempting authentication
      if (email.trim().isEmpty || password.isEmpty) {
        _setError('Please enter both email and password', context: 'login');
        return false;
      }

      if (!email.contains('@') || !email.contains('.')) {
        _setError('Please enter a valid email address', context: 'login');
        return false;
      }

      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('Signed in: ${credential.user?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      _setError(errorMessage, context: 'login');
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      // Enhanced error handling with network detection
      String errorMessage =
          'Login failed. Please try again or check your credentials.';

      // Handle case where Firebase Auth is not properly configured
      if (e.toString().contains('No Firebase App') ||
          e.toString().contains('app/no-app')) {
        errorMessage =
            'Firebase Authentication is not properly configured. The app will work in offline mode.';
        debugPrint('Firebase Auth not configured: $e');
      } else if (_isNetworkError(e)) {
        errorMessage =
            'Network error. Please check your internet connection and try again. If you\'re still having trouble, try restarting the app.';
        debugPrint('Network error during sign in: $e');

        // Additional logging for network issues
        if (e.toString().contains('timeout')) {
          debugPrint('Request timed out - check network stability');
        } else if (e.toString().contains('unreachable')) {
          debugPrint('Firebase servers may be unreachable');
        }
      } else {
        debugPrint('Unexpected sign in error: $e');
      }

      _setError(errorMessage, context: 'login');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  /// Create account with email and password
  Future<bool> createAccount(String email, String password, String name) async {
    if (_isMockMode) {
      _setEmailLoading(true);
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      // Mock user creation for development - DON'T auto-login
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Create account successfully but DON'T set _user (no auto-login)
        debugPrint('Mock account created for: $email (not auto-logged in)');
        _setEmailLoading(false);
        return true;
      } else {
        _setError('Please fill in all fields', context: 'register');
        _setEmailLoading(false);
        return false;
      }
    }

    if (_auth == null) {
      _setError('Authentication service not available', context: 'register');
      return false;
    }

    try {
      _setEmailLoading(true);
      _clearError();

      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name but DON'T auto-login
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        await credential.user!.reload();
        // Sign out immediately after creating account - user must login manually
        await _auth!.signOut();
        _user = null;
      }

      debugPrint(
        'Account created: ${credential.user?.email} (not auto-logged in)',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      _setError(errorMessage, context: 'register');
      debugPrint('Create account error: $errorMessage');
      return false;
    } catch (e) {
      // Enhanced network error handling
      String errorMessage = 'An unexpected error occurred. Please try again.';

      // Handle case where Firebase Auth is not properly configured
      if (e.toString().contains('No Firebase App') ||
          e.toString().contains('app/no-app')) {
        errorMessage =
            'Firebase Authentication is not properly configured. Please enable Authentication in Firebase Console.';
        debugPrint('Firebase Auth not configured: $e');
      } else if (_isNetworkError(e)) {
        errorMessage =
            'Network error. Please check your internet connection and try again. If the problem persists, try restarting the app.';
        debugPrint('Network error during account creation: $e');

        // Attempt to fallback to mock mode for development
        if (!_isMockMode && kDebugMode) {
          debugPrint(
            'Considering fallback to mock mode due to persistent network issues',
          );
        }
      } else {
        debugPrint('Unexpected create account error: $e');
      }

      _setError(errorMessage, context: 'register');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  /// Check if an error is network-related
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('dns') ||
        errorString.contains('socket') ||
        errorString.contains('internet');
  }

  /// Get network troubleshooting steps for users
  static List<String> getNetworkTroubleshootingSteps() {
    return [
      'Check your internet connection',
      'Try switching between WiFi and mobile data',
      'Disable VPN if you\'re using one',
      'Restart the app and try again',
      'Clear app cache (Android) or restart device',
      'Check if Firebase services are accessible in your region',
    ];
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    if (_isMockMode) {
      _setGoogleLoading(true);
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      // Mock Google sign in for development
      _user = MockUser(email: 'demo@google.com', displayName: 'Demo User');
      debugPrint('Mock Google sign in successful');
      _setGoogleLoading(false);
      notifyListeners();
      return true;
    }

    try {
      _setGoogleLoading(true);
      _clearError();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth!.signInWithCredential(credential);

      debugPrint('Signed in with Google: ${currentUser?.email}');
      return true;
    } catch (e) {
      String errorMessage = 'Failed to sign in with Google. Please try again.';

      // Handle specific Google sign-in errors
      String errorString = e.toString().toLowerCase();

      if (errorString.contains('network-request-failed') ||
          errorString.contains('network')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (errorString.contains('sign_in_canceled') ||
          errorString.contains('cancelled')) {
        // User cancelled, don't show error message
        debugPrint('Google sign-in cancelled by user');
        return false;
      } else if (errorString.contains('sign_in_failed')) {
        errorMessage =
            'Google sign-in failed. Please ensure Google Play Services is up to date and try again.';
      } else if (errorString.contains(
        'account-exists-with-different-credential',
      )) {
        errorMessage =
            'An account already exists with this email using a different sign-in method. Please try signing in with email/password.';
      } else if (errorString.contains('popup-blocked')) {
        errorMessage =
            'Sign-in popup was blocked. Please allow popups and try again.';
      } else if (errorString.contains('popup-closed')) {
        errorMessage =
            'Sign-in was cancelled. Please complete the sign-in process.';
      } else if (errorString.contains('unauthorized-domain')) {
        errorMessage =
            'Sign-in not allowed from this domain. Please contact support.';
      } else if (errorString.contains('operation-not-allowed')) {
        errorMessage = 'Google sign-in is not enabled. Please contact support.';
      } else if (errorString.contains('invalid-credential')) {
        errorMessage = 'Google authentication failed. Please try again.';
      } else if (errorString.contains('user-disabled')) {
        errorMessage =
            'Your account has been disabled. Please contact support for assistance.';
      } else if (errorString.contains('too-many-requests')) {
        errorMessage =
            'Too many sign-in attempts. Please wait a moment and try again.';
      } else if (errorString.contains('internal-error')) {
        errorMessage = 'Internal error occurred. Please try again later.';
      }

      _setError(errorMessage, context: 'google-signin');
      debugPrint('Google sign in error: $e');
      return false;
    } finally {
      _setGoogleLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_isMockMode) {
      _setEmailLoading(true);
      _setGoogleLoading(true);
      await Future.delayed(const Duration(milliseconds: 500));
      _user = null;
      debugPrint('Mock sign out successful');
      _setEmailLoading(false);
      _setGoogleLoading(false);
      notifyListeners();
      return;
    }

    try {
      _setEmailLoading(true);
      _setGoogleLoading(true);
      _clearError();

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth?.signOut();
      debugPrint('User signed out');
    } catch (e) {
      _setError('Failed to sign out. Please try again.', context: 'signout');
      debugPrint('Sign out error: $e');
    } finally {
      _setEmailLoading(false);
      _setGoogleLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setEmailLoading(true);
      _clearError();

      await _auth!.sendPasswordResetEmail(email: email.trim());
      debugPrint('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      _setError(errorMessage, context: 'password-reset');
      debugPrint('Password reset error: $errorMessage');
      return false;
    } catch (e) {
      _setError(
        'Failed to send password reset email. Please try again.',
        context: 'password-reset',
      );
      debugPrint('Unexpected password reset error: $e');
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead or use a different email address.';
      case 'invalid-credential':
        return 'The email or password is incorrect. Please check your credentials and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email. Please check your email or create a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password if you forgot it.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password with at least 6 characters.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment before trying again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method. Please try signing in with that method.';
      case 'requires-recent-login':
        return 'For security, please sign out and sign in again to complete this action.';
      case 'credential-already-in-use':
        return 'This account is already linked to another user.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'app-not-authorized':
        return 'App is not authorized to use Firebase Authentication. Please contact support.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check the code and try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please restart the process.';
      case 'code-expired':
        return 'Verification code has expired. Please request a new code.';
      case 'missing-verification-code':
        return 'Please enter the verification code.';
      case 'missing-verification-id':
        return 'Verification ID is missing. Please restart the process.';
      case 'quota-exceeded':
        return 'Too many requests. Please try again later.';
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled. Please try again.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked. Please allow popups and try again.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled. Please complete the sign-in process.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for authentication. Please contact support.';
      default:
        // Handle unknown errors with helpful fallback messages
        String message = e.message ?? 'An error occurred. Please try again.';

        // Check for common patterns and provide helpful messages
        if (message.toLowerCase().contains('email') &&
            message.toLowerCase().contains('exist')) {
          return 'This email is already registered. Please sign in instead.';
        }
        if (message.toLowerCase().contains('password') &&
            message.toLowerCase().contains('weak')) {
          return 'Password is too weak. Please choose a stronger password.';
        }
        if (message.toLowerCase().contains('network') ||
            message.toLowerCase().contains('connection')) {
          return 'Network error. Please check your internet connection and try again.';
        }

        // Remove technical jargon if present
        if (message.contains('FirebaseError') || message.contains('auth/')) {
          return 'Authentication failed. Please try again or contact support if the problem persists.';
        }

        return message;
    }
  }

  /// Check if user's email is verified
  bool get isEmailVerified =>
      _isMockMode ? true : (currentUser?.emailVerified ?? false);

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    if (_isMockMode) {
      debugPrint('Mock email verification sent');
      return true;
    }

    try {
      if (currentUser != null && !isEmailVerified) {
        await currentUser!.sendEmailVerification();
        debugPrint('Email verification sent');
        return true;
      }
      return false;
    } catch (e) {
      _setError(
        'Failed to send verification email.',
        context: 'email-verification',
      );
      debugPrint('Email verification error: $e');
      return false;
    }
  }
}

/// Simple Mock User class for development when Firebase is not available
class MockUser {
  final String email;
  final String displayName;
  final String uid;
  final bool emailVerified;

  MockUser({required this.email, required this.displayName})
    : uid = 'mock-${email.hashCode}',
      emailVerified = true;

  String? get phoneNumber => null;
  String? get photoURL => null;
  bool get isAnonymous => false;
}
