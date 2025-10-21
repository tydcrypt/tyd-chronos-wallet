import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'ethereum_service.dart';

class WalletConnectService extends ChangeNotifier {
  static const String projectId = '4d57c8f2cd69c1ce95a1571780af06cb';
  
  Web3Wallet? _web3wallet;
  final EthereumService _ethereumService = EthereumService();
  
  bool _isInitialized = false;
  List<SessionData> _activeSessions = [];
  String? _ethereumAddress;

  bool get isInitialized => _isInitialized;
  List<SessionData> get activeSessions => _activeSessions;
  String? get ethereumAddress => _ethereumAddress;

  Future<void> initialize() async {
    try {
      _web3wallet = await Web3Wallet.createInstance(
        projectId: projectId,
        metadata: const PairingMetadata(
          name: 'TydChronos Wallet',
          description: 'Official TydChronos Ecosystem Wallet',
          url: 'https://tydchronos.com',
          icons: ['https://tydchronos.com/icon.png'],
        ),
      );

      // Get Ethereum address
      _ethereumAddress = await _ethereumService.getAddress();
      
      // Load existing sessions
      _activeSessions = _web3wallet!.getSessions();
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      // Silently handle initialization errors for now
    }
  }

  // Get connection URI for DApps
  Future<String?> getConnectionURI() async {
    if (_web3wallet == null) return null;
    
    try {
      final pairing = await _web3wallet!.pair();
      return pairing.uri;
    } catch (e) {
      return null;
    }
  }

  // Handle session approval
  Future<void> approveSession(int proposalId, Map<String, Namespace> namespaces) async {
    if (_web3wallet == null) return;
    
    try {
      final session = await _web3wallet!.approveSession(
        id: proposalId,
        namespaces: namespaces,
      );
      _activeSessions.add(session);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Handle session rejection
  Future<void> rejectSession(int proposalId) async {
    if (_web3wallet == null) return;
    
    try {
      await _web3wallet!.rejectSession(
        id: proposalId,
        reason: 'User rejected the session',
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // Disconnect session
  Future<void> disconnectSession(String topic) async {
    if (_web3wallet == null) return;
    
    try {
      await _web3wallet!.disconnectSession(
        topic: topic,
        reason: 'User disconnected',
      );
      _activeSessions.removeWhere((session) => session.topic == topic);
      notifyListeners();
    } catch (e) {
      // Handle error silently
    }
  }

  // Get wallet info
  Map<String, dynamic> getWalletInfo() {
    return {
      'isInitialized': _isInitialized,
      'activeSessions': _activeSessions.length,
      'ethereumAddress': _ethereumAddress,
      'projectId': projectId,
    };
  }
}
