import 'package:flutter/foundation.dart';

class WalletConnectService extends ChangeNotifier {
  bool _isConnected = false;
  String? _connectedWallet;
  
  // Proper method signatures that match what the components expect
  bool get isConnected => _isConnected;
  String? get connectedWallet => _connectedWallet;
  
  Future<void> initialize() async {
    print('[WalletConnect] Service initialized');
    // Initialization logic here
  }
  
  Future<void> connectToWallet() async {
    print('[WalletConnect] Connecting to wallet...');
    // Simulate connection
    await Future.delayed(const Duration(seconds: 2));
    _isConnected = true;
    _connectedWallet = 'MetaMask';
    notifyListeners();
    print('[WalletConnect] Connected to $_connectedWallet');
  }
  
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'wallet': _connectedWallet,
      'chainId': _isConnected ? '0x1' : null,
    };
  }
  
  Future<void> disconnect() async {
    print('[WalletConnect] Disconnecting...');
    _isConnected = false;
    _connectedWallet = null;
    notifyListeners();
    print('[WalletConnect] Disconnected');
  }
}
