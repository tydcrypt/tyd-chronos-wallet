import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:bip39/bip39.dart' as bip39;
import 'services/ethereum_service.dart';
import 'services/currency_service.dart';
import 'services/walletconnect_adapter.dart'; // CHANGED: Use adapter instead

// ==================== NETWORK MODE MANAGER ====================
class NetworkModeManager extends ChangeNotifier {
  bool _isTestnetMode = true; // Default to testnet for safety
  
  bool get isTestnetMode => _isTestnetMode;
  String get currentNetwork => _isTestnetMode ? 'Testnet' : 'Mainnet';
  String get currentNetworkSubtitle => _isTestnetMode ? 'Using test funds' : 'Real funds mode';
  
  void toggleNetworkMode() {
    _isTestnetMode = !_isTestnetMode;
    notifyListeners();
  }
  
  // Network-specific balance logic
  double getAdjustedBalance(double mainnetBalance) {
    return _isTestnetMode ? 0.0 : mainnetBalance;
  }
  
  String getNetworkAdjustedBalance(double mainnetBalance, {String symbol = '\$'}) {
    final balance = getAdjustedBalance(mainnetBalance);
    return balance > 0 ? '$symbol\${balance.toStringAsFixed(2)}' : '••••••';
  }
}

// ==================== MAIN APP ====================
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WalletConnectService()..initialize()),
        ChangeNotifierProvider(create: (context) => NetworkModeManager()),
      ],
      child: const TydChronosWalletApp(),
    ),
  );
}

// ... REST OF YOUR ORIGINAL CODE REMAINS EXACTLY THE SAME ...
// All your screens, models, and UI components stay unchanged

