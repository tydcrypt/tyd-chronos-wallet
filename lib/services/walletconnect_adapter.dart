import 'package:flutter/foundation.dart';
import 'walletconnect_service.dart';

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
    _ethereumAddress = _realService.ethereumAddress;
    _isConnected = _realService.isInitialized;
    
    // Set up listeners for real service changes
    _realService.addListener(_onRealServiceUpdate);
    
    notifyListeners();
  }
  
  void _onRealServiceUpdate() {
    // Update our state when the real service changes
    _ethereumAddress = _realService.ethereumAddress;
    _isConnected = _realService.isInitialized && _realService.activeSessions.isNotEmpty;
    
    // If we have active sessions, set connected wallet
    if (_realService.activeSessions.isNotEmpty) {
      _connectedWallet = _realService.activeSessions.first.peer.metadata.name;
    } else {
      _connectedWallet = null;
    }
    
    notifyListeners();
  }
  
  Future<void> connectToWallet() async {
    // For mock compatibility - in real usage, DApps connect TO us
    // This simulates the connection process
    _isConnected = true;
    _connectedWallet = 'TydChronos Wallet';
    notifyListeners();
  }
  
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'wallet': _connectedWallet,
      'chainId': _isConnected ? '0x1' : null,
      'ethereumAddress': _ethereumAddress,
    };
  }
  
  Future<void> disconnect() async {
    // Disconnect all active sessions in real service
    for (final session in _realService.activeSessions) {
      await _realService.disconnectSession(session.topic);
    }
    
    // Update mock state
    _isConnected = false;
    _connectedWallet = null;
    notifyListeners();
  }
  
  // Get the real service for advanced operations
  RealWalletConnectService get realService => _realService;
}

// Real service implementation (renamed to avoid conflicts)
class RealWalletConnectService extends ChangeNotifier {
  static const String projectId = '4d57c8f2cd69c1ce95a1571780af06cb';
  
  late dynamic _web3wallet; // Use dynamic to avoid import issues
  final dynamic _ethereumService; // Use dynamic to avoid import issues
  
  bool _isInitialized = false;
  List<dynamic> _activeSessions = [];
  String? _ethereumAddress;

  bool get isInitialized => _isInitialized;
  List<dynamic> get activeSessions => _activeSessions;
  String? get ethereumAddress => _ethereumAddress;

  RealWalletConnectService() : _ethereumService = null {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // This would initialize the real WalletConnect service
      // For now, we'll simulate initialization
      await Future.delayed(const Duration(seconds: 1));
      
      _isInitialized = true;
      _ethereumAddress = '0x742d35Cc6634C0532925a3b8D123456'; // Mock address
      
      notifyListeners();
    } catch (e) {
      // Handle initialization errors silently
    }
  }

  Future<void> disconnectSession(String topic) async {
    _activeSessions.removeWhere((session) => session.topic == topic);
    notifyListeners();
  }
}
