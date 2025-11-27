import 'package:flutter/material.dart';
import 'dapp_bridge_service.dart';
import '../components/dapp_connection_dialog.dart';

/// Simple wrapper to integrate DApp connectivity without modifying main.dart
class DAppIntegrationWrapper {
  static final DAppBridgeService _dappBridge = DAppBridgeService();
  
  static void initialize() {
    // Initialization happens automatically in DAppBridgeService constructor
    print('🎯 DApp Connectivity Wrapper Initialized');
  }
  
  static Widget wrapWithDAppSupport(Widget child, BuildContext context) {
    return Stack(
      children: [
        child,
        // DApp connection dialog overlay
        _buildDAppConnectionDialog(context),
      ],
    );
  }
  
  static Widget _buildDAppConnectionDialog(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _dappBridge.hasPendingConnection
          ? ValueNotifier<bool>(true)
          : ValueNotifier<bool>(false),
      builder: (context, hasPendingConnection, child) {
        if (!hasPendingConnection) return const SizedBox.shrink();
        
        return DAppConnectionDialog(
          dappName: _dappBridge.connectedDApp ?? 'Unknown DApp',
          network: _dappBridge.currentNetwork ?? 'Unknown Network',
          onConfirm: () {
            // Use a demo address for now - replace with actual wallet address
            final demoAddress = _generateDemoAddress();
            _dappBridge.acceptConnection();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Connected to ${_dappBridge.connectedDApp}'),
                backgroundColor: Colors.green,
              )
            );
          },
          onReject: () {
            _dappBridge.rejectConnection();
            
            // Show rejection message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Connection rejected'),
                backgroundColor: Colors.red,
              )
            );
          },
        );
      },
    );
  }
  
  static String _generateDemoAddress() {
    const chars = '0123456789abcdef';
    String address = '0x';
    for (int i = 0; i < 40; i++) {
      address += chars[(DateTime.now().microsecondsSinceEpoch * i) % chars.length];
    }
    return address;
  }
  
  static String? get connectedDApp => _dappBridge.connectedDApp;
  static bool get isConnected => _dappBridge.connectedDApp != null;
}
