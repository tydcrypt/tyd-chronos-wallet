import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;

class WalletSecureStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Generate a new 12-word mnemonic
  Future<String> generateMnemonic() async {
    try {
      return bip39.generateMnemonic();
    } catch (e) {
      throw Exception('Failed to generate mnemonic: $e');
    }
  }

  // Convert mnemonic to seed
  Future<String> mnemonicToSeed(String mnemonic) async {
    try {
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }
      return bip39.mnemonicToSeedHex(mnemonic);
    } catch (e) {
      throw Exception('Failed to convert mnemonic to seed: $e');
    }
  }

  // Derive private key from seed using BIP44 path for Ethereum
  Future<String> derivePrivateKey(String seed) async {
    try {
      final seedBytes = hexToBytes(seed);
      final root = bip32.BIP32.fromSeed(seedBytes);
      
      // BIP44 path for Ethereum: m/44'/60'/0'/0/0
      final child = root.derivePath("m/44'/60'/0'/0/0");
      
      if (child.privateKey == null) {
        throw Exception('Failed to derive private key');
      }
      
      return bytesToHex(child.privateKey!);
    } catch (e) {
      throw Exception('Failed to derive private key: $e');
    }
  }

  // Save mnemonic to secure storage
  Future<void> saveMnemonic(String mnemonic) async {
    try {
      await _secureStorage.write(key: 'wallet_mnemonic', value: mnemonic);
    } catch (e) {
      throw Exception('Failed to save mnemonic: $e');
    }
  }

  // Retrieve mnemonic from secure storage
  Future<String?> getMnemonic() async {
    try {
      return await _secureStorage.read(key: 'wallet_mnemonic');
    } catch (e) {
      throw Exception('Failed to retrieve mnemonic: $e');
    }
  }

  // Save private key to secure storage
  Future<void> savePrivateKey(String privateKey) async {
    try {
      await _secureStorage.write(key: 'wallet_private_key', value: privateKey);
    } catch (e) {
      throw Exception('Failed to save private key: $e');
    }
  }

  // Retrieve private key from secure storage
  Future<String?> getPrivateKey() async {
    try {
      return await _secureStorage.read(key: 'wallet_private_key');
    } catch (e) {
      throw Exception('Failed to retrieve private key: $e');
    }
  }

  // Clear all wallet data (for logout/reset)
  Future<void> clearWalletData() async {
    try {
      await _secureStorage.delete(key: 'wallet_mnemonic');
      await _secureStorage.delete(key: 'wallet_private_key');
    } catch (e) {
      throw Exception('Failed to clear wallet data: $e');
    }
  }

  // Check if wallet exists
  Future<bool> walletExists() async {
    try {
      final mnemonic = await getMnemonic();
      return mnemonic != null && mnemonic.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Helper methods for hex conversion
  List<int> hexToBytes(String hex) {
    try {
      final bytes = <int>[];
      for (int i = 0; i < hex.length; i += 2) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
      return bytes;
    } catch (e) {
      throw Exception('Invalid hex string: $e');
    }
  }

  String bytesToHex(List<int> bytes) {
    try {
      return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    } catch (e) {
      throw Exception('Failed to convert bytes to hex: $e');
    }
  }

  // Validate mnemonic
  bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }
}
