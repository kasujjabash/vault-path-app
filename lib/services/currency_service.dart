import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Currency model
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const Currency ugx = Currency(
    code: 'UGX',
    symbol: 'UGX',
    name: 'Ugandan Shilling',
  );

  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
  );

  static const List<Currency> supportedCurrencies = [ugx, usd];

  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }
}

/// Currency Service for managing user's preferred currency
class CurrencyService extends ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  static const String _currencyKey = 'preferred_currency';
  Currency _currentCurrency = Currency.usd; // Default to USD

  Currency get currentCurrency => _currentCurrency;
  List<Currency> get supportedCurrencies => Currency.supportedCurrencies;

  /// Initialize the currency service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCurrencyCode = prefs.getString(_currencyKey);

      if (savedCurrencyCode != null) {
        final currency = Currency.fromCode(savedCurrencyCode);
        if (currency != null) {
          _currentCurrency = currency;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing currency service: $e');
    }
  }

  /// Change the current currency
  Future<void> setCurrency(Currency currency) async {
    try {
      _currentCurrency = currency;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting currency: $e');
    }
  }
}
