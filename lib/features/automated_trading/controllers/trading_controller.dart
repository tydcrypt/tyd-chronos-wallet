import 'package:flutter/foundation.dart';
import '../services/trading_service.dart';

class TradingController with ChangeNotifier {
  final TradingService _tradingService = TradingService();
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadTradingData() async {
    _setLoading(true);
    _error = '';
    await Future.delayed(const Duration(seconds: 2));
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
