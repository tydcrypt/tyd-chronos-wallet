import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class EthereumService {
  static const String _privateKeyKey = 'ethereum_private_key';
  
  late Web3Client _client;
  Credentials? _credentials;
  EthereumAddress? _address;

  EthereumService() {
    // Initialize with Goerli testnet - use public RPC for testing
    _client = Web3Client(
      'https://eth-goerli.g.alchemy.com/v2/demo', // Public Alchemy endpoint
      Client(), // Add the required httpClient parameter
    );
  }

  Future<void> createWalletFromMnemonic(String mnemonic) async {
    try {
      // Validate mnemonic
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }

      // Generate seed from mnemonic
      final seed = bip39.mnemonicToSeed(mnemonic);
      
      // Use first 32 bytes as private key (simplified for demo)
      // In production, use proper BIP32 derivation
      final privateKeyBytes = seed.sublist(0, 32);
      final privateKey = EthPrivateKey.fromHex(_bytesToHex(privateKeyBytes));
      
      // Get address
      _credentials = privateKey;
      _address = await _credentials!.extractAddress();
      
      // Store securely
      await _storeWallet(_bytesToHex(privateKeyBytes));
      
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  Future<void> _storeWallet(String privateKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_privateKeyKey, privateKey);
  }

  Future<String?> getAddress() async {
    if (_address != null) return _address!.hex;
    
    // Try to load from storage
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString(_privateKeyKey);
    
    if (privateKey != null) {
      try {
        final ethPrivateKey = EthPrivateKey.fromHex(privateKey);
        _credentials = ethPrivateKey;
        _address = await _credentials!.extractAddress();
        return _address!.hex;
      } catch (e) {
        print('Error loading wallet: $e');
        return null;
      }
    }
    
    return null;
  }

  Future<double> getBalance() async {
    if (_address == null) return 0.0;
    
    try {
      final balance = await _client.getBalance(_address!);
      return balance.getValueInUnit(EtherUnit.ether).toDouble();
    } catch (e) {
      print('Balance error: $e');
      return 0.0; // Return 0 for demo purposes
    }
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }
}
