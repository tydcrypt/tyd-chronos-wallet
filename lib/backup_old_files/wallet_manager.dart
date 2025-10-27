import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:tyd_chronos_wallet_new/core/security/wallet_secure_storage.dart';

class WalletManager {
  final WalletSecureStorage _secureStorage = WalletSecureStorage();
  late Web3Client _web3client;
  Credentials? _credentials;
  EthereumAddress? _address;
  
  final Map<String, String> _networkRpcs = {
    'Ethereum Mainnet': 'https://eth.llamarpc.com',
    'Goerli Testnet': 'https://eth-goerli.public.blastapi.io',
    'Sepolia Testnet': 'https://rpc2.sepolia.org',
    'Polygon Mainnet': 'https://polygon-rpc.com',
    'Polygon Mumbai': 'https://rpc-mumbai.matic.today',
    'Arbitrum One': 'https://arb1.arbitrum.io/rpc',
    'Optimism': 'https://mainnet.optimism.io',
    'Avalanche C-Chain': 'https://api.avax.network/ext/bc/C/rpc',
    'zkSync Era': 'https://mainnet.era.zksync.io',
  };

  WalletManager() {
    _initializeClient('Ethereum Mainnet');
  }

  void _initializeClient(String network) {
    final rpcUrl = _networkRpcs[network] ?? _networkRpcs['Ethereum Mainnet']!;
    print('Connecting to: $network - $rpcUrl');
    _web3client = Web3Client(rpcUrl, Client());
  }

  Future<String?> getWalletAddress() async {
    if (_address != null) return _address!.hex;
    
    final mnemonic = await _secureStorage.getMnemonic();
    if (mnemonic != null) {
      await _loadWalletFromMnemonic(mnemonic);
      return _address!.hex;
    }
    
    await generateNewWallet();
    return _address!.hex;
  }

  Future<void> generateNewWallet() async {
    try {
      final mnemonic = await _secureStorage.generateMnemonic();
      await _loadWalletFromMnemonic(mnemonic);
      await _secureStorage.saveMnemonic(mnemonic);
      await _secureStorage.savePrivateKey(_credentials!.privateKey);
      print('✅ New wallet generated with address: ${_address!.hex}');
      print('📝 Mnemonic: $mnemonic');
    } catch (e) {
      throw Exception('Failed to generate wallet: $e');
    }
  }

  Future<void> _loadWalletFromMnemonic(String mnemonic) async {
    try {
      final seed = await _secureStorage.mnemonicToSeed(mnemonic);
      final privateKeyHex = await _secureStorage.derivePrivateKey(seed);
      
      // For web3dart 2.7.3, use EthPrivateKey.fromHex
      _credentials = EthPrivateKey.fromHex(privateKeyHex);
      _address = await _credentials!.extractAddress();
    } catch (e) {
      throw Exception('Failed to load wallet from mnemonic: $e');
    }
  }

  Future<double> getBalance(String network) async {
    try {
      _initializeClient(network);

      if (_address == null) {
        await getWalletAddress();
      }

      if (_address != null) {
        print('🔄 Fetching balance for ${_address!.hex} on $network...');
        final balance = await _web3client.getBalance(_address!);
        final etherBalance = balance.getInWei.toDouble() / 1000000000000000000; // Convert from wei to ETH
        print('✅ Balance on $network: $etherBalance ETH');
        return etherBalance;
      }
      
      return 0.0;
    } catch (e) {
      print('❌ Error getting balance from $network: $e');
      return 0.0;
    }
  }

  List<String> getAvailableNetworks() {
    return _networkRpcs.keys.toList();
  }

  Future<String?> getMnemonic() async {
    return await _secureStorage.getMnemonic();
  }

  Future<bool> isWalletInitialized() async {
    final mnemonic = await _secureStorage.getMnemonic();
    return mnemonic != null;
  }
}
