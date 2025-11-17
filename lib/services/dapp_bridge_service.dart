import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../utils/web3dart_compat.dart' as compat;
import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:convert/convert.dart' as convert;

/// Comprehensive DApp Bridge Service supporting multiple L2 networks including zkSync Era
class NetworkConfig {
  final int chainId;
  final String name;
  final String rpcUrl;
  final String wsUrl;
  final String explorer;
  final String currency;
  final bool isL2;
  final String? bridgeAddress;

  const NetworkConfig({
    required this.chainId,
    required this.name,
    required this.rpcUrl,
    required this.wsUrl,
    required this.explorer,
    required this.currency,
    this.isL2 = false,
    this.bridgeAddress,
  });
}

/// Event types for DApp communication
abstract class DAppEvent {
  final String type;
  final DateTime timestamp;

  DAppEvent(this.type) : timestamp = DateTime.now();
}

class ServiceInitializedEvent extends DAppEvent {
  final String network;
  final String? account;

  ServiceInitializedEvent({required this.network, this.account})
      : super('service_initialized');
}

class NetworkChangedEvent extends DAppEvent {
  final String network;
  final NetworkConfig config;

  NetworkChangedEvent({required this.network, required this.config})
      : super('network_changed');
}

class AccountChangedEvent extends DAppEvent {
  final String account;

  AccountChangedEvent({required this.account}) : super('account_changed');
}

class TransactionSentEvent extends DAppEvent {
  final String hash;
  final String from;
  final String to;
  final BigInt value;
  final String network;

  TransactionSentEvent({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.network,
  }) : super('transaction_sent');
}

class MessageSignedEvent extends DAppEvent {
  final String message;
  final String signature;
  final String account;

  MessageSignedEvent({
    required this.message,
    required this.signature,
    required this.account,
  }) : super('message_signed');
}

class NewBlockEvent extends DAppEvent {
  final BigInt blockNumber;
  final String blockHash;
  final DateTime timestamp;

  NewBlockEvent({
    required this.blockNumber,
    required this.blockHash,
    required this.timestamp,
  }) : super('new_block');
}

class NewLogsEvent extends DAppEvent {
  final EthereumAddress address;
  final List<String> topics;
  final String data;
  final BigInt? blockNumber;
  final String? transactionHash;

  NewLogsEvent({
    required this.address,
    required this.topics,
    required this.data,
    this.blockNumber,
    this.transactionHash,
  }) : super('new_logs');
}

class PendingTransactionEvent extends DAppEvent {
  final String hash;
  final EthereumAddress from;
  final EthereumAddress? to;
  final BigInt value;

  PendingTransactionEvent({
    required this.hash,
    required this.from,
    this.to,
    required this.value,
  }) : super('pending_transaction');
}

class ConnectionEvent extends DAppEvent {
  final String connectionType;
  final String network;

  ConnectionEvent({required this.connectionType, required this.network})
      : super('connection_changed');
}

class ErrorEvent extends DAppEvent {
  final String error;
  final ErrorSeverity severity;

  ErrorEvent({required this.error, required this.severity})
      : super('error');
}

class TokenAddedEvent extends DAppEvent {
  final String address;
  final String symbol;
  final int decimals;
  final String network;

  TokenAddedEvent({
    required this.address,
    required this.symbol,
    required this.decimals,
    required this.network,
  }) : super('token_added');
}

class CustomEvent extends DAppEvent {
  final Map<String, dynamic> data;

  CustomEvent({required String type, required this.data}) : super(type);
}

enum ConnectionType {
  connected,
  disconnected,
  reconnecting,
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Contract function abstraction
class ContractFunction {
  final String name;
  final List<dynamic> inputs;
  final List<dynamic> outputs;
  final bool constant;

  const ContractFunction({
    required this.name,
    required this.inputs,
    required this.outputs,
    this.constant = false,
  });

  Map<String, dynamic> get abi {
    return {
      'name': name,
      'type': 'function',
      'inputs': inputs,
      'outputs': outputs,
      'constant': constant,
      'stateMutability': constant ? 'view' : 'nonpayable',
    };
  }
}

class DAppBridgeService with ChangeNotifier {
  final Logger _logger = Logger();
  Web3Client? _web3client;
  Credentials? _credentials;

