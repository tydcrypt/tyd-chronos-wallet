// Currency Management Service
// Handles multi-currency support and conversions

import 'package:flutter/foundation.dart';

class CurrencyService with ChangeNotifier {
  final Map<String, double> _exchangeRates = {};
  String _selectedCurrency = 'USD';
  
  CurrencyService() {
    // Initialize with default rates
    _exchangeRates['USD'] = 1.0;
    _exchangeRates['EUR'] = 0.85;
    _exchangeRates['GBP'] = 0.73;
    _exchangeRates['JPY'] = 110.0;
    _exchangeRates['ETH'] = 3500.0; // Mock ETH price
    _exchangeRates['BTC'] = 45000.0; // Mock BTC price
  }
  
  // Getters
  String get selectedCurrency => _selectedCurrency;
  Map<String, double> get exchangeRates => Map.from(_exchangeRates);
  
  double convertCurrency(double amount, String fromCurrency, String toCurrency) {
    if (!_exchangeRates.containsKey(fromCurrency) || !_exchangeRates.containsKey(toCurrency)) {
      throw Exception('Currency not supported: $fromCurrency → $toCurrency');
    }
    
    double usdAmount = amount / _exchangeRates[fromCurrency]!;
    return usdAmount * _exchangeRates[toCurrency]!;
  }
  
  void updateExchangeRate(String currency, double rate) {
    _exchangeRates[currency] = rate;
    notifyListeners();
  }
  
  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
  
  double getEthToCurrency(double ethAmount) {
    return convertCurrency(ethAmount, 'ETH', _selectedCurrency);
  }
}
