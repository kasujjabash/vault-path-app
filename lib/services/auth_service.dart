import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

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

  /// Set loading state (deprecated - use specific methods)
  void _setLoading(bool loading) {
    _isEmailLoading = loading;
    _isGoogleLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
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
        _setError('Invalid email or password');
        _setEmailLoading(false);
        return false;
      }
    }

    if (_auth == null) {
      _setError(
        'Authentication service not available. Please check Firebase setup.',
      );
      return false;
    }

    try {
      _setEmailLoading(true);
      _clearError();

      // Validate input before attempting authentication
      if (email.trim().isEmpty || password.isEmpty) {
        _setError('Please enter both email and password');
        return false;
      }

      if (!email.contains('@') || !email.contains('.')) {
        _setError('Please enter a valid email address');
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
      _setError(errorMessage);
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

      _setError(errorMessage);
      return false;
    } finally {
      _setEmailLoading(false);
    }
  }

  /// Create account with email and password
  Future<bool> createAccount(String email, String password, String name) async {
    if (_isMockMode) {
      _setLoading(true);
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      // Mock user creation for development - DON'T auto-login
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Create account successfully but DON'T set _user (no auto-login)
        debugPrint('Mock account created for: $email (not auto-logged in)');
        _setLoading(false);
        return true;
      } else {
        _setError('Please fill in all fields');
        _setLoading(false);
        return false;
      }
    }

    if (_auth == null) {
      _setError('Authentication service not available');
      return false;
    }

    try {
      _setLoading(true);
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
      _setError(errorMessage);
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

      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
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

      // Handle specific network errors
      if (e.toString().contains('network-request-failed')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('sign_in_canceled')) {
        // User cancelled, don't show error
        return false;
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage =
            'Sign in failed. Please ensure Google Play Services is installed and try again.';
      }

      _setError(errorMessage);
      debugPrint('Google sign in error: $e');
      return false;
    } finally {
      _setGoogleLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_isMockMode) {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 500));
      _user = null;
      debugPrint('Mock sign out successful');
      _setLoading(false);
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth?.signOut();
      debugPrint('User signed out');
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
      debugPrint('Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth!.sendPasswordResetEmail(email: email.trim());
      debugPrint('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      debugPrint('Password reset error: $errorMessage');
      return false;
    } catch (e) {
      _setError('Failed to send password reset email. Please try again.');
      debugPrint('Unexpected password reset error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'The email or password is incorrect. Please check your credentials and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email. Please check your email or create a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'app-not-authorized':
        return 'App is not authorized to use Firebase Authentication.';
      default:
        // Provide the original message but make it more user-friendly
        String message = e.message ?? 'An error occurred. Please try again.';
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
      _setError('Failed to send verification email.');
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
