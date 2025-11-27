import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web3dart/web3dart.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _currentNetwork = 'ethereum';
  final StreamController<DAppEvent> _eventController = StreamController<DAppEvent>.broadcast();
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  EthereumAddress? _currentAccount;
  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _webSocketSubscription;

  // Network configurations including zkSync Era and other L2s
  final Map<String, NetworkConfig> networks = {
    'ethereum': const NetworkConfig(
      chainId: 1,
      name: 'Ethereum Mainnet',
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_PROJECT_ID',
      wsUrl: 'wss://mainnet.infura.io/ws/v3/YOUR_PROJECT_ID',
      explorer: 'https://etherscan.io',
      currency: 'ETH',
    ),
    'polygon': const NetworkConfig(
      chainId: 137,
      name: 'Polygon Mainnet',
      rpcUrl: 'https://polygon-rpc.com',
      wsUrl: 'wss://polygon-mainnet.g.alchemy.com/v2/YOUR_API_KEY',
      explorer: 'https://polygonscan.com',
      currency: 'MATIC',
    ),
    'arbitrum': const NetworkConfig(
      chainId: 42161,
      name: 'Arbitrum One',
      rpcUrl: 'https://arb1.arbitrum.io/rpc',
      wsUrl: 'wss://arb1.arbitrum.io/ws',
      explorer: 'https://arbiscan.io',
      currency: 'ETH',
    ),
    'optimism': const NetworkConfig(
      chainId: 10,
      name: 'Optimism',
      rpcUrl: 'https://mainnet.optimism.io',
      wsUrl: 'wss://ws-mainnet.optimism.io',
      explorer: 'https://optimistic.etherscan.io',
      currency: 'ETH',
    ),
    'zksync-era': const NetworkConfig(
      chainId: 324,
      name: 'zkSync Era Mainnet',
      rpcUrl: 'https://mainnet.era.zksync.io',
      wsUrl: 'wss://mainnet.era.zksync.io/ws',
      explorer: 'https://explorer.zksync.io',
      currency: 'ETH',
      isL2: true,
      bridgeAddress: '0x32400084C286CF3E17e7B677ea9583e60a000324',
    ),
    'base': const NetworkConfig(
      chainId: 8453,
      name: 'Base Mainnet',
      rpcUrl: 'https://mainnet.base.org',
      wsUrl: 'wss://mainnet.base.org/ws',
      explorer: 'https://basescan.org',
      currency: 'ETH',
    ),
    'zksync-sepolia': const NetworkConfig(
      chainId: 300,
      name: 'zkSync Sepolia Testnet',
      rpcUrl: 'https://sepolia.era.zksync.dev',
      wsUrl: 'wss://sepolia.era.zksync.dev/ws',
      explorer: 'https://sepolia.explorer.zksync.io',
      currency: 'ETH',
      isL2: true,
    ),
  };

  // Getters
  bool get hasPendingConnection => _hasPendingConnection;
  String? get connectedDApp => _connectedDApp;
  String get currentNetwork => _currentNetwork;
  Stream<DAppEvent> get events => _eventController.stream;
  NetworkConfig get currentNetworkConfig => networks[_currentNetwork]!;
  EthereumAddress? get currentAccount => _currentAccount;

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

  /// Initialize the service
  void _initialize() {
    // Initialization logic here
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
          // Handle WebSocket events
        } catch (e) {
          print('Error parsing WebSocket message: $e');
        }
      },
      onError: (error) {
        _eventController.add(ErrorEvent(
          error: 'WebSocket error: $error',
          severity: ErrorSeverity.medium,
        ));
      },
      onDone: () {
        _eventController.add(ConnectionEvent(
          connectionType: 'disconnected', 
          network: _currentNetwork
        ));
      },
    );
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

  /// Get supported networks
  List<NetworkConfig> getSupportedNetworks() {
    return networks.values.toList();
  }

  // Methods for integration wrapper compatibility
  String? get pendingDAppName => _connectedDApp;
  String? get pendingNetwork => _currentNetwork;

  Future<void> acceptConnection() async {
    _hasPendingConnection = false;
    notifyListeners();
  }

  Future<void> rejectConnection() async {
    _hasPendingConnection = false;
    _connectedDApp = null;
    notifyListeners();
  }

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
