
import 'package:flutter/foundation.dart';

class NetworkModeManager extends ChangeNotifier {
  bool _isTestnet = false;
  String _currentNetwork = 'Ethereum Mainnet';

  NetworkModeManager() {
    // Constructor
  }

  Future<void> initialize() async {
    // Initialize network mode manager
    await fetchLivePrices();
  }

  bool get isTestnet => _isTestnet;
  String get currentNetwork => _currentNetwork;

  Future<void> fetchLivePrices() async {
    // Mock implementation for price fetching
    await Future.delayed(Duration(milliseconds: 100));
    print('📊 Prices fetched successfully');
  }

  void toggleNetwork() {
    _isTestnet = !_isTestnet;
    _currentNetwork = _isTestnet ? 'Goerli Testnet' : 'Ethereum Mainnet';
    notifyListeners();
    print('🔄 Network switched to: $_currentNetwork');
  }

  void setNetwork(bool isTestnet) {
    _isTestnet = isTestnet;
    _currentNetwork = isTestnet ? 'Goerli Testnet' : 'Ethereum Mainnet';
    notifyListeners();
  }
}