  static final DAppBridgeService _instance = DAppBridgeService._internal();
  
  static DAppBridgeService get instance => _instance;
  factory DAppBridgeService() => _instance;
  
  DAppBridgeService._internal() {
    _initialize();
  }

  // Properties for main.dart integration
  bool _hasPendingConnection = false;
  String? _connectedDApp;
  
  bool get hasPendingConnection => _hasPendingConnection;
  String? get connectedDApp => _connectedDApp;
  
  void setPendingConnection(bool pending, {String? dappName}) {
    _hasPendingConnection = pending;
    _connectedDApp = dappName;
    notifyListeners();
  }

  void setConnectedDApp(String? dappName) {
    _connectedDApp = dappName;
    _hasPendingConnection = false;
    notifyListeners();
  }

  // Network configurations including zkSync Era and other L2s
  final Map<String, NetworkConfig> networks = {
    'ethereum': NetworkConfig(
      chainId: 1,
      name: 'Ethereum Mainnet',
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_PROJECT_ID',
      wsUrl: 'wss://mainnet.infura.io/ws/v3/YOUR_PROJECT_ID',
      explorer: 'https://etherscan.io',
      currency: 'ETH',
    ),
    'polygon': NetworkConfig(
      chainId: 137,
      name: 'Polygon Mainnet',
      rpcUrl: 'https://polygon-rpc.com',
      wsUrl: 'wss://polygon-mainnet.g.alchemy.com/v2/YOUR_API_KEY',
      explorer: 'https://polygonscan.com',
      currency: 'MATIC',
    ),
    'arbitrum': NetworkConfig(
      chainId: 42161,
      name: 'Arbitrum One',
      rpcUrl: 'https://arb1.arbitrum.io/rpc',
      wsUrl: 'wss://arb1.arbitrum.io/ws',
      explorer: 'https://arbiscan.io',
      currency: 'ETH',
    ),
    'optimism': NetworkConfig(
      chainId: 10,
      name: 'Optimism',
      rpcUrl: 'https://mainnet.optimism.io',
      wsUrl: 'wss://ws-mainnet.optimism.io',
      explorer: 'https://optimistic.etherscan.io',
      currency: 'ETH',
    ),
    'zksync-era': NetworkConfig(
      chainId: 324,
      name: 'zkSync Era Mainnet',
      rpcUrl: 'https://mainnet.era.zksync.io',
      wsUrl: 'wss://mainnet.era.zksync.io/ws',
      explorer: 'https://explorer.zksync.io',
      currency: 'ETH',
      isL2: true,
      bridgeAddress: '0x32400084C286CF3E17e7B677ea9583e60a000324',
    ),
    'base': NetworkConfig(
      chainId: 8453,
      name: 'Base Mainnet',
      rpcUrl: 'https://mainnet.base.org',
      wsUrl: 'wss://mainnet.base.org/ws',
      explorer: 'https://basescan.org',
      currency: 'ETH',
    ),
    'zksync-sepolia': NetworkConfig(
      chainId: 300,
      name: 'zkSync Sepolia Testnet',
      rpcUrl: 'https://sepolia.era.zksync.dev',
      wsUrl: 'wss://sepolia.era.zksync.dev/ws',
      explorer: 'https://sepolia.explorer.zksync.io',
      currency: 'ETH',
      isL2: true,
    ),
  };

  String _currentNetwork = 'ethereum';
  final StreamController<DAppEvent> _eventController = StreamController<DAppEvent>.broadcast();
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  EthereumAddress? _currentAccount;
  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _webSocketSubscription;

  // Getters
  Stream<DAppEvent> get events => _eventController.stream;
  String get currentNetwork => _currentNetwork;
  NetworkConfig get currentNetworkConfig => networks[_currentNetwork]!;
  EthereumAddress? get currentAccount => _currentAccount;

  /// Initialize the service
  void _initialize() {
    // Initialization logic here
  }

  /// Handle new block events from WebSocket
  void _handleNewBlock(dynamic blockData) {
    if (blockData != null) {
      _eventController.add(NewBlockEvent(
        blockNumber: BigInt.tryParse(blockData['number']?.toString() ?? '0') ?? BigInt.zero,
        blockHash: blockData['hash']?.toString() ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(blockData['timestamp']?.toString() ?? '0') ?? 0,
        ),
      ));
    }
  }

