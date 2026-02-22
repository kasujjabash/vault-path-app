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

  static const Currency eur = Currency(code: 'EUR', symbol: '€', name: 'Euro');

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
  );

  static const Currency chf = Currency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
  );

  static const Currency brl = Currency(
    code: 'BRL',
    symbol: 'R\$',
    name: 'Brazilian Real',
  );

  static const Currency krw = Currency(
    code: 'KRW',
    symbol: '₩',
    name: 'South Korean Won',
  );

  static const Currency mxn = Currency(
    code: 'MXN',
    symbol: 'MX\$',
    name: 'Mexican Peso',
  );

  static const Currency zar = Currency(
    code: 'ZAR',
    symbol: 'R',
    name: 'South African Rand',
  );

  static const Currency ngn = Currency(
    code: 'NGN',
    symbol: '₦',
    name: 'Nigerian Naira',
  );

  static const List<Currency> supportedCurrencies = [
    usd,
    eur,
    gbp,
    ugx,
    jpy,
    cad,
    aud,
    chf,
    cny,
    inr,
    brl,
    krw,
    mxn,
    zar,
    ngn,
  ];

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
      // Only proceed if currency is actually different
      if (_currentCurrency.code == currency.code) {
        return;
      }

      _currentCurrency = currency;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);

      // Use a small delay to ensure any ongoing navigation is complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Force immediate notification to all listeners
      notifyListeners();

      // Additional delayed notification to catch any late widgets
      Future.delayed(const Duration(milliseconds: 200), () {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error setting currency: $e');
    }
  }

  /// Force refresh all currency displays
  void forceRefresh() {
    notifyListeners();
  }
}
