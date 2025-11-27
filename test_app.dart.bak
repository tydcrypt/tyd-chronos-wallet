import 'package:flutter_test/flutter_test.dart';
import 'package:tydchronos_wallet/main.dart';

void main() {
  test('App starts without errors', () {
    expect(() => main(), returnsNormally);
  });

  test('WalletConnectService initializes', () {
    final service = WalletConnectService();
    expect(() => service.initialize(), returnsNormally);
  });

  test('NetworkModeManager toggles correctly', () {
    final manager = NetworkModeManager();
    expect(manager.isTestnetMode, true);
    
    manager.toggleNetworkMode();
    expect(manager.isTestnetMode, false);
    
    manager.toggleNetworkMode();
    expect(manager.isTestnetMode, true);
  });

  test('BalanceVisibilityManager formats correctly', () {
    final manager = BalanceVisibilityManager();
    
    expect(manager.formatBalance(1000.0), equals('\$1000.00'));
    expect(manager.formatCryptoBalance(1.5), equals('1.5000'));
    
    manager.toggleBalances();
    expect(manager.formatBalance(1000.0), equals('\$••••••'));
    expect(manager.formatCryptoBalance(1.5), equals('••••••'));
  });
}