  /// Handle new log events from WebSocket
  void _handleNewLogs(dynamic logsData) {
    if (logsData != null) {
      _eventController.add(NewLogsEvent(
        address: EthereumAddress.fromHex(logsData['address']?.toString() ?? '0x0'),
        topics: (logsData['topics'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ?? [],
        data: logsData['data']?.toString() ?? '',
        blockNumber: BigInt.tryParse(logsData['blockNumber']?.toString() ?? '0'),
        transactionHash: logsData['transactionHash']?.toString(),
      ));
    }
  }

  /// Handle pending transaction events
  void _handlePendingTransaction(dynamic txData) {
    if (txData != null) {
      _eventController.add(PendingTransactionEvent(
        hash: txData['hash']?.toString() ?? '',
        from: EthereumAddress.fromHex(txData['from']?.toString() ?? ''),
        to: txData.containsKey('to') 
            ? EthereumAddress.fromHex(txData['to']?.toString() ?? '')
            : null,
        value: BigInt.tryParse(txData['value']?.toString() ?? '0') ?? BigInt.zero,
      ));
    }
  }

  /// Handle custom WebSocket events
  void _handleCustomEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      _eventController.add(CustomEvent(
        type: event['type']?.toString() ?? 'unknown',
        data: event,
      ));
    }
  }

  /// Handle WebSocket events
  void _handleWebSocketEvent(dynamic event) {
    if (event is Map<String, dynamic>) {
      final method = event['method']?.toString() ?? '';
      final params = event['params'];
      
      switch (method) {
        case 'eth_subscription':
          _handleSubscriptionEvent(params);
          break;
        default:
          print('Unknown WebSocket method: $method');
      }
    }
  }

  /// Handle subscription events
  void _handleSubscriptionEvent(dynamic params) {
    if (params is Map<String, dynamic>) {
      final subscription = params['subscription']?.toString() ?? '';
      final result = params['result'];
      
      switch (subscription) {
        case 'newHeads':
          _handleNewBlock(result);
          break;
        case 'logs':
          _handleNewLogs(result);
          break;
        case 'pendingTransactions':
          _handlePendingTransaction(result);
          break;
        default:
          print('Unknown subscription: $subscription');
      }
    }
  }

  /// Initialize the service
  Future<void> initialize({String? initialNetwork}) async {
    if (initialNetwork != null && networks.containsKey(initialNetwork)) {
      _currentNetwork = initialNetwork;
    }
    
    await _connectToNetwork();
    await _loadSavedSession();
    
    _eventController.add(ServiceInitializedEvent(
      network: _currentNetwork,
      account: _currentAccount?.hex,
    ));
  }

  /// Connect to specified network
  Future<void> switchNetwork(String networkId) async {
    if (!networks.containsKey(networkId)) {
      throw Exception('Network $networkId not supported');
    }

    _currentNetwork = networkId;
    await _connectToNetwork();
    
    _eventController.add(NetworkChangedEvent(
      network: networkId,
      config: networks[networkId]!,
    ));
  }

