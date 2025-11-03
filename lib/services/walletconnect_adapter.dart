import 'package:flutter/foundation.dart';
import 'walletconnect_service.dart';
import '../constants/deployment.dart';

// This adapter makes the real WalletConnectService compatible
// with your existing main_updated.dart that expects mock methods
class WalletConnectService extends ChangeNotifier {
  final RealWalletConnectService _realService = RealWalletConnectService();

  bool _isConnected = false;
  String? _connectedWallet;
  String? _ethereumAddress;

  bool get isConnected => _isConnected;
  String? get connectedWallet => _connectedWallet;
  String? get ethereumAddress => _ethereumAddress;

  Future<void> initialize() async {
    await _realService.initialize();

    // Map real service state to expected mock state
    _realService.addListener(() {
      _isConnected = _realService.isConnected;
      _connectedWallet = _realService.connectedWallet;
      _ethereumAddress = _realService.ethereumAddress;
      notifyListeners();
    });
  }

  Future<void> connectToDApp(String uri) async {
    try {
      await _realService.connectToDApp(uri);
    } catch (e) {
      print('Error connecting to DApp: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    // Disconnect all active sessions in real service
    for (final session in _realService.activeSessions) {
      await _realService.disconnectSession(session.topic);
    }
    _isConnected = false;
    _connectedWallet = null;
    _ethereumAddress = null;
    notifyListeners();
  }

  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'wallet': _connectedWallet,
      'chainId': _isConnected ? '0x${DeploymentConstants.sepoliaChainId.toRadixString(16)}' : null,
      'ethereumAddress': _ethereumAddress,
      'network': 'Sepolia Testnet',
      'rpcUrl': DeploymentConstants.sepoliaRpcUrl,
    };
  }

  // Add method to switch networks if needed
  Future<void> switchToSepolia() async {
    // In a real implementation, this would prompt the user to switch networks
    // For now, we'll just update our internal state
    print('🔄 Switching to Sepolia Testnet (Chain ID: ${DeploymentConstants.sepoliaChainId})');
    notifyListeners();
  }

  Future<void> switchToMainnet() async {
    print('🔄 Switching to Ethereum Mainnet (Chain ID: 1)');
    notifyListeners();
  }
}
