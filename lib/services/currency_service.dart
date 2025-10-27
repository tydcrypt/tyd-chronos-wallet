// Currency Service
// Handles currency conversions and exchange rates

class CurrencyService {
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.73,
    'JPY': 110.0,
    'ETH': 3500.0,
    'BTC': 45000.0,
  };
  
  CurrencyService() {
    print("CurrencyService initialized");
  }
  
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
