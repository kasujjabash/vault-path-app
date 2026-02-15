import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/foundation.dart' hide Category;
import '../models/account.dart';
import '../models/category.dart' as app_models;
import '../models/transaction.dart' as app_models;
import '../models/budget.dart';
import '../database/data_repository.dart';

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
        notifyListeners();
        return;
      }

      _currentUserId = userId;
      await _localRepo.initialize();

      // Enable Firestore offline persistence (different methods for web vs mobile)
      try {
        if (kIsWeb) {
          await _firestore!.enablePersistence(
            const PersistenceSettings(synchronizeTabs: true),
          );
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

      // Listen for network connectivity changes
      _firestore!
          .enableNetwork()
          .then((_) {
            _isOnline = true;
            notifyListeners();
            _performInitialSync();
          })
          .catchError((e) {
            debugPrint('Firestore network error: $e');
            _isOnline = false;
            notifyListeners();

            // If it's a permission error, don't retry
            if (e.toString().contains('PERMISSION_DENIED') ||
                e.toString().contains(
                  'Cloud Firestore API has not been used',
                )) {
              debugPrint('Firestore API not enabled - disabling sync service');
              _isInitialized = false; // Prevent further initialization attempts
              return;
            }
          });

      _isInitialized = true;
      debugPrint('FirebaseSyncService initialized successfully');
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
          e.toString().contains('Cloud Firestore API has not been used')) {
        debugPrint('Disabling sync due to Firestore permission error');
        _isOnline = false;
        _isInitialized = false;
        notifyListeners();
      }
    } finally {
      _setSyncing(false);
    }
  }

  /// Sync all data between local and remote
  Future<void> _syncAllData() async {
    await Future.wait([
      _syncAccounts(),
      _syncCategories(),
      _syncTransactions(),
      _syncBudgets(),
    ]);
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
}
