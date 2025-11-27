// Currency Service
// Handles currency conversions and exchange rates

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'NGN': '₦',
    'INR': '₹',
    'ETH': 'Ξ',
    'BTC': '₿',
  };

  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'CNY': 6.45,
    'NGN': 410.0,
    'INR': 75.0,
    'ETH': 3500.0,
    'BTC': 45000.0,
  };
  
  String _selectedCurrency = 'USD';

  String getSelectedCurrency() {
    return _selectedCurrency;
  }

  String formatCurrency(double amount, {String? currency}) {
    final curr = currency ?? _selectedCurrency;
    final symbol = getCurrencySymbol(curr);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String getCurrencySymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }

  String getCurrencyName(String currency) {
    switch (currency) {
      case 'USD': return 'US Dollar';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      case 'JPY': return 'Japanese Yen';
      case 'CNY': return 'Chinese Yuan';
      case 'NGN': return 'Nigerian Naira';
      case 'INR': return 'Indian Rupee';
      case 'ETH': return 'Ethereum';
      case 'BTC': return 'Bitcoin';
      default: return currency;
    }
  }

  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
  }

  // Getter for the currency symbols
  Map<String, String> get currencySymbolsMap => currencySymbols;
  
  // Method that might be called
  double convertCurrency(double amount, String fromCurrency, String toCurrency) {
    if (!_exchangeRates.containsKey(fromCurrency) || !_exchangeRates.containsKey(toCurrency)) {
      throw Exception('Currency not supported: $fromCurrency → $toCurrency');
    }
    
    double usdAmount = amount / _exchangeRates[fromCurrency]!;
    return usdAmount * _exchangeRates[toCurrency]!;
  }
  
  void updateExchangeRate(String currency, double rate) {
    _exchangeRates[currency] = rate;
  }
  
  double getExchangeRate(String currency) {
    return _exchangeRates[currency] ?? 1.0;
  }
}
