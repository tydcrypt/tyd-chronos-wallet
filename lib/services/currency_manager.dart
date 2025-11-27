import 'package:flutter/foundation.dart';

class CurrencyManager extends ChangeNotifier {
  String _selectedCurrency = 'USD';
  
  String get selectedCurrency => _selectedCurrency;
  
  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
    print('💰 Currency changed to: $currency');
  }
  
  String getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'NGN': return '₦';
      case 'INR': return '₹';
      default: return '\$';
    }
  }
}
