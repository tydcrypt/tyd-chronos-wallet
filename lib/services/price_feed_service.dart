import 'package:flutter/foundation.dart';

class PriceFeedService with ChangeNotifier {
  Map<String, double> _prices = {};

  Map<String, double> get prices => _prices;

  Future<Map<String, double>> getLivePrices() async {
    _prices = {
      'ETH': 2500.0,
      'BTC': 45000.0,
      'USDC': 1.0,
      'DAI': 1.0,
      'BTC': 43245.67,
      'ETH': 3000.45,
      'ARB': 1.67,
      'MATIC': 0.85,
    };
    notifyListeners();
    return _prices;
  }

  double getPrice(String symbol) {
    return _prices[symbol] ?? 0.0;
  }
}