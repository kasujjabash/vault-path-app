import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple connectivity checker for network troubleshooting
class ConnectivityHelper {
  /// Check if device has basic internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      if (kIsWeb) {
        // For web, we'll assume connectivity and let Firebase handle errors
        return true;
      }

      // Try to lookup a reliable DNS server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      debugPrint('No internet connection detected');
      return false;
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      return false; // Assume no connection if check fails
    }
  }

  /// Check Firebase connectivity specifically
  static Future<bool> canReachFirebase() async {
    try {
      if (kIsWeb) {
        // For web, assume connectivity
        return true;
      }

      // Try to reach Firebase domains
      final results = await Future.wait([
        InternetAddress.lookup('firebase.google.com').timeout(
          const Duration(seconds: 5),
          onTimeout: () => <InternetAddress>[],
        ),
        InternetAddress.lookup('firebaseapp.com').timeout(
          const Duration(seconds: 5),
          onTimeout: () => <InternetAddress>[],
        ),
      ]);

      return results.any((result) => result.isNotEmpty);
    } catch (e) {
      debugPrint('Firebase connectivity check failed: $e');
      return false;
    }
  }

  /// Get user-friendly network error message
  static String getNetworkErrorMessage(
    bool hasInternet,
    bool canReachFirebase,
  ) {
    if (!hasInternet) {
      return 'No internet connection. Please check your network settings and try again.';
    } else if (!canReachFirebase) {
      return 'Cannot reach Firebase servers. Please check your connection or try again later.';
    } else {
      return 'Network error occurred. Please try again.';
    }
  }
}
