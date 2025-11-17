import 'package:flutter_test/flutter_test.dart';
import 'package:tydchronos_wallet/services/dapp_bridge_service.dart';

void main() {
  group('DAppBridgeService', () {
    test('Singleton instance creation', () {
      final service1 = DAppBridgeService();
      final service2 = DAppBridgeService();
      expect(service1, equals(service2));
    });

    test('Initial state values', () {
      final service = DAppBridgeService();
      expect(service.hasPendingConnection, isFalse);
      expect(service.isConnected, isFalse);
      expect(service.connectedDApp, isNull);
      expect(service.connectedDApps, isEmpty);
    });
  });
}
