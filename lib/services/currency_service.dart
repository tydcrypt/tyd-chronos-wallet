import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _currencyKey = 'selected_currency';
  static const String defaultCurrency = 'USD';
  
  static final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'BTC': '₿',
    'ETH': 'Ξ',
    'NGN': '₦',
    'CAD': '\$',
    'AUD': '\$',
  };

  static final Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'NGN': 'Nigerian Naira',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
  };

  static final Map<String, double> exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CNY': 6.45,
    'INR': 74.0,
    'BTC': 0.000021,
    'ETH': 0.00031,
    'NGN': 410.0,
    'CAD': 1.25,
    'AUD': 1.35,
  };

  static Future<String> getSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? defaultCurrency;
  }

  static Future<void> setSelectedCurrency(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? '\$';
  }

  static String getCurrencyName(String currencyCode) {
    return currencyNames[currencyCode] ?? 'US Dollar';
  }

  static double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    final fromRate = exchangeRates[fromCurrency] ?? 1.0;
    final toRate = exchangeRates[toCurrency] ?? 1.0;
    
    final amountInUSD = amount / fromRate;
    return amountInUSD * toRate;
  }

  static String formatCurrency(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final convertedAmount = convertAmount(amount, 'USD', currencyCode);
    
    if (currencyCode == 'BTC' || currencyCode == 'ETH') {
      return '$symbol${convertedAmount.toStringAsFixed(8)}';
    } else if (currencyCode == 'JPY' || currencyCode == 'INR' || currencyCode == 'NGN') {
      return '$symbol${convertedAmount.toStringAsFixed(0)}';
    } else {
      return '$symbol${convertedAmount.toStringAsFixed(2)}';
    }
  }
}