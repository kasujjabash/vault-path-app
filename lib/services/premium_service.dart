import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/premium_features.dart';

/// Premium Service
/// Manages premium user status and Google Play in-app purchases
class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _premiumKey = 'is_premium_user';

  bool _isPremium = false;
  bool _isInitialized = false;
  bool _isStoreAvailable = false;
  bool _isPurchasing = false;
  String? _purchaseError;
  List<ProductDetails> _products = [];

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // Getters
  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isPurchasing => _isPurchasing;
  String? get purchaseError => _purchaseError;
  List<ProductDetails> get products => _products;

  /// Get product details for a given plan ID
  ProductDetails? getProduct(String planId) {
    final productId = _planToProductId(planId);
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Initialize premium service — loads stored status and sets up IAP
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumKey) ?? false;
      _isInitialized = true;
      debugPrint('PremiumService initialized - isPremium: $_isPremium');
      notifyListeners();

      await _initializeIAP();
    } catch (e) {
      debugPrint('Failed to initialize PremiumService: $e');
      _isInitialized = true;
    }
  }

  Future<void> _initializeIAP() async {
    try {
      _isStoreAvailable = await InAppPurchase.instance.isAvailable();
      if (!_isStoreAvailable) {
        debugPrint('Store not available');
        return;
      }

      // Subscribe to purchase stream
      _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdated,
        onError: (error) {
          debugPrint('Purchase stream error: $error');
          _purchaseError = 'Store error. Please try again.';
          _isPurchasing = false;
          notifyListeners();
        },
      );

      await loadProducts();
    } catch (e) {
      debugPrint('IAP initialization error: $e');
    }
  }

  /// Query product details from Google Play
  Future<void> loadProducts() async {
    try {
      const productIds = {
        PremiumFeatures.monthlySubscriptionId,
        PremiumFeatures.yearlySubscriptionId,
        PremiumFeatures.lifetimePurchaseId,
      };

      final response =
          await InAppPurchase.instance.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('Product query error: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found in store: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products from store');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  /// Handle incoming purchase updates from the store
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      debugPrint('Purchase update: ${purchase.productID} → ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          _purchaseError = null;
          notifyListeners();

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _isPurchasing = false;
          _purchaseError = null;
          await setPremium(true);
          await InAppPurchase.instance.completePurchase(purchase);

        case PurchaseStatus.error:
          _isPurchasing = false;
          _purchaseError = purchase.error?.message ?? 'Purchase failed';
          notifyListeners();

        case PurchaseStatus.canceled:
          _isPurchasing = false;
          _purchaseError = null;
          notifyListeners();
      }
    }
  }

  /// Trigger purchase for a plan ('monthly', 'yearly', 'lifetime')
  Future<bool> purchasePlan(String planId) async {
    if (!_isStoreAvailable) {
      _purchaseError = 'Google Play is not available on this device.';
      notifyListeners();
      return false;
    }

    final productId = _planToProductId(planId);
    if (productId.isEmpty) return false;

    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      _purchaseError =
          'This product is not available in your region. Please try again later.';
      notifyListeners();
      return false;
    }

    try {
      _isPurchasing = true;
      _purchaseError = null;
      notifyListeners();

      final purchaseParam = PurchaseParam(productDetails: product);
      return await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _isPurchasing = false;
      _purchaseError = 'Purchase failed. Please try again.';
      notifyListeners();
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  /// Restore previously completed purchases
  Future<void> restorePurchases() async {
    if (!_isStoreAvailable) return;
    try {
      _isPurchasing = true;
      _purchaseError = null;
      notifyListeners();
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _isPurchasing = false;
      _purchaseError = 'Restore failed. Please try again.';
      notifyListeners();
      debugPrint('Restore error: $e');
    }
  }

  String _planToProductId(String planId) {
    switch (planId) {
      case 'monthly':
        return PremiumFeatures.monthlySubscriptionId;
      case 'yearly':
        return PremiumFeatures.yearlySubscriptionId;
      case 'lifetime':
        return PremiumFeatures.lifetimePurchaseId;
      default:
        return '';
    }
  }

  /// Set premium status (persisted to SharedPreferences)
  Future<void> setPremium(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumKey, value);
      _isPremium = value;
      debugPrint('Premium status updated: $_isPremium');
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to set premium status: $e');
    }
  }

  /// Check if Firebase sync is allowed
  bool canUseFirebaseSync() {
    if (!_isInitialized) return false;
    return _isPremium;
  }

  /// Get error message for non-premium users trying to use Firebase sync
  String getFirebaseSyncErrorMessage() {
    return 'Cloud sync is a premium feature. Upgrade to Vault Path Premium to sync your data across devices.';
  }

  /// Check if user can use a premium feature
  bool canUsePremiumFeature(String featureName) {
    if (!_isInitialized) return false;
    return _isPremium;
  }

  /// Get premium feature restriction message
  String getPremiumFeatureMessage(String featureName) {
    return '$featureName is a premium feature. Upgrade to unlock this.';
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
