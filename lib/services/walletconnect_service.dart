import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ethereum_service.dart';

class WalletConnectService extends ChangeNotifier {
  static const String projectId = '4d57c8f2cd69c1ce95a1571780af06cb';

  bool _isInitialized = false;
  final List<Map<String, dynamic>> _activeSessions = [];
  String? _ethereumAddress;
  final EthereumService _ethereumService = EthereumService();

  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get activeSessions => _activeSessions;
  String? get ethereumAddress => _ethereumAddress;

  Future<void> initialize() async {
    try {
      // Get Ethereum address
      _ethereumAddress = await _ethereumService.getAddress();

      _isInitialized = true;
      notifyListeners();

    } catch (e) {
      // Silently handle initialization errors for now
    }
  }

  // Get connection URI for DApps
  Future<String?> getConnectionURI() async {
    return null; // Placeholder
  }

  // Handle session approval
  Future<void> approveSession(int proposalId, Map<String, dynamic> namespaces) async {
    // Placeholder implementation
    _activeSessions.add({'id': proposalId, 'namespaces': namespaces});
    notifyListeners();
  }

  // Handle session rejection
  Future<void> rejectSession(int proposalId) async {
    // Placeholder implementation
  }

  // Disconnect session
  Future<void> disconnectSession(String topic) async {
    _activeSessions.removeWhere((session) => session['topic'] == topic);
    notifyListeners();
  }

  // Add missing method
  Future<void> connectToDApp(String uri) async {
    // Placeholder implementation
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
