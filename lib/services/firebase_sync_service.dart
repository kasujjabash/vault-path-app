import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/category.dart' as app_models;
import '../models/transaction.dart' as app_models;
import '../models/budget.dart';
import '../database/data_repository.dart';
import '../utils/app_constants.dart';

/// Firebase Sync Service
/// Handles synchronization between local database and Firestore
/// with offline support and conflict resolution
class FirebaseSyncService extends ChangeNotifier {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  FirebaseFirestore? _firestore;
  final DataRepository _localRepo = DataRepository();

  bool _isOnline = false;
  bool _isSyncing = false;
  bool _isInitialized = false;
  DateTime? _lastSyncTime;
  String? _currentUserId;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isInitialized => _isInitialized;

  /// Initialize sync service for a specific user
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      // Check if Firebase is available before accessing Firestore
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint(
          'Firebase not available, sync service will remain offline: $e',
        );
        _isInitialized = true;
        _isOnline = false;
        notifyListeners();
        return;
      }

      _currentUserId = userId;
      await _localRepo.initialize();

      // Enable Firestore offline persistence (different methods for web vs mobile)
      try {
        if (kIsWeb) {
          // Use Settings.persistenceEnabled for web
          _firestore!.settings = const Settings(persistenceEnabled: true);
        } else {
          // For mobile platforms, use Settings
          _firestore!.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        }
      } catch (e) {
        debugPrint(
          'Firestore persistence already enabled or not supported: $e',
        );
      }

      // Test Firestore connection first
      try {
        await _firestore!
            .doc('test/connection')
            .get()
            .timeout(const Duration(seconds: 5));
        _isOnline = true;
        debugPrint('Firestore connection test successful');
      } catch (e) {
        debugPrint('Firestore connection test failed: $e');
        _isOnline = false;

        // Check for specific permission/API errors
        if (e.toString().contains('PERMISSION_DENIED') ||
            e.toString().contains('Cloud Firestore API has not been used') ||
            e.toString().contains('firestore.googleapis.com')) {
          debugPrint(
            'Firestore API not enabled - sync service will remain offline',
          );
          _isInitialized = true; // Mark as initialized but offline
          notifyListeners();
          return;
        }
      }

      // Only try to enable network if we passed the connection test
      if (_isOnline) {
        try {
          await _firestore!.enableNetwork();
          _performInitialSync();
        } catch (e) {
          debugPrint('Failed to enable Firestore network: $e');
          _isOnline = false;
        }
      }

      _isInitialized = true;
      debugPrint(
        'FirebaseSyncService initialized successfully (Online: $_isOnline)',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize FirebaseSyncService: $e');
      _isInitialized = false;
    }
  }

  /// Perform initial sync when user comes online
  Future<void> _performInitialSync() async {
    if (!_isOnline || _currentUserId == null) return;

    _setSyncing(true);
    try {
      await _syncAllData();
      _lastSyncTime = DateTime.now();
      debugPrint('Initial sync completed');
    } catch (e) {
      debugPrint('Initial sync failed: $e');

      // If it's a permission error, disable sync service to prevent retries
      if (e.toString().contains('PERMISSION_DENIED') ||
          e.toString().contains('Cloud Firestore API has not been used') ||
          e.toString().contains('unavailable')) {
        debugPrint('Disabling sync due to Firestore error: $e');
        _isOnline = false;
        // Don't disable _isInitialized to allow retry later
        notifyListeners();
      }
    } finally {
      _setSyncing(false);
    }
  }

  /// Sync all data between local and remote
  Future<void> _syncAllData() async {
    if (!_isOnline || _currentUserId == null) {
      debugPrint('Skipping sync - offline or no user');
      return;
    }

    try {
      await Future.wait([
        _syncAccountsSafe(),
        _syncCategoriesSafe(),
        _syncTransactionsSafe(),
        _syncBudgetsSafe(),
        _syncUserSettingsSafe(),
      ]);
    } catch (e) {
      debugPrint('Sync all data failed: $e');
      // Check if it's a connectivity issue
      if (e.toString().contains('unavailable') ||
          e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('network')) {
        _isOnline = false;
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Set syncing state
  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  /// Get user's collection reference
  CollectionReference? _getUserCollection(String collection) {
    if (_firestore == null || _currentUserId == null) return null;
    return _firestore!
        .collection('users')
        .doc(_currentUserId!)
        .collection(collection);
  }

  // ACCOUNT SYNC

  /// Sync accounts between local and remote
  Future<void> _syncAccounts() async {
    if (_currentUserId == null) return;

    final collection = _getUserCollection('accounts');
    if (collection == null) return;

    final localAccounts = await _localRepo.getAccounts();
    final remoteSnapshot = await collection.get();

    final remoteAccounts =
        remoteSnapshot.docs
            .map(
              (doc) => Account.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList();

    // Merge accounts (remote takes precedence for conflicts)
    await _mergeAccounts(localAccounts, remoteAccounts, collection);
  }

  /// Merge local and remote accounts
  Future<void> _mergeAccounts(
    List<Account> localAccounts,
    List<Account> remoteAccounts,
    CollectionReference? collection,
  ) async {
    if (collection == null) return;

    final Map<String, Account> localMap = {
      for (var account in localAccounts) account.id: account,
    };
    final Map<String, Account> remoteMap = {
      for (var account in remoteAccounts) account.id: account,
    };

    // Add/update remote accounts to local
    for (final remoteAccount in remoteAccounts) {
      final localAccount = localMap[remoteAccount.id];
      if (localAccount == null) {
        // New remote account - add to local
        await _localRepo.insertAccount(remoteAccount);
      } else if (remoteAccount.updatedAt.isAfter(localAccount.updatedAt)) {
        // Remote is newer - update local
        await _localRepo.updateAccount(remoteAccount);
      }
    }

    // Add local-only accounts to remote
    for (final localAccount in localAccounts) {
      if (!remoteMap.containsKey(localAccount.id)) {
        await collection.doc(localAccount.id).set(localAccount.toMap());
      }
    }
  }

  // CATEGORY SYNC

  /// Sync categories between local and remote
  Future<void> _syncCategories() async {
    if (_currentUserId == null || !_isInitialized) return;

    final collection = _getUserCollection('categories');
    if (collection == null) return;

    final localCategories = await _localRepo.getCategories();
    final remoteSnapshot = await collection.get();

    final remoteCategories =
        remoteSnapshot.docs
            .map(
              (doc) => app_models.Category.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList();

    await _mergeCategories(localCategories, remoteCategories, collection);
  }

  /// Merge local and remote categories
  Future<void> _mergeCategories(
    List<app_models.Category> localCategories,
    List<app_models.Category> remoteCategories,
    CollectionReference? collection,
  ) async {
    if (collection == null) return;
    final Map<String, app_models.Category> localMap = {
      for (var category in localCategories) category.id: category,
    };
    final Map<String, app_models.Category> remoteMap = {
      for (var category in remoteCategories) category.id: category,
    };

    // Add/update remote categories to local
    for (final remoteCategory in remoteCategories) {
      final localCategory = localMap[remoteCategory.id];
      if (localCategory == null) {
        await _localRepo.insertCategory(remoteCategory);
      } else if (remoteCategory.updatedAt.isAfter(localCategory.updatedAt)) {
        await _localRepo.updateCategory(remoteCategory);
      }
    }

    // Add local-only categories to remote
    for (final localCategory in localCategories) {
      if (!remoteMap.containsKey(localCategory.id)) {
        await collection.doc(localCategory.id).set(localCategory.toMap());
      }
    }
  }

  // TRANSACTION SYNC

  /// Sync transactions between local and remote
  Future<void> _syncTransactions() async {
    if (_currentUserId == null || !_isInitialized) return;

    final collection = _getUserCollection('transactions');
    if (collection == null) return;

    final localTransactions = await _localRepo.getTransactions();
    final remoteSnapshot = await collection.get();

    final remoteTransactions =
        remoteSnapshot.docs
            .map(
              (doc) => app_models.Transaction.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList();

    await _mergeTransactions(localTransactions, remoteTransactions, collection);
  }

  /// Merge local and remote transactions
  Future<void> _mergeTransactions(
    List<app_models.Transaction> localTransactions,
    List<app_models.Transaction> remoteTransactions,
    CollectionReference? collection,
  ) async {
    if (collection == null) return;
    final Map<String, app_models.Transaction> localMap = {
      for (var transaction in localTransactions) transaction.id: transaction,
    };
    final Map<String, app_models.Transaction> remoteMap = {
      for (var transaction in remoteTransactions) transaction.id: transaction,
    };

    // Add/update remote transactions to local
    for (final remoteTransaction in remoteTransactions) {
      final localTransaction = localMap[remoteTransaction.id];
      if (localTransaction == null) {
        await _localRepo.insertTransaction(remoteTransaction);
      } else if (remoteTransaction.updatedAt.isAfter(
        localTransaction.updatedAt,
      )) {
        await _localRepo.updateTransaction(remoteTransaction);
      }
    }

    // Add local-only transactions to remote
    for (final localTransaction in localTransactions) {
      if (!remoteMap.containsKey(localTransaction.id)) {
        await collection.doc(localTransaction.id).set(localTransaction.toMap());
      }
    }
  }

  // BUDGET SYNC

  /// Sync budgets between local and remote
  Future<void> _syncBudgets() async {
    if (_currentUserId == null || !_isInitialized) return;

    final collection = _getUserCollection('budgets');
    if (collection == null) return;

    final localBudgets = await _localRepo.getBudgets();
    final remoteSnapshot = await collection.get();

    final remoteBudgets =
        remoteSnapshot.docs
            .map(
              (doc) => Budget.fromMap({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }),
            )
            .toList();

    await _mergeBudgets(localBudgets, remoteBudgets, collection);
  }

  /// Merge local and remote budgets
  Future<void> _mergeBudgets(
    List<Budget> localBudgets,
    List<Budget> remoteBudgets,
    CollectionReference? collection,
  ) async {
    if (collection == null) return;
    final Map<String, Budget> localMap = {
      for (var budget in localBudgets) budget.id: budget,
    };
    final Map<String, Budget> remoteMap = {
      for (var budget in remoteBudgets) budget.id: budget,
    };

    // Add/update remote budgets to local
    for (final remoteBudget in remoteBudgets) {
      final localBudget = localMap[remoteBudget.id];
      if (localBudget == null) {
        await _localRepo.insertBudget(remoteBudget);
      } else if (remoteBudget.updatedAt.isAfter(localBudget.updatedAt)) {
        await _localRepo.updateBudget(remoteBudget);
      }
    }

    // Add local-only budgets to remote
    for (final localBudget in localBudgets) {
      if (!remoteMap.containsKey(localBudget.id)) {
        await collection.doc(localBudget.id).set(localBudget.toMap());
      }
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    if (_currentUserId == null) {
      debugPrint('Cannot sync: no user signed in');
      return;
    }

    _setSyncing(true);
    try {
      await _syncAllData();
      _lastSyncTime = DateTime.now();
      debugPrint('Manual sync completed');
    } catch (e) {
      debugPrint('Manual sync failed: $e');
      rethrow;
    } finally {
      _setSyncing(false);
    }
  }

  /// Clear all user data on sign out
  Future<void> clearUserData() async {
    _currentUserId = null;
    _lastSyncTime = null;
    _isOnline = false;
    _isSyncing = false;
    notifyListeners();
  }

  /// Delete transaction from Firebase
  Future<void> deleteTransactionFromFirebase(String transactionId) async {
    if (_firestore == null || _currentUserId == null) {
      debugPrint(
        'Firebase not available or user not signed in, skipping Firebase deletion',
      );
      return;
    }

    try {
      final collection = _getUserCollection('transactions');
      if (collection != null) {
        await collection.doc(transactionId).delete();
        debugPrint('Transaction deleted from Firebase: $transactionId');
      }
    } catch (e) {
      debugPrint('Error deleting transaction from Firebase: $e');
      // Don't rethrow - local deletion should still work even if Firebase deletion fails
    }
  }

  /// Delete account from Firebase
  Future<void> deleteAccountFromFirebase(String accountId) async {
    if (_firestore == null || _currentUserId == null) {
      debugPrint(
        'Firebase not available or user not signed in, skipping Firebase deletion',
      );
      return;
    }

    try {
      final collection = _getUserCollection('accounts');
      if (collection != null) {
        await collection.doc(accountId).delete();
        debugPrint('Account deleted from Firebase: $accountId');
      }
    } catch (e) {
      debugPrint('Error deleting account from Firebase: $e');
      // Don't rethrow - local deletion should still work even if Firebase deletion fails
    }
  }

  /// Delete category from Firebase
  Future<void> deleteCategoryFromFirebase(String categoryId) async {
    if (_firestore == null || _currentUserId == null) {
      debugPrint(
        'Firebase not available or user not signed in, skipping Firebase deletion',
      );
      return;
    }

    try {
      final collection = _getUserCollection('categories');
      if (collection != null) {
        await collection.doc(categoryId).delete();
        debugPrint('Category deleted from Firebase: $categoryId');
      }
    } catch (e) {
      debugPrint('Error deleting category from Firebase: $e');
      // Don't rethrow - local deletion should still work even if Firebase deletion fails
    }
  }

  /// Delete budget from Firebase
  Future<void> deleteBudgetFromFirebase(String budgetId) async {
    if (_firestore == null || _currentUserId == null) {
      debugPrint(
        'Firebase not available or user not signed in, skipping Firebase deletion',
      );
      return;
    }

    try {
      final collection = _getUserCollection('budgets');
      if (collection != null) {
        await collection.doc(budgetId).delete();
        debugPrint('Budget deleted from Firebase: $budgetId');
      }
    } catch (e) {
      debugPrint('Error deleting budget from Firebase: $e');
      // Don't rethrow - local deletion should still work even if Firebase deletion fails
    }
  }

  // USER SETTINGS SYNC

  /// Safe wrapper for syncing user settings
  Future<void> _syncUserSettingsSafe() async {
    try {
      await _syncUserSettings();
    } catch (e) {
      debugPrint('Safe sync user settings failed: $e');
      // Don't rethrow - continue with other syncs
    }
  }

  /// Safe wrapper for syncing accounts
  Future<void> _syncAccountsSafe() async {
    try {
      await _syncAccounts();
    } catch (e) {
      debugPrint('Safe sync accounts failed: $e');
      // Don't rethrow - continue with other syncs
    }
  }

  /// Safe wrapper for syncing categories
  Future<void> _syncCategoriesSafe() async {
    try {
      await _syncCategories();
    } catch (e) {
      debugPrint('Safe sync categories failed: $e');
      // Don't rethrow - continue with other syncs
    }
  }

  /// Safe wrapper for syncing transactions
  Future<void> _syncTransactionsSafe() async {
    try {
      await _syncTransactions();
    } catch (e) {
      debugPrint('Safe sync transactions failed: $e');
      // Don't rethrow - continue with other syncs
    }
  }

  /// Safe wrapper for syncing budgets
  Future<void> _syncBudgetsSafe() async {
    try {
      await _syncBudgets();
    } catch (e) {
      debugPrint('Safe sync budgets failed: $e');
      // Don't rethrow - continue with other syncs
    }
  }

  /// Sync user settings between local SharedPreferences and Firebase
  Future<void> _syncUserSettings() async {
    if (_currentUserId == null || _firestore == null || !_isOnline) {
      debugPrint('Skipping settings sync - no user, firestore, or offline');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final doc = _firestore!
          .collection('users')
          .doc(_currentUserId!)
          .collection('settings')
          .doc('preferences');

      // Get remote settings with timeout
      final remoteDoc = await doc.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Settings fetch timed out',
            const Duration(seconds: 10),
          );
        },
      );

      if (remoteDoc.exists) {
        // Remote settings exist - update local with remote (remote takes precedence)
        final remoteData = remoteDoc.data();
        if (remoteData != null) {
          await prefs.setBool(
            AppConstants.keyBudgetAlertsEnabled,
            remoteData['budgetAlertsEnabled'] ?? true,
          );
          await prefs.setDouble(
            AppConstants.keyBudgetAlertPercentage,
            (remoteData['budgetAlertPercentage'] as num?)?.toDouble() ?? 80.0,
          );
          await prefs.setBool(
            AppConstants.keyDarkMode,
            remoteData['darkMode'] ?? false,
          );
          await prefs.setString(
            AppConstants.keyDefaultCurrency,
            remoteData['defaultCurrency'] ?? 'USD',
          );
          await prefs.setBool(
            AppConstants.keyNotificationsEnabled,
            remoteData['notificationsEnabled'] ?? true,
          );
          await prefs.setBool(
            AppConstants.keyBiometricEnabled,
            remoteData['biometricEnabled'] ?? false,
          );
          await prefs.setBool(
            AppConstants.keyAutoBackup,
            remoteData['autoBackup'] ?? false,
          );

          debugPrint('User settings synced from Firebase');
        }
      } else {
        // No remote settings - upload current local settings
        await _uploadUserSettings();
      }
    } catch (e) {
      debugPrint('Error syncing user settings: $e');

      // Handle specific Firebase errors
      if (e.toString().contains('unavailable') ||
          e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('timeout')) {
        debugPrint('Firebase temporarily unavailable for settings sync');
        _isOnline = false;
        notifyListeners();
      }

      // Don't rethrow to prevent app crashes
    }
  }

  /// Upload current local settings to Firebase
  Future<void> _uploadUserSettings() async {
    if (_currentUserId == null || _firestore == null || !_isOnline) {
      debugPrint('Skipping settings upload - no user, firestore, or offline');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final doc = _firestore!
          .collection('users')
          .doc(_currentUserId!)
          .collection('settings')
          .doc('preferences');

      final settingsData = {
        'budgetAlertsEnabled':
            prefs.getBool(AppConstants.keyBudgetAlertsEnabled) ?? true,
        'budgetAlertPercentage':
            prefs.getDouble(AppConstants.keyBudgetAlertPercentage) ?? 80.0,
        'darkMode': prefs.getBool(AppConstants.keyDarkMode) ?? false,
        'defaultCurrency':
            prefs.getString(AppConstants.keyDefaultCurrency) ?? 'USD',
        'notificationsEnabled':
            prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true,
        'biometricEnabled':
            prefs.getBool(AppConstants.keyBiometricEnabled) ?? false,
        'autoBackup': prefs.getBool(AppConstants.keyAutoBackup) ?? false,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await doc
          .set(settingsData)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Settings upload timed out',
                const Duration(seconds: 10),
              );
            },
          );
      debugPrint('User settings uploaded to Firebase');
    } catch (e) {
      debugPrint('Error uploading user settings: $e');

      // Handle specific Firebase errors
      if (e.toString().contains('unavailable') ||
          e.toString().contains('UNAVAILABLE') ||
          e.toString().contains('timeout')) {
        debugPrint('Firebase temporarily unavailable for settings upload');
        _isOnline = false;
        notifyListeners();
      }

      // Don't rethrow to prevent app crashes
    }
  }

  /// Force upload settings when they change locally
  Future<void> syncSettingsToFirebase() async {
    if (_isOnline && _currentUserId != null && _firestore != null) {
      try {
        await _uploadUserSettings();
      } catch (e) {
        debugPrint('Failed to sync settings to Firebase: $e');
        // Don't rethrow to prevent app crashes
      }
    }
  }

  /// Manual settings sync for immediate updates
  Future<void> forceSyncSettings() async {
    try {
      await _syncUserSettings();
    } catch (e) {
      debugPrint('Failed to force sync settings: $e');
      // Don't rethrow to prevent app crashes
    }
  }
}
