import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/src/credentials/credentials.dart';
import 'package:web3dart/src/crypto/secp256k1.dart';
import 'dart:typed_data';
import 'package:convert/convert.dart';

class Web3Compat {
  /// Sign personal message with proper parameters
  static Future<String> signPersonalMessage({
    required web3.Web3Client client,
    required web3.EthereumAddress address,
    required String message,
    required Credentials credentials,
  }) async {
    try {
      // Convert string message to bytes
      final messageBytes = Uint8List.fromList(message.codeUnits);
      
      // Sign the message using the credentials
      final signature = await credentials.signPersonalMessage(messageBytes);
      
      // Return the signature in hex format
      return '0x${hex.encode(signature)}';
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  /// Get credentials for an address
  static CustomCredentials getCredentials(web3.EthereumAddress address) {
    return CustomCredentials(address: address);
  }

  /// Convert EtherAmount to BigInt
  static BigInt etherAmountToBigInt(web3.EtherAmount amount) {
    return amount.getInWei;
  }

  /// Build transaction with proper parameter handling
  static web3.Transaction build({
    required web3.EthereumAddress to,
    required web3.EtherAmount value,
    Uint8List? data,
    int? gasLimit,
    web3.EtherAmount? gasPrice,
    web3.EtherAmount? maxFeePerGas,
    web3.EtherAmount? maxPriorityFeePerGas,
    int? nonce,
  }) {
    return web3.Transaction(
      to: to,
      value: value,
      data: data,
      maxGas: gasLimit,
      gasPrice: gasPrice,
      maxFeePerGas: maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas,
      nonce: nonce,
    );
  }
}

/// Custom credentials that work with the current setup
class CustomCredentials extends Credentials {
  final web3.EthereumAddress address;

  CustomCredentials({required this.address});

  @override
  web3.EthereumAddress get ethAddress => address;

  @override
  Future<web3.EthereumAddress> extractAddress() async {
    return address;
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload, {int? chainId, bool isEIP1559 = false}) {
    throw UnimplementedError('CustomCredentials.signToSignature not implemented');
  }

  @override
  MsgSignature signToEcSignature(Uint8List payload, {int? chainId, bool isEIP1559 = false}) {
    throw UnimplementedError('CustomCredentials.signToEcSignature not implemented');
  }

  @override
  Future<Uint8List> sign(Uint8List payload, {int? chainId, bool isEIP1559 = false}) {
    throw UnimplementedError('CustomCredentials.sign not implemented');
  }
}

/// Compatibility transaction class
class CompatTransaction {
  static web3.Transaction build({
    required web3.EthereumAddress to,
    required web3.EtherAmount value,
    Uint8List? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    int? nonce,
  }) {
    return web3.Transaction(
      to: to,
      value: value,
      data: data,
      maxGas: gasLimit?.toInt(),
      gasPrice: gasPrice != null ? web3.EtherAmount.inWei(gasPrice) : null,
      maxFeePerGas: maxFeePerGas != null ? web3.EtherAmount.inWei(maxFeePerGas) : null,
      maxPriorityFeePerGas: maxPriorityFeePerGas != null ? web3.EtherAmount.inWei(maxPriorityFeePerGas) : null,
      nonce: nonce,
    );
  }
}