  /// Connect to current network RPC
  Future<void> _connectToNetwork() async {
    final config = networks[_currentNetwork]!;
    
    try {
      // Close existing connections
      await _web3client?.dispose();
      await _webSocketChannel?.sink.close();
      await _webSocketSubscription?.cancel();

      // Create new HTTP client
      final httpClient = http.Client();
      _web3client = Web3Client(config.rpcUrl, httpClient);

      // Connect WebSocket for real-time events
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(config.wsUrl));
      _setupWebSocketListeners();

    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Failed to connect to $_currentNetwork: $e',
        severity: ErrorSeverity.high,
      ));
      rethrow;
    }
  }

  /// Set up WebSocket listeners for real-time events
  void _setupWebSocketListeners() {
    _webSocketSubscription = _webSocketChannel?.stream.listen(
      (data) {
        try {
          final event = jsonDecode(data);
          _handleWebSocketEvent(event);
        } catch (e) {
          print('Error parsing WebSocket message: $e');
        }
      },
      onError: (error) {
        _eventController.add(ErrorEvent(
          error: 'WebSocket error: $error',
          severity: ErrorSeverity.medium,
        ));
        _reconnectWebSocket();
      },
      onDone: () {
        _eventController.add(ConnectionEvent(
          connectionType: 'disconnected', 
          network: _currentNetwork
        ));
        _reconnectWebSocket();
      },
    );
  }

  /// Reconnect WebSocket with exponential backoff
  Future<void> _reconnectWebSocket() async {
    const maxAttempts = 5;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
      
      try {
        final config = networks[_currentNetwork]!;
        _webSocketChannel = WebSocketChannel.connect(Uri.parse(config.wsUrl));
        _setupWebSocketListeners();
        _eventController.add(ConnectionEvent(
          connectionType: 'connected',
          network: _currentNetwork,
        ));
        return;
      } catch (e) {
        print("WebSocket reconnection attempt $attempt failed: $e");
      }
    }
    
    _eventController.add(ErrorEvent(
      error: 'Failed to reconnect WebSocket after $maxAttempts attempts',
      severity: ErrorSeverity.high,
    ));
  }

  /// Set current account for transactions
  void setCurrentAccount(EthereumAddress account) {
    _currentAccount = account;
    
    final prefs = SharedPreferences.getInstance();
    prefs.then((storage) {
      storage.setString('last_account', account.hexEip55);
    });

    _eventController.add(AccountChangedEvent(account: account.hex));
  }

  /// Load saved session from storage
  Future<void> _loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAccount = prefs.getString('last_account');
    final lastNetwork = prefs.getString('last_network');

    if (lastNetwork != null && networks.containsKey(lastNetwork)) {
      _currentNetwork = lastNetwork;
    }

    if (lastAccount != null) {
      try {
        _currentAccount = EthereumAddress.fromHex(lastAccount);
      } catch (e) {
        print('Error loading saved account: $e');
      }
    }
  }

  /// Send transaction
  Future<String> sendTransaction({
    required String to,
    required BigInt value,
    String? data,
    BigInt? gasLimit,
    BigInt? gasPrice,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
  }) async {
    if (_currentAccount == null) {
      throw Exception('No account selected');
    }

    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    try {
      final transaction = compat.CompatTransaction.build(
        to: web3.EthereumAddress.fromHex(to),
        value: web3.EtherAmount.fromBigInt(web3.EtherUnit.wei, value),
        data: data != null ? Uint8List.fromList(convert.hex.decode(data.replaceFirst('0x', ''))) : null,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
      );

      final hash = await _web3client!.sendTransaction(
        compat.Web3Compat.getCredentials(_currentAccount!),
        transaction,
        chainId: networks[_currentNetwork]!.chainId,
      );

      _eventController.add(TransactionSentEvent(
        hash: hash,
        from: _currentAccount!.hex,
        to: to,
        value: value,
        network: _currentNetwork,
      ));

      return hash;
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Transaction failed: $e',
        severity: ErrorSeverity.high,
      ));
      rethrow;
    }
  }

  /// Sign message
  Future<String> signMessage(String message) async {
    if (_currentAccount == null) {
      throw Exception('No account selected');
    }

    try {
      final signature = await compat.Web3Compat.signPersonalMessage(
        client: _web3client!,
        address: _currentAccount!,
        message: message,
        credentials: compat.Web3Compat.getCredentials(_currentAccount!),
      );

      _eventController.add(MessageSignedEvent(
        message: message,
        signature: signature,
        account: _currentAccount!.hex,
      ));

      return signature;
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Message signing failed: $e',
        severity: ErrorSeverity.medium,
      ));
      rethrow;
    }
  }

  /// Call contract method
  Future<List<dynamic>> callContract({
    required String contractAddress,
    required String functionName,
    required ContractFunction function,
    required List<dynamic> params,
  }) async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode([function.abi]), 'Contract'),
        EthereumAddress.fromHex(contractAddress),
      );

      final result = await _web3client!.call(
        contract: contract,
        function: contract.function(functionName),
        params: params,
      );

      return result;
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Contract call failed: $e',
        severity: ErrorSeverity.medium,
      ));
      rethrow;
    }
  }

  /// Get balance for address
  Future<BigInt> getBalance([EthereumAddress? address]) async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    final targetAddress = address ?? _currentAccount;
    if (targetAddress == null) {
      throw Exception('No address provided and no current account set');
    }

    try {
      final balance = await _web3client!.getBalance(targetAddress);
      return compat.Web3Compat.etherAmountToBigInt(balance);
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Balance check failed: $e',
        severity: ErrorSeverity.low,
      ));
      rethrow;
    }
  }

  /// Get transaction count
  Future<int> getTransactionCount([EthereumAddress? address]) async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    final targetAddress = address ?? _currentAccount;
    if (targetAddress == null) {
      throw Exception('No address provided and no current account set');
    }

    try {
      return await _web3client!.getTransactionCount(targetAddress);
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Transaction count check failed: $e',
        severity: ErrorSeverity.low,
      ));
      rethrow;
    }
  }

  /// Estimate gas for transaction
    /// Estimate gas for a transaction
  Future<BigInt> estimateGas({
    required EthereumAddress from,
    required EthereumAddress to,
    required BigInt value,
    required Uint8List data,
    BigInt? gas,
    BigInt? gasPrice,
    BigInt? maxPriorityFeePerGas,
    BigInt? maxFeePerGas,
  }) async {
    try {
      final EtherAmount? etherValue = value > BigInt.zero 
          ? EtherAmount.fromBigInt(EtherUnit.wei, value)
          : null;
          
      final EtherAmount? gasPriceValue = gasPrice != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, gasPrice)
          : null;
          
      final EtherAmount? maxPriorityFee = maxPriorityFeePerGas != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, maxPriorityFeePerGas)
          : null;
          
      final EtherAmount? maxFee = maxFeePerGas != null
          ? EtherAmount.fromBigInt(EtherUnit.wei, maxFeePerGas)
          : null;

      if (_web3client == null) {
      throw StateError('Web3Client is not initialized');
    }
    return await _web3client!.estimateGas(
        sender: from,
        to: to,
        value: etherValue,
        data: data,
        amountOfGas: gas,
        gasPrice: gasPriceValue,
        maxPriorityFeePerGas: maxPriorityFee,
        maxFeePerGas: maxFee,
      );
    } catch (e) {
      _logger.e('Error estimating gas: \$e');
      rethrow;
    }
  }

  /// Get gas price
  Future<BigInt> getGasPrice() async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    try {
      final gasPrice = await _web3client!.getGasPrice();
      return compat.Web3Compat.etherAmountToBigInt(gasPrice);
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Gas price check failed: $e',
        severity: ErrorSeverity.low,
      ));
      rethrow;
    }
  }

  /// Get current block number
  Future<BigInt> getBlockNumber() async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    try {
      final blockNumber = await _web3client!.getBlockNumber();
      return BigInt.from(blockNumber);
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Block number check failed: $e',
        severity: ErrorSeverity.low,
      ));
      rethrow;
    }
  }

  /// Get transaction receipt
  Future<TransactionReceipt?> getTransactionReceipt(String hash) async {
    if (_web3client == null) {
      throw Exception('Not connected to network');
    }

    try {
      return await _web3client!.getTransactionReceipt(hash);
    } catch (e) {
      _eventController.add(ErrorEvent(
        error: 'Transaction receipt check failed: $e',
        severity: ErrorSeverity.low,
      ));
      rethrow;
    }
  }

  /// Add token to wallet
  Future<void> addToken({
    required String address,
    required String symbol,
    required int decimals,
    String? imageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tokens = prefs.getStringList('custom_tokens') ?? [];
    
    final tokenData = {
      'address': address,
      'symbol': symbol,
      'decimals': decimals,
      'imageUrl': imageUrl,
      'network': _currentNetwork,
    };
    
    tokens.add(jsonEncode(tokenData));
    await prefs.setStringList('custom_tokens', tokens);
    
    _eventController.add(TokenAddedEvent(
      address: address,
      symbol: symbol,
      decimals: decimals,
      network: _currentNetwork,
    ));
  }

  /// Get supported networks
  List<NetworkConfig> getSupportedNetworks() {
    return networks.values.toList();
  }

  /// Check if network is L2
  bool isL2Network(String networkId) {
    return networks[networkId]?.isL2 == true;
  }

  /// Get zkSync Era specific configuration
  NetworkConfig get zkSyncEraConfig => networks['zksync-era']!;

  /// Cleanup resources
  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _webSocketChannel?.sink.close();
    _eventController.close();
    _web3client?.dispose();
    _pendingRequests.clear();
    super.dispose();
  }
}