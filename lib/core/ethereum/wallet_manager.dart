import 'dart:math';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EthereumWalletManager {
  static final EthereumWalletManager _instance = EthereumWalletManager._internal();
  factory EthereumWalletManager() => _instance;
  EthereumWalletManager._internal();

  EthPrivateKey? _privateKey;
  String? _mnemonic;
  String? _encryptedPrivateKey;

  // Generate new wallet with mnemonic
  Future<Map<String, String>> generateNewWallet() async {
    // Generate mnemonic
    _mnemonic = bip39.generateMnemonic();
    
    // Generate seed from mnemonic
    final seed = bip39.mnemonicToSeed(_mnemonic!);
    
    // Generate BIP32 root key
    final root = bip32.BIP32.fromSeed(seed);
    
    // Generate Ethereum path: m/44'/60'/0'/0/0
    final child = root.derivePath("m/44'/60'/0'/0/0");
    
    // Create Ethereum private key
    _privateKey = EthPrivateKey.fromHex(bytesToHex(child.privateKey!));
    
    // Get address
    final address = await _privateKey!.extractAddress();
    
    // Encrypt and store private key
    await _encryptAndStorePrivateKey();
    
    return {
      'address': address.hex,
      'privateKey': bytesToHex(child.privateKey!),
      'mnemonic': _mnemonic!,
    };
  }

  // Import wallet from private key
  Future<String> importFromPrivateKey(String privateKey) async {
    try {
      _privateKey = EthPrivateKey.fromHex(privateKey);
      final address = await _privateKey!.extractAddress();
      await _encryptAndStorePrivateKey();
      return address.hex;
    } catch (e) {
      throw Exception('Invalid private key: $e');
    }
  }

  // Import wallet from mnemonic
  Future<String> importFromMnemonic(String mnemonic) async {
    try {
      _mnemonic = mnemonic;
      final seed = bip39.mnemonicToSeed(mnemonic);
      final root = bip32.BIP32.fromSeed(seed);
      final child = root.derivePath("m/44'/60'/0'/0/0");
      _privateKey = EthPrivateKey.fromHex(bytesToHex(child.privateKey!));
      final address = await _privateKey!.extractAddress();
      await _encryptAndStorePrivateKey();
      return address.hex;
    } catch (e) {
      throw Exception('Invalid mnemonic: $e');
    }
  }

  // Get current address
  Future<String?> getCurrentAddress() async {
    if (_privateKey == null) {
      await _loadStoredWallet();
    }
    return _privateKey != null ? (await _privateKey!.extractAddress()).hex : null;
  }

  // Sign transaction
  Future<String> signTransaction({
    required String to,
    required BigInt amount,
    required BigInt gasPrice,
    required BigInt gasLimit,
    required int nonce,
  }) async {
    if (_privateKey == null) {
      await _loadStoredWallet();
      if (_privateKey == null) throw Exception('No wallet loaded');
    }

    final transaction = Transaction(
      to: EthereumAddress.fromHex(to),
      value: amount,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      nonce: nonce,
    );

    final signature = await _privateKey!.signTransaction(transaction);
    return signature;
  }

  // Sign message
  Future<MsgSignature> signMessage(String message) async {
    if (_privateKey == null) {
      await _loadStoredWallet();
      if (_privateKey == null) throw Exception('No wallet loaded');
    }

    final messageBytes = utf8.encode(message);
    return await _privateKey!.signPersonalMessage(messageBytes);
  }

  // Sign smart contract transaction
  Future<String> signContractTransaction({
    required DeployableContract contract,
    required String functionName,
    required List<dynamic> parameters,
    required BigInt gasPrice,
    required BigInt gasLimit,
    required int nonce,
  }) async {
    if (_privateKey == null) {
      await _loadStoredWallet();
      if (_privateKey == null) throw Exception('No wallet loaded');
    }

    final function = contract.function(functionName);
    final call = ContractCall(contract, function, parameters);
    
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: parameters,
      gasPrice: gasPrice,
      gasLimit: gasLimit,
      nonce: nonce,
    );

    final signature = await _privateKey!.signTransaction(transaction);
    return signature;
  }

  // Private method to encrypt and store private key
  Future<void> _encryptAndStorePrivateKey() async {
    if (_privateKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));

    final privateKeyHex = _privateKey!.privateKey.toString();
    _encryptedPrivateKey = encrypter.encrypt(privateKeyHex, iv: iv).base64;

    await prefs.setString('encrypted_private_key', _encryptedPrivateKey!);
    await prefs.setString('encryption_key', key.base64);
    await prefs.setString('encryption_iv', iv.base64);
    
    if (_mnemonic != null) {
      await prefs.setString('mnemonic', _mnemonic!);
    }
  }

  // Private method to load stored wallet
  Future<void> _loadStoredWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedKey = prefs.getString('encrypted_private_key');
    final keyBase64 = prefs.getString('encryption_key');
    final ivBase64 = prefs.getString('encryption_iv');
    _mnemonic = prefs.getString('mnemonic');

    if (encryptedKey != null && keyBase64 != null && ivBase64 != null) {
      final key = Key.fromBase64(keyBase64);
      final iv = IV.fromBase64(ivBase64);
      final encrypter = Encrypter(AES(key));

      final decrypted = encrypter.decrypt64(encryptedKey, iv: iv);
      _privateKey = EthPrivateKey.fromHex(decrypted);
    }
  }

  // Check if wallet exists
  Future<bool> walletExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('encrypted_private_key');
  }

  // Clear wallet (logout)
  Future<void> clearWallet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('encrypted_private_key');
    await prefs.remove('encryption_key');
    await prefs.remove('encryption_iv');
    await prefs.remove('mnemonic');
    _privateKey = null;
    _mnemonic = null;
    _encryptedPrivateKey = null;
  }

  String bytesToHex(List<int> bytes) {
    return '0x${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('')}';
  }
}
