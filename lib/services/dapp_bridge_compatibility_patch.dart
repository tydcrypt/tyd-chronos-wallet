/// Compatibility patch for web3dart 2.x
/// This file provides any necessary shims or compatibility layers
/// without modifying the main 796-line DAppBridgeService

import 'package:web3dart/web3dart.dart';

/// Web3Dart 2.x compatibility helpers
class Web3Compat {
  /// Helper for any API differences between web3dart versions
  static bool isWeb3Dart2x() {
    return true; // We're using 2.7.3
  }
  
  /// Note: web3dart 2.x uses different transaction parameters
  /// The main DAppBridgeService should work as-is since it uses
  /// basic Transaction constructor which is stable across versions
}

/// Transaction builder compatible with web3dart 2.x
class CompatTransactionBuilder {
  static Transaction build({
    required String to,
    required BigInt value,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) {
    // web3dart 2.x uses basic Transaction constructor
    // EIP-1559 fields might not be available in 2.x
    return Transaction(
      to: EthereumAddress.fromHex(to),
      value: value,
      data: data != null ? hexToBytes(data) : null,
      gasLimit: gasLimit,
      gasPrice: gasPrice,
      // maxFeePerGas and maxPriorityFeePerGas not available in 2.x
    );
  }
}
