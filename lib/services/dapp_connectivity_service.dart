import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Service to handle DApp connection requests and messaging
class DAppConnectivityService with ChangeNotifier {
  static final DAppConnectivityService _instance = DAppConnectivityService._internal();
  factory DAppConnectivityService() => _instance;
  DAppConnectivityService._internal() {
    _initializeMessageHandling();
  }

  String? _connectedAddress;
  String? _connectedDApp;
  bool _isConnected = false;
  String? _pendingConnectionOrigin;

  String? get connectedAddress => _connectedAddress;
  String? get connectedDApp => _connectedDApp;
  bool get isConnected => _isConnected;
  String? get pendingConnectionOrigin => _pendingConnectionOrigin;

  void _initializeMessageHandling() {
    if (kIsWeb) {
      html.window.addEventListener('message', (html.MessageEvent event) {
        _handleIncomingMessage(event);
      });
      
      // Notify that wallet is ready for connections
      html.window.addEventListener('load', (event) {
        _notifyWalletReady();
      });
    }
  }

  void _handleIncomingMessage(html.MessageEvent event) {
    try {
      final data = event.data as Map<String, dynamic>?;
      if (data == null) return;

      final type = data['type'] as String?;
      if (type == null) return;

      print('📨 DApp message received: $type from ${event.origin}');

      switch (type) {
        case 'CONNECTION_REQUEST':
          _handleConnectionRequest(event, data);
          break;
        case 'DISCONNECT_REQUEST':
          _handleDisconnectRequest(event);
          break;
        case 'SIGN_TRANSACTION':
          _handleTransactionSigning(event, data);
          break;
      }
    } catch (e) {
      print('❌ Error handling DApp message: $e');
    }
  }

  void _handleConnectionRequest(html.MessageEvent event, Map<String, dynamic> data) {
    final dapp = data['dapp'] as String? ?? 'Unknown DApp';
    final network = data['network'] as String? ?? 'Unknown Network';
    
    _connectedDApp = dapp;
    _pendingConnectionOrigin = event.origin;
    
    // Store connection info for UI to use
    notifyListeners();
    
    print('🔗 Connection request from: $dapp on $network');
  }

  void acceptConnection(String address) {
    if (_pendingConnectionOrigin == null) return;
    
    _connectedAddress = address;
    _isConnected = true;
    
    // Send confirmation back to DApp
    html.window.opener?.postMessage({
      'type': 'WALLET_CONNECTED',
      'address': _connectedAddress,
      'walletType': 'tydchronos'
    }, _pendingConnectionOrigin!);
    
    _pendingConnectionOrigin = null;
    notifyListeners();
    
    print('✅ Connection accepted with address: $_connectedAddress');
  }

  void rejectConnection() {
    if (_pendingConnectionOrigin == null) return;
    
    // Send rejection back to DApp
    html.window.opener?.postMessage({
      'type': 'WALLET_REJECTED',
      'reason': 'User rejected connection'
    }, _pendingConnectionOrigin!);
    
    _pendingConnectionOrigin = null;
    _connectedDApp = null;
    notifyListeners();
    
    print('❌ Connection rejected');
  }

  void _handleDisconnectRequest(html.MessageEvent event) {
    _isConnected = false;
    _connectedAddress = null;
    _connectedDApp = null;
    _pendingConnectionOrigin = null;
    
    html.window.opener?.postMessage({
      'type': 'WALLET_DISCONNECTED'
    }, event.origin!);
    
    notifyListeners();
    
    print('🔌 Disconnected from DApp');
  }

  void _handleTransactionSigning(html.MessageEvent event, Map<String, dynamic> data) {
    final transaction = data['transaction'] as Map<String, dynamic>? ?? {};
    
    print('📝 Transaction signing request: $transaction');
    
    // In real implementation, this would show a transaction confirmation dialog
    // For now, auto-confirm and send back success
    _confirmTransaction(event.origin!, transaction);
  }

  void _confirmTransaction(String origin, Map<String, dynamic> transaction) {
    html.window.opener?.postMessage({
      'type': 'TRANSACTION_SIGNED',
      'transaction': transaction,
      'success': true,
      'txHash': _generateDemoTxHash()
    }, origin);
    
    print('✅ Transaction confirmed');
  }

  void _notifyWalletReady() {
    if (html.window.opener != null) {
      html.window.opener.postMessage({
        'type': 'WALLET_READY'
      }, '*');
    }
    print('🎯 Tydchronos Wallet ready for DApp connections');
  }

  String _generateDemoTxHash() {
    const chars = '0123456789abcdef';
    String hash = '0x';
    for (int i = 0; i < 64; i++) {
      hash += chars[(DateTime.now().microsecondsSinceEpoch * i) % chars.length];
    }
    return hash;
  }

  void disconnect() {
    _isConnected = false;
    _connectedAddress = null;
    _connectedDApp = null;
    _pendingConnectionOrigin = null;
    notifyListeners();
    
    print('🔌 Manual disconnect initiated');
  }
}
