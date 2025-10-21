import 'package:flutter/foundation.dart';

class DiagnosticController with ChangeNotifier {
  final Map<String, bool> _componentStatus = {};
  final Map<String, String> _componentMessages = {};
  final Map<String, int> _componentTimings = {};
  
  void updateComponentStatus(String component, bool isReady, [String message = '']) {
    _componentStatus[component] = isReady;
    if (message.isNotEmpty) {
      _componentMessages[component] = message;
    }
    notifyListeners();
  }
  
  void setComponentTiming(String component, int milliseconds) {
    _componentTimings[component] = milliseconds;
    notifyListeners();
  }
  
  void showWalletConnectProgress() {
    updateComponentStatus('walletconnect', false, 'Connecting to blockchain network...');
  }
  
  void completeWalletConnect() {
    updateComponentStatus('walletconnect', true, 'WalletConnect ready');
  }
  
  Map<String, dynamic> getStatus() {
    return {
      'status': Map<String, bool>.from(_componentStatus),
      'messages': Map<String, String>.from(_componentMessages),
      'timings': Map<String, int>.from(_componentTimings),
    };
  }
  
  bool get allComponentsReady {
    return _componentStatus.values.every((status) => status == true);
  }
  
  String get loadingMessage {
    final loadingComponents = _componentStatus.entries
        .where((entry) => entry.value == false)
        .map((entry) => entry.key)
        .toList();
    
    if (loadingComponents.isEmpty) return 'All components ready';
    return 'Loading: ${loadingComponents.join(', ')}';
  }
}
