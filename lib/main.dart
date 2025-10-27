import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/services.dart';
import 'services/ethereum_service.dart';
import 'services/currency_service.dart';
import 'services/price_feed_service.dart';
import 'services/transaction_service.dart';
import 'services/backend_api_service.dart';
import 'services/security_service.dart';
import 'services/snipping_bot_service.dart';
import 'features/automated_trading/automated_trading.dart';

// ==================== NETWORK MODE MANAGER ====================
class NetworkModeManager extends ChangeNotifier {
  bool _isTestnetMode = false;
  final PriceFeedService _priceService = PriceFeedService();
  Map<String, double> _livePrices = {};
  Map<String, double> _lockedValues = {}; // For volatility protection
  
  bool get isTestnetMode => _isTestnetMode;
  String get currentNetwork => _isTestnetMode ? 'Testnet' : 'Mainnet';
  String get currentNetworkSubtitle => _isTestnetMode ? 'Using test funds' : 'Real funds mode';
  
  Map<String, double> get livePrices => _livePrices;
  Map<String, double> get lockedValues => _lockedValues;
  
  void toggleNetworkMode() {
    _isTestnetMode = !_isTestnetMode;
    notifyListeners();
  }
  
  double getAdjustedBalance(double mainnetBalance) {
    return _isTestnetMode ? 0.0 : mainnetBalance;
  }
  
  String getNetworkAdjustedBalance(double mainnetBalance, {String symbol = '\$'}) {
    final balance = getAdjustedBalance(mainnetBalance);
    return balance > 0 ? '$symbol${balance.toStringAsFixed(2)}' : '••••••';
  }
  
  // Volatility protection - lock values during transactions
  void lockValue(String txHash, double value, String symbol) {
    _lockedValues['${txHash}_$symbol'] = value;
    notifyListeners();
  }
  
  void unlockValue(String txHash, String symbol) {
    _lockedValues.remove('${txHash}_$symbol');
    notifyListeners();
  }
  
  double getLockedValue(String txHash, String symbol) {
    return _lockedValues['${txHash}_$symbol'] ?? 0.0;
  }
  
  Future<void> fetchLivePrices() async {
    try {
      _livePrices = await _priceService.getLivePrices();
      notifyListeners();
    } catch (e) {
      print('Error fetching live prices: $e');
    }
  }
  
  double getLivePrice(String symbol) {
    return _livePrices[symbol] ?? 0.0;
  }
}

// ==================== CURRENCY MANAGER ====================
class CurrencyManager extends ChangeNotifier {
  String _selectedCurrency = 'USD';
  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'INR': '₹',
    'NGN': '₦', // Nigerian Naira
    'CAD': '\$',
    'AUD': '\$',
    'BTC': '₿',
    'ETH': 'Ξ',
  };
  
  String get selectedCurrency => _selectedCurrency;
  String get currencySymbol => _currencySymbols[_selectedCurrency] ?? '\$';
  
  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }
  
  String formatBalance(double amount, {int decimalPlaces = 2}) {
    return '$currencySymbol${amount.toStringAsFixed(decimalPlaces)}';
  }
}

// ==================== TYDCHRONOS ECOSYSTEM SERVICE ====================
class TydChronosEcosystemService extends ChangeNotifier {
  String? _ethereumAddress;
  final BackendApiService _backendService = BackendApiService();
  final SecurityService _securityService = SecurityService();
  final SnippingBotService _snippingBotService = SnippingBotService();
  
  // Bot status
  bool _arbitrageBotActive = false;
  bool _liquidityBotActive = false;
  bool _marketMakingBotActive = false;
  
  // Bot trading data
  Map<String, dynamic> _bot1Performance = {
    'tradingBalance': 0.5,
    'profit': 250.0,
    'successRate': 75.0,
    'totalTrades': 45
  };
  
  Map<String, dynamic> _bot2Performance = {
    'tradingBalance': 0.3,
    'profit': 180.0,
    'successRate': 68.0,
    'totalTrades': 32
  };
  
  Map<String, dynamic> _bot3Performance = {
    'tradingBalance': 0.4,
    'profit': 320.0,
    'successRate': 82.0,
    'totalTrades': 28
  };
  
  String? get ethereumAddress => _ethereumAddress;
  bool get arbitrageBotActive => _arbitrageBotActive;
  bool get liquidityBotActive => _liquidityBotActive;
  bool get marketMakingBotActive => _marketMakingBotActive;
  
  Map<String, dynamic> get bot1Performance => _bot1Performance;
  Map<String, dynamic> get bot2Performance => _bot2Performance;
  Map<String, dynamic> get bot3Performance => _bot3Performance;
  
  double get totalTradingBalance => 
      _bot1Performance['tradingBalance'] + _bot2Performance['tradingBalance'] + _bot3Performance['tradingBalance'];
  
  double get totalProfit => 
      _bot1Performance['profit'] + _bot2Performance['profit'] + _bot3Performance['profit'];
  
  double get totalSuccessRate => 
      (_bot1Performance['successRate'] + _bot2Performance['successRate'] + _bot3Performance['successRate']) / 3;
  
  Future<void> initialize() async {
    try {
      print('[TydChronos] Ecosystem Service initializing...');
      await _securityService.initialize();
      
      // Generate or retrieve Ethereum address
      final ethService = EthereumService();
      _ethereumAddress = await ethService.getAddress();
      
      if (_ethereumAddress == null) {
        print('[TydChronos] Generating new wallet...');
        final mnemonic = bip39.generateMnemonic();
        await ethService.createWalletFromMnemonic(mnemonic);
        _ethereumAddress = await ethService.getAddress();
        
        if (_ethereumAddress != null) {
          await _backendService.registerWallet(_ethereumAddress!);
          print('[TydChronos] New wallet created: $_ethereumAddress');
        }
      } else {
        print('[TydChronos] Existing wallet found: $_ethereumAddress');
      }
      
      // Sync with TydChronos backend
      if (_ethereumAddress != null) {
        await _backendService.syncWalletData(_ethereumAddress!);
        
        // Initialize snipping bots
        await _snippingBotService.initialize(_ethereumAddress!);
      }
      
      print('[TydChronos] Ecosystem Service initialized successfully');
      notifyListeners();
    } catch (e) {
      print('[TydChronos] Initialization error: $e');
    }
  }
  
  Future<void> initializeWallet() async {
    try {
      print('[TydChronos] Manual wallet initialization requested');
      await _securityService.initialize();
      
      final ethService = EthereumService();
      final mnemonic = bip39.generateMnemonic();
      await ethService.createWalletFromMnemonic(mnemonic);
      _ethereumAddress = await ethService.getAddress();
      
      if (_ethereumAddress != null) {
        await _backendService.registerWallet(_ethereumAddress!);
        await _backendService.syncWalletData(_ethereumAddress!);
        await _snippingBotService.initialize(_ethereumAddress!);
        
        print('[TydChronos] Wallet created successfully: $_ethereumAddress');
        notifyListeners();
        
        return;
      }
      throw Exception('Failed to generate wallet address');
    } catch (e) {
      print('[TydChronos] Manual initialization error: $e');
      rethrow;
    }
  }
  
  // ==================== SNIPPING BOT MANAGEMENT ====================
  
  Future<Map<String, dynamic>> activateArbitrageBot() async {
    try {
      await _securityService.requireTransactionPin();
      final result = await _snippingBotService.activateArbitrageBot();
      _arbitrageBotActive = true;
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('Failed to activate arbitrage bot: $e');
    }
  }
  
  Future<Map<String, dynamic>> activateLiquidityBot() async {
    try {
      await _securityService.requireTransactionPin();
      final result = await _snippingBotService.activateLiquidityBot();
      _liquidityBotActive = true;
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('Failed to activate liquidity bot: $e');
    }
  }
  
  Future<Map<String, dynamic>> activateMarketMakingBot() async {
    try {
      await _securityService.requireTransactionPin();
      final result = await _snippingBotService.activateMarketMakingBot();
      _marketMakingBotActive = true;
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('Failed to activate market making bot: $e');
    }
  }
  
  Future<void> deactivateAllBots() async {
    await _snippingBotService.deactivateAllBots();
    _arbitrageBotActive = false;
    _liquidityBotActive = false;
    _marketMakingBotActive = false;
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> getBotPerformance() async {
    return await _snippingBotService.getBotPerformance();
  }
  
  // Send ETH to bots
  Future<void> sendEthToBot1(double amount) async {
    await _updateBotBalance('bot1', amount);
    notifyListeners();
  }
  
  Future<void> sendEthToBot2(double amount) async {
    await _updateBotBalance('bot2', amount);
    notifyListeners();
  }
  
  Future<void> sendEthToBot3(double amount) async {
    await _updateBotBalance('bot3', amount);
    notifyListeners();
  }
  
  // Send ETH from trading balance back to crypto wallet
  Future<void> sendEthToCryptoWallet(double amount) async {
    try {
      // Determine which bot to take funds from (prioritize by balance)
      if (_bot1Performance['tradingBalance'] >= amount) {
        _bot1Performance['tradingBalance'] -= amount;
      } else if (_bot2Performance['tradingBalance'] >= amount) {
        _bot2Performance['tradingBalance'] -= amount;
      } else if (_bot3Performance['tradingBalance'] >= amount) {
        _bot3Performance['tradingBalance'] -= amount;
      } else {
        // If no single bot has enough, take proportionally
        final total = totalTradingBalance;
        if (total >= amount) {
          final ratio = amount / total;
          _bot1Performance['tradingBalance'] -= _bot1Performance['tradingBalance'] * ratio;
          _bot2Performance['tradingBalance'] -= _bot2Performance['tradingBalance'] * ratio;
          _bot3Performance['tradingBalance'] -= _bot3Performance['tradingBalance'] * ratio;
        } else {
          throw Exception('Insufficient trading balance');
        }
      }
      
      print('Sent $amount ETH from trading balance to crypto wallet');
      notifyListeners();
    } catch (e) {
      print('Error sending ETH to crypto wallet: $e');
      rethrow;
    }
  }
  
  // Send profits back to crypto wallet
  Future<void> sendProfitsToCryptoWallet() async {
    // Simulate transferring all profits back to main wallet
    final totalProfits = totalProfit;
    _bot1Performance['profit'] = 0.0;
    _bot2Performance['profit'] = 0.0;
    _bot3Performance['profit'] = 0.0;
    
    print('Sent $totalProfits profits back to crypto wallet');
    notifyListeners();
  }
  
  Future<void> _updateBotBalance(String bot, double amount) async {
    // Simulate sending ETH to bot
    await Future.delayed(const Duration(seconds: 1));
    
    switch (bot) {
      case 'bot1':
        _bot1Performance['tradingBalance'] += amount;
        break;
      case 'bot2':
        _bot2Performance['tradingBalance'] += amount;
        break;
      case 'bot3':
        _bot3Performance['tradingBalance'] += amount;
        break;
    }
    
    print('Sent $amount ETH to $bot');
  }
  
  // ==================== TYDCHRONOS DAPP INTEGRATION ====================
  
  Future<void> connectToTydChronosDApp() async {
    print('[TydChronos] Connecting to TydChronos DApp...');
    await _securityService.requireBiometricAuth();
    
    // Simulate DApp connection
    await Future.delayed(const Duration(seconds: 2));
    
    await _backendService.logDAppConnection(_ethereumAddress!);
    print('[TydChronos] Connected to TydChronos DApp');
  }
  
  Future<Map<String, dynamic>> executeTydChronosTransaction({
    required String toAddress,
    required double amount,
    required String symbol,
    bool enableVolatilityProtection = true,
    required BuildContext context,
  }) async {
    await _securityService.requireTransactionPin();
    
    try {
      final networkMode = Provider.of<NetworkModeManager>(context, listen: false);
      String? lockedTxHash;
      
      // Enable volatility protection by locking value
      if (enableVolatilityProtection) {
        lockedTxHash = 'tx_${DateTime.now().millisecondsSinceEpoch}';
        networkMode.lockValue(lockedTxHash, amount, symbol);
      }
      
      final result = await TransactionService().executeTydChronosTransaction(
        fromAddress: _ethereumAddress!,
        toAddress: toAddress,
        amount: amount,
        symbol: symbol,
        enableVolatilityProtection: enableVolatilityProtection,
      );
      
      // Unlock value after transaction confirmation
      if (enableVolatilityProtection && lockedTxHash != null) {
        networkMode.unlockValue(lockedTxHash, symbol);
      }
      
      await _backendService.recordTransaction(result);
      notifyListeners();
      return result;
    } catch (e) {
      throw Exception('TydChronos transaction failed: $e');
    }
  }
  
  Map<String, dynamic> getEcosystemInfo() {
    return {
      'walletAddress': _ethereumAddress,
      'arbitrageBotActive': _arbitrageBotActive,
      'liquidityBotActive': _liquidityBotActive,
      'marketMakingBotActive': _marketMakingBotActive,
      'connectedToDApp': true,
    };
  }
}

// ==================== TYDCHRONOS ECOSYSTEM BUTTON ====================
class TydChronosEcosystemButton extends StatelessWidget {
  const TydChronosEcosystemButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TydChronosEcosystemService>(
      builder: (context, ecosystem, child) {
        return IconButton(
          icon: const Icon(
            Icons.account_balance_wallet,
            color: Color(0xFFD4AF37),
          ),
          onPressed: () => _showTydChronosDialog(context, ecosystem),
          tooltip: 'TydChronos Ecosystem',
        );
      },
    );
  }

  void _showTydChronosDialog(BuildContext context, TydChronosEcosystemService ecosystem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'TydChronos Ecosystem',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, color: Color(0xFFD4AF37), size: 50),
            const SizedBox(height: 16),
            const Text('TydChronos Wallet & DApp Integration', 
                     style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ecosystem.connectToTydChronosDApp();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              child: const Text('Connect to TydChronos DApp'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TYDCHRONOS LOGO WIDGET ====================
class TydChronosLogo extends StatelessWidget {
  final double size;
  final bool withBackground;
  final bool isAppBarIcon;

  const TydChronosLogo({
    super.key,
    required this.size,
    this.withBackground = true,
    this.isAppBarIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = isAppBarIcon 
        ? 'assets/icon/icon.png'
        : 'assets/images/logo.png';

    return Container(
      width: size,
      height: size,
      decoration: withBackground ? _buildBackgroundDecoration() : null,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        cacheWidth: size.toInt(),
        cacheHeight: size.toInt(),
        errorBuilder: (context, error, stackTrace) {
          print('Error loading $assetPath: $error');
          return _buildFallbackIcon();
        },
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFD4AF37),
          Color(0xFFFFD700),
          Color(0xFFD4AF37),
        ],
      ),
      borderRadius: BorderRadius.circular(size / 4),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        Icons.account_balance_wallet,
        size: size * (withBackground ? 0.6 : 0.8),
        color: withBackground ? Colors.black : const Color(0xFFD4AF37),
      ),
    );
  }
}

// ==================== DEBUG ASSET CHECK ====================

// Asset validation for production
Future<void> _debugCheckAssets() async {
  print('🔄 Checking asset availability...');

  final assetsToCheck = [
    'assets/images/logo.png',
    'assets/icon/icon.png',
  ];

  for (final asset in assetsToCheck) {
    try {
      final data = await rootBundle.load(asset);
      print('✅ $asset loaded successfully (${data.lengthInBytes} bytes)');
    } catch (e) {
      print('⚠️  $asset not found: $e');
    }
  }
  
  print('✅ Asset check completed');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _debugCheckAssets();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TydChronosEcosystemService()..initialize()),
          ChangeNotifierProvider(create: (context) => NetworkModeManager()),
          ChangeNotifierProvider(create: (context) => CurrencyManager()),
        ],
        child: const TydChronosWalletApp(),
      ),
    );
  } catch (error, stackTrace) {
    log('🚨 TydChronos Wallet failed to start: $error');
    log('Stack trace: $stackTrace');

    // Fallback UI for production
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'TydChronos Wallet',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Initialization error. Please refresh.',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TydChronosWalletApp extends StatelessWidget {
  const TydChronosWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TydChronos Wallet',
      theme: _buildBlackGoldTheme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildBlackGoldTheme() {
    return ThemeData(
      primaryColor: const Color(0xFFD4AF37),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD4AF37),
        secondary: Color(0xFFFFD700),
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFFD4AF37),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
      ),
      useMaterial3: false,
    );
  }
}

// ==================== BALANCE VISIBILITY MANAGER ====================
class BalanceVisibilityManager extends ChangeNotifier {
  bool _balancesVisible = true;

  bool get balancesVisible => _balancesVisible;

  void toggleBalances() {
    _balancesVisible = !_balancesVisible;
    notifyListeners();
  }

  String formatBalance(double amount, {String symbol = '\$', int decimalPlaces = 2}) {
    if (!_balancesVisible) {
      return '$symbol••••••';
    }
    return '$symbol${amount.toStringAsFixed(decimalPlaces)}';
  }

  String formatCryptoBalance(double amount, {int decimalPlaces = 4}) {
    if (!_balancesVisible) {
      return '••••••';
    }
    return amount.toStringAsFixed(decimalPlaces);
  }
}

class BalanceProvider extends InheritedWidget {
  final BalanceVisibilityManager balanceManager;

  const BalanceProvider({
    super.key,
    required this.balanceManager,
    required super.child,
  });

  static BalanceVisibilityManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<BalanceProvider>();
    if (provider == null) {
      throw FlutterError('BalanceProvider.of() called with a context that does not contain a BalanceProvider.');
    }
    return provider.balanceManager;
  }

  @override
  bool updateShouldNotify(BalanceProvider oldWidget) {
    return balanceManager != oldWidget.balanceManager;
  }
}

class BalanceConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, BalanceVisibilityManager balanceManager, Widget? child) builder;

  const BalanceConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      BalanceProvider.of(context),
      null,
    );
  }
}

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final networkMode = Provider.of<NetworkModeManager>(context, listen: false);
    await networkMode.fetchLivePrices();
    
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TydChronosHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TydChronosLogo(size: 150, withBackground: true, isAppBarIcon: false),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'TydChronos Wallet',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Advanced Banking & Cryptocurrency Platform',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading TydChronos Ecosystem...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DATA MODELS ====================
class FiatWallet {
  double balance = 12500.0;
  String selectedCurrency = 'USD';
  List<BankAccount> accounts = [
    BankAccount(name: 'Primary Checking', number: '**** 7890', balance: 7500.0, type: 'Checking'),
    BankAccount(name: 'Savings Account', number: '**** 4567', balance: 5000.0, type: 'Savings'),
  ];
  List<BankCard> cards = [
    BankCard(name: 'TydChronos Platinum', number: '**** 1234', expiry: '12/25', balance: 12500.0),
  ];
  List<Bill> bills = [
    Bill(name: 'Electricity', amount: 125.50, dueDate: '2024-01-15', status: 'Pending'),
    Bill(name: 'Internet', amount: 89.99, dueDate: '2024-01-20', status: 'Pending'),
  ];
  List<Transaction> transactions = [
    Transaction(type: 'Transfer', amount: -500.0, description: 'To John Doe', date: '2024-01-10'),
    Transaction(type: 'Deposit', amount: 2000.0, description: 'Salary', date: '2024-01-05'),
    Transaction(type: 'Withdrawal', amount: -200.0, description: 'ATM', date: '2024-01-03'),
  ];
}

class BankAccount {
  final String name;
  final String number;
  final double balance;
  final String type;
  
  BankAccount({
    required this.name,
    required this.number,
    required this.balance,
    required this.type,
  });
}

class BankCard {
  final String name;
  final String number;
  final String expiry;
  final double balance;
  
  BankCard({
    required this.name,
    required this.number,
    required this.expiry,
    required this.balance,
  });
}

class Bill {
  final String name;
  final double amount;
  final String dueDate;
  final String status;
  
  Bill({
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
  });
}

class Transaction {
  final String type;
  final double amount;
  final String description;
  final String date;
  
  Transaction({
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
}

class CryptoWallet {
  String selectedNetwork = 'Ethereum';
  String selectedCurrency = 'USD';
  String walletAddress = '0x742d35Cc6634C0532925a3b8D123456';
  List<CryptoAsset> assets = [
    CryptoAsset(symbol: 'ETH', name: 'Ethereum', balance: 2.5, usdValue: 7500.0, network: 'Ethereum', icon: '🟣'),
    CryptoAsset(symbol: 'BTC', name: 'Bitcoin', balance: 0.15, usdValue: 6487.0, network: 'Bitcoin', icon: '🟡'),
    CryptoAsset(symbol: 'ARB', name: 'Arbitrum', balance: 150.0, usdValue: 250.0, network: 'Arbitrum', icon: '🔵'),
    CryptoAsset(symbol: 'MATIC', name: 'Polygon', balance: 500.0, usdValue: 350.0, network: 'Polygon', icon: '🟣'),
    CryptoAsset(symbol: 'OP', name: 'Optimism', balance: 200.0, usdValue: 300.0, network: 'Optimism', icon: '🔴'),
    CryptoAsset(symbol: 'ZK', name: 'zkSync', balance: 100.0, usdValue: 150.0, network: 'zkSync', icon: '🟢'),
  ];
  
  double get totalValueUSD {
    return assets.fold(0.0, (sum, asset) => sum + asset.usdValue);
  }
}

class CryptoAsset {
  final String symbol;
  final String name;
  final double balance;
  final double usdValue;
  final String network;
  final String icon;
  
  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.usdValue,
    required this.network,
    required this.icon,
  });
}

class TradingBot {
  double tradingBalance = 1.2;
  bool isActive = true;
  double totalProfit = 1250.50;
  double successRate = 72.5;
  List<TradingPair> pairs = [
    TradingPair(pair: 'BTC/USD', price: 43245.67, change: 2.34),
    TradingPair(pair: 'ETH/USD', price: 3000.45, change: -1.23),
    TradingPair(pair: 'ARB/USD', price: 1.67, change: 5.67),
  ];
}

class TradingPair {
  final String pair;
  final double price;
  final double change;
  
  TradingPair({
    required this.pair,
    required this.price,
    required this.change,
  });
}

// ==================== MAIN HOME PAGE ====================
class TydChronosHomePage extends StatefulWidget {
  const TydChronosHomePage({super.key});

  @override
  State<TydChronosHomePage> createState() => _TydChronosHomePageState();
}

class _TydChronosHomePageState extends State<TydChronosHomePage> {
  int _selectedIndex = 0;
  final CryptoWallet _cryptoWallet = CryptoWallet();
  final FiatWallet _fiatWallet = FiatWallet();
  final TradingBot _tradingBot = TradingBot();
  final BalanceVisibilityManager _balanceManager = BalanceVisibilityManager();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _balanceManager),
      ],
      child: BalanceProvider(
        balanceManager: _balanceManager,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TydChronosLogo(size: 35, withBackground: false, isAppBarIcon: true),
            ),
            title: const Text(
              'TydChronos Wallet',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Consumer<NetworkModeManager>(
                builder: (context, networkMode, child) {
                  return IconButton(
                    icon: Icon(
                      networkMode.isTestnetMode ? Icons.security : Icons.attach_money,
                      color: networkMode.isTestnetMode ? Colors.orange : Colors.green,
                    ),
                    onPressed: () {
                      networkMode.toggleNetworkMode();
                    },
                    tooltip: 'Switch to ${networkMode.isTestnetMode ? 'Mainnet' : 'Testnet'}',
                  );
                },
              ),
              Consumer<TydChronosEcosystemService>(
                builder: (context, ecosystem, child) {
                  if (ecosystem.ethereumAddress != null) {
                    return IconButton(
                      icon: const Icon(Icons.qr_code, color: Color(0xFFD4AF37)),
                      onPressed: () {
                        _showAddressDialogWithQR(context, ecosystem.ethereumAddress!);
                      },
                      tooltip: 'Your TydChronos Address',
                    );
                  }
                  return const SizedBox();
                },
              ),
              const TydChronosEcosystemButton(),
              Builder(
                builder: (context) {
                  final balanceManager = BalanceProvider.of(context);
                  return IconButton(
                    icon: Icon(
                      balanceManager.balancesVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFFD4AF37),
                    ),
                    onPressed: () {
                      balanceManager.toggleBalances();
                    },
                    tooltip: balanceManager.balancesVisible ? 'Hide Balances' : 'Show Balances',
                  );
                },
              ),
            ],
          ),
          body: _getCurrentScreen(),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: Colors.grey.shade600,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
              BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_motion), label: 'TRADING'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
      case 1:
        return CryptoScreen(
          cryptoWallet: _cryptoWallet,
          tradingBot: _tradingBot,
        );
      case 2:
        return ChangeNotifierProvider(
          create: (context) => TradingController(),
          child: const AutomatedTradingScreen(),
        );
      case 3:
        return EWalletScreen(fiatWallet: _fiatWallet);
      case 4:
        return SettingsSecurityScreen();
      default:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
    }
  }

  void _showAddressDialogWithQR(BuildContext context, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Your TydChronos Address',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: Center(
                child: Text(
                  'QR Code\n$address',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      address,
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    color: const Color(0xFFD4AF37),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan QR code or copy address to receive funds',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}

// ==================== OVERVIEW SCREEN ====================
class OverviewScreen extends StatelessWidget {
  final CryptoWallet cryptoWallet;
  final FiatWallet fiatWallet;
  final TradingBot tradingBot;

  const OverviewScreen({
    super.key,
    required this.cryptoWallet,
    required this.fiatWallet,
    required this.tradingBot,
  });

  @override
  Widget build(BuildContext context) {
    final networkMode = Provider.of<NetworkModeManager>(context);
    final ecosystem = Provider.of<TydChronosEcosystemService>(context);
    final currencyManager = Provider.of<CurrencyManager>(context);
    
    double totalNetWorth = networkMode.getAdjustedBalance(
      cryptoWallet.totalValueUSD + fiatWallet.balance + (tradingBot.tradingBalance * 3000)
    );

    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: networkMode.isTestnetMode ? Colors.orange : Colors.green,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      networkMode.isTestnetMode ? Icons.security : Icons.attach_money,
                      color: networkMode.isTestnetMode ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${networkMode.currentNetwork} Mode',
                            style: TextStyle(
                              color: networkMode.isTestnetMode ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            networkMode.currentNetworkSubtitle,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        networkMode.toggleNetworkMode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Switch to ${networkMode.isTestnetMode ? 'Mainnet' : 'Testnet'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Net Worth',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      balanceManager.formatBalance(totalNetWorth, symbol: currencyManager.currencySymbol),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Crypto', 
                      networkMode.getNetworkAdjustedBalance(cryptoWallet.totalValueUSD, symbol: currencyManager.currencySymbol), 
                      Colors.orange
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceCard(
                      'Banking', 
                      networkMode.getNetworkAdjustedBalance(fiatWallet.balance, symbol: currencyManager.currencySymbol), 
                      Colors.blue
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Trading', 
                      networkMode.getNetworkAdjustedBalance(tradingBot.tradingBalance * 3000, symbol: currencyManager.currencySymbol), 
                      Colors.green
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceCard(
                      'TydChronos DApp', 
                      'Connected', 
                      const Color(0xFFD4AF37)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildMultiChainAssets(balanceManager, networkMode, currencyManager),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.currency_bitcoin, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 8),
                        const Text(
                          'TydChronos Ecosystem',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (ecosystem.ethereumAddress == null) ...[
                      const Text(
                        'No TydChronos wallet found. Initialize to access full ecosystem.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Initialize TydChronos Wallet'),
                        onPressed: () async {
                          try {
                            await ecosystem.initializeWallet();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('TydChronos Wallet initialized successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error initializing wallet: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your TydChronos Address:', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD4AF37)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    ecosystem.ethereumAddress!,
                                    style: TextStyle(
                                      fontFamily: 'Monospace',
                                      fontSize: 12,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  color: const Color(0xFFD4AF37),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: ecosystem.ethereumAddress!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Address copied to clipboard'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('DApp Status:', style: TextStyle(color: Colors.grey)),
                              Text(
                                'Ready',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _showVolatilityProtectedTransaction(context, ecosystem, networkMode);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Execute Protected Transaction'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVolatilityProtectedTransaction(BuildContext context, TydChronosEcosystemService ecosystem, NetworkModeManager networkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Volatility Protected Transaction', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send 0.01 ETH with price protection', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            const Text('🔒 Value locked until blockchain confirmation', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await ecosystem.executeTydChronosTransaction(
                    toAddress: '0x742d35Cc6634C0532925a3b8D123456',
                    amount: 0.01,
                    symbol: 'ETH',
                    enableVolatilityProtection: true,
                    context: context,
                  );
                  Navigator.pop(context);
                  _showSuccessDialog(context, result);
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorDialog(context, e.toString());
                }
              },
              child: const Text('Confirm Protected Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transaction Successful', style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TX Hash: ${result['txHash']}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            const Text('✅ Value protection active', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transaction Failed', style: TextStyle(color: Colors.red)),
        content: Text(error, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiChainAssets(BalanceVisibilityManager balanceManager, NetworkModeManager networkMode, CurrencyManager currencyManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Multi-Chain Assets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemCount: cryptoWallet.assets.length,
          itemBuilder: (context, index) {
            final asset = cryptoWallet.assets[index];
            final adjustedValue = networkMode.getAdjustedBalance(asset.usdValue);
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    asset.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          asset.symbol,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          asset.network,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        adjustedValue > 0 ? '${currencyManager.currencySymbol}${adjustedValue.toStringAsFixed(2)}' : '••••••',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        balanceManager.formatCryptoBalance(asset.balance),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==================== CRYPTO SCREEN ====================
class CryptoScreen extends StatefulWidget {
  final CryptoWallet cryptoWallet;
  final TradingBot tradingBot;

  const CryptoScreen({super.key, required this.cryptoWallet, required this.tradingBot});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  int _cryptoSelectedIndex = 0;

  void _onCryptoItemTapped(int index) {
    setState(() {
      _cryptoSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ecosystem = Provider.of<TydChronosEcosystemService>(context);
    final networkMode = Provider.of<NetworkModeManager>(context);
    final currencyManager = Provider.of<CurrencyManager>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        title: const Text(
          'CRYPTO',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (ecosystem.ethereumAddress != null)
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                _showWalletAddressDialog(ecosystem.ethereumAddress!);
              },
              color: const Color(0xFFD4AF37),
            ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showNetworkSelector,
            color: const Color(0xFFD4AF37),
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: _showCurrencySelector,
            color: const Color(0xFFD4AF37),
          ),
        ],
      ),
      body: _cryptoSelectedIndex == 0 ? _buildCryptoWalletTab(networkMode, ecosystem, currencyManager) : _buildAITradingTab(networkMode, ecosystem, currencyManager),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _cryptoSelectedIndex,
        onTap: _onCryptoItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Crypto Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'AI Trading'),
        ],
      ),
    );
  }

  Widget _buildCryptoWalletTab(NetworkModeManager networkMode, TydChronosEcosystemService ecosystem, CurrencyManager currencyManager) {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Crypto Value',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      balanceManager.formatBalance(networkMode.getAdjustedBalance(widget.cryptoWallet.totalValueUSD), symbol: currencyManager.currencySymbol),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions - REMOVED "Send ETH to Crypto" from here
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: [
                  _buildCryptoActionItem(Icons.arrow_upward, 'Send', Colors.red, () {
                    _showSendDialog(ecosystem, networkMode, context);
                  }),
                  _buildCryptoActionItem(Icons.arrow_downward, 'Receive', Colors.green, () {
                    _showReceiveDialog(ecosystem);
                  }),
                  _buildCryptoActionItem(Icons.swap_horiz, 'Swap', Colors.blue, () {
                    _showSwapDialog(ecosystem, networkMode, context);
                  }),
                  _buildCryptoActionItem(Icons.account_balance_wallet, 'Bridge', Colors.purple, () {
                    _showBridgeDialog(ecosystem, networkMode, context);
                  }),
                  _buildCryptoActionItem(Icons.shopping_cart, 'Buy', Colors.teal, () {
                    _showBuyDialog(ecosystem, networkMode, context);
                  }),
                  _buildCryptoActionItem(Icons.attach_money, 'Sell', Colors.orange, () {
                    _showSellDialog(ecosystem, networkMode, context);
                  }),
                  _buildCryptoActionItem(Icons.smart_toy, 'Send ETH Bot 1', Colors.green, () {
                    _showSendToBotDialog(context, ecosystem, 'Arbitrage Bot', 'bot1', 0.1);
                  }),
                  _buildCryptoActionItem(Icons.water_drop, 'Send ETH Bot 2', Colors.blue, () {
                    _showSendToBotDialog(context, ecosystem, 'Liquidity Bot', 'bot2', 0.1);
                  }),
                  _buildCryptoActionItem(Icons.trending_up, 'Send ETH Bot 3', Colors.orange, () {
                    _showSendToBotDialog(context, ecosystem, 'Market Making Bot', 'bot3', 0.1);
                  }),
                  _buildCryptoActionItem(Icons.account_balance, 'Transfer TydChronos', Colors.amber, () {
                    _showTransferTydChronosDialog(context, ecosystem, networkMode);
                  }),
                  _buildCryptoActionItem(Icons.qr_code_scanner, 'Scan', Colors.indigo, () {
                    _showScanDialog(context);
                  }),
                  _buildCryptoActionItem(Icons.more_horiz, 'More', Colors.grey, () {
                    // Additional actions
                  }),
                ],
              ),
              const SizedBox(height: 20),

              ...widget.cryptoWallet.assets.map((asset) {
                final adjustedValue = networkMode.getAdjustedBalance(asset.usdValue);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          asset.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    title: Text(
                      '${asset.symbol} - ${asset.network}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      asset.name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          adjustedValue > 0 ? '${currencyManager.currencySymbol}${adjustedValue.toStringAsFixed(2)}' : '••••••',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          balanceManager.formatCryptoBalance(asset.balance),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Send ETH to Bot Dialog
  void _showSendToBotDialog(BuildContext context, TydChronosEcosystemService ecosystem, String botName, String botId, double defaultAmount) {
    double amount = defaultAmount;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Send ETH to $botName', style: const TextStyle(color: Color(0xFFD4AF37))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Fund your trading bot with ETH', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'ETH Amount',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    amount = double.tryParse(value) ?? defaultAmount;
                  },
                ),
                const SizedBox(height: 12),
                Text('Current balance: ${_getBotBalance(ecosystem, botId)} ETH', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                const Text('🚀 Boost your trading performance', style: const TextStyle(color: Colors.green, fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      switch (botId) {
                        case 'bot1':
                          await ecosystem.sendEthToBot1(amount);
                          break;
                        case 'bot2':
                          await ecosystem.sendEthToBot2(amount);
                          break;
                        case 'bot3':
                          await ecosystem.sendEthToBot3(amount);
                          break;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sent $amount ETH to $botName'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Send $amount ETH to $botName'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getBotBalance(TydChronosEcosystemService ecosystem, String botId) {
    switch (botId) {
      case 'bot1':
        return ecosystem.bot1Performance['tradingBalance'];
      case 'bot2':
        return ecosystem.bot2Performance['tradingBalance'];
      case 'bot3':
        return ecosystem.bot3Performance['tradingBalance'];
      default:
        return 0.0;
    }
  }

  Widget _buildCryptoActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Transfer TydChronos Wallet Dialog
  void _showTransferTydChronosDialog(BuildContext context, TydChronosEcosystemService ecosystem, NetworkModeManager networkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transfer to TydChronos Wallet', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transfer fiat funds from Crypto wallet to E-wallet', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAssetSelector('Select Asset', 'USD'),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Transfer to: E-Wallet', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('💸 Instant transfer between wallets', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transfer to TydChronos Wallet completed'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Transfer Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Bridge Dialog
  void _showBridgeDialog(TydChronosEcosystemService ecosystem, NetworkModeManager networkMode, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cross-Chain Bridge', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bridge assets between different blockchains', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            _buildNetworkSelector('From Network', 'Ethereum'),
            const SizedBox(height: 12),
            _buildNetworkSelector('To Network', 'Polygon'),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('🔒 Secure cross-chain bridge with TydChronos protection', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bridge transaction initiated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Start Bridge'),
            ),
          ],
        ),
      ),
    );
  }

  // Buy Dialog
  void _showBuyDialog(TydChronosEcosystemService ecosystem, NetworkModeManager networkMode, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Buy Crypto', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Purchase cryptocurrency with fiat', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAssetSelector('Select Asset', 'ETH'),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount (USD)',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Estimated: 0.033 ETH', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('💳 Instant bank transfer available', style: TextStyle(color: Colors.blue, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buy order placed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Buy Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Sell Dialog
  void _showSellDialog(TydChronosEcosystemService ecosystem, NetworkModeManager networkMode, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Sell Crypto', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sell cryptocurrency for fiat', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            _buildAssetSelector('Select Asset', 'ETH'),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount to Sell',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Estimated: \$50.25 USD', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('💰 Instant withdrawal to bank account', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sell order placed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Sell Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Scan Dialog
  void _showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('QR Scanner', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scan QR code for addresses or payment requests', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QR scanner activated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Start Scanning'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSelector(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(initialValue, style: const TextStyle(color: Colors.white)),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssetSelector(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🟣', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(initialValue, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  void _showSendDialog(TydChronosEcosystemService ecosystem, NetworkModeManager networkMode, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Send Crypto', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient Address',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.security, color: Colors.green, size: 16),
                const SizedBox(width: 5),
                const Text('Enable volatility protection', style: TextStyle(color: Colors.green, fontSize: 12)),
                const Spacer(),
                Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: const Color(0xFFD4AF37),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ecosystem.executeTydChronosTransaction(
                    toAddress: '0x742d35Cc6634C0532925a3b8D123456',
                    amount: 0.01,
                    symbol: 'ETH',
                    enableVolatilityProtection: true,
                    context: context,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sending with volatility protection...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Send with Protection'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiveDialog(TydChronosEcosystemService ecosystem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Receive Crypto', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ecosystem.ethereumAddress != null) ...[
              const Text('Your TydChronos Address:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              SelectableText(
                ecosystem.ethereumAddress!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                color: Colors.white,
                child: const Center(
                  child: Text('TydChronos QR', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSwapDialog(TydChronosEcosystemService ecosystem, NetworkModeManager networkMode, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Swap Assets', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('TydChronos DApp swap interface', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            Text('🔒 Volatility protection enabled', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ecosystem.connectToTydChronosDApp();
              Navigator.pop(context);
            },
            child: const Text('Connect to DApp', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  Widget _buildAITradingTab(NetworkModeManager networkMode, TydChronosEcosystemService ecosystem, CurrencyManager currencyManager) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Snipping Bots Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.smart_toy, size: 50, color: Color(0xFFD4AF37)),
                const SizedBox(height: 10),
                const Text(
                  'TydChronos Snipping Bots',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Advanced DeFi trading automation integrated with TydChronos Smart Contracts',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // UPDATED: AI Trading Stats with Send ETH to Crypto Wallet button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'AI Trading Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Trading Balance', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${ecosystem.totalTradingBalance.toStringAsFixed(4)} ETH',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Total Profit', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${currencyManager.currencySymbol}${ecosystem.totalProfit.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Total Success Rate', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${ecosystem.totalSuccessRate.toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text('Send Profits to Crypto'),
                        onPressed: () {
                          ecosystem.sendProfitsToCryptoWallet();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profits sent to crypto wallet'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Send ETH to Crypto'),
                        onPressed: () {
                          _showSendToCryptoWalletDialog(context, ecosystem);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // UPDATED: Individual Bot Performance Cards
          _buildBotPerformanceCard(
            'Arbitrage Bot / Bot 1',
            'Automated cross-exchange arbitrage opportunities',
            Icons.compare_arrows,
            Colors.green,
            ecosystem.bot1Performance,
            ecosystem.arbitrageBotActive,
            () => _activateArbitrageBot(context, ecosystem),
            () => _deactivateBot(context, ecosystem),
            currencyManager,
          ),
          const SizedBox(height: 16),

          _buildBotPerformanceCard(
            'Liquidity Bot / Bot 2',
            'Automated liquidity provision and yield farming',
            Icons.water_drop,
            Colors.blue,
            ecosystem.bot2Performance,
            ecosystem.liquidityBotActive,
            () => _activateLiquidityBot(context, ecosystem),
            () => _deactivateBot(context, ecosystem),
            currencyManager,
          ),
          const SizedBox(height: 16),

          _buildBotPerformanceCard(
            'Market Making Bot / Bot 3',
            'Automated market making and spread capture',
            Icons.trending_up,
            Colors.orange,
            ecosystem.bot3Performance,
            ecosystem.marketMakingBotActive,
            () => _activateMarketMakingBot(context, ecosystem),
            () => _deactivateBot(context, ecosystem),
            currencyManager,
          ),
          const SizedBox(height: 20),

          // Bot Performance
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Bot Performance Analytics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: ecosystem.getBotPerformance(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: Color(0xFFD4AF37));
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                    }
                    final performance = snapshot.data ?? {};
                    return Column(
                      children: [
                        _buildPerformanceItem('Total Trades', '${performance['totalTrades'] ?? '0'}'),
                        _buildPerformanceItem('Success Rate', '${performance['successRate'] ?? '0'}%'),
                        _buildPerformanceItem('Total Profit', '${currencyManager.currencySymbol}${performance['totalProfit'] ?? '0'}'),
                        _buildPerformanceItem('Active Bots', '${performance['activeBots'] ?? '0'}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Send ETH from Trading Balance to Crypto Wallet Dialog
  void _showSendToCryptoWalletDialog(BuildContext context, TydChronosEcosystemService ecosystem) {
    double amount = 0.0;
    final totalTradingBalance = ecosystem.totalTradingBalance;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Send ETH to Crypto Wallet', style: TextStyle(color: Color(0xFFD4AF37))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Transfer ETH from trading balance to your crypto wallet', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Text('Available Trading Balance: ${totalTradingBalance.toStringAsFixed(4)} ETH', 
                  style: const TextStyle(color: Colors.green, fontSize: 14)),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'ETH Amount',
                    labelStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Text('MAX', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                      onPressed: () {
                        setState(() {
                          amount = totalTradingBalance;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    amount = double.tryParse(value) ?? 0.0;
                  },
                  controller: TextEditingController(text: amount > 0 ? amount.toString() : ''),
                ),
                const SizedBox(height: 12),
                if (amount > totalTradingBalance)
                  const Text('Insufficient balance!', style: TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 16),
                const Text('💸 Transfer from trading bots to main wallet', style: TextStyle(color: Colors.green, fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: amount > 0 && amount <= totalTradingBalance ? () async {
                    Navigator.pop(context);
                    try {
                      await ecosystem.sendEthToCryptoWallet(amount);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sent $amount ETH to crypto wallet'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                  child: Text('Send ${amount.toStringAsFixed(4)} ETH to Crypto Wallet'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // UPDATED: Bot Performance Card with detailed stats
  Widget _buildBotPerformanceCard(
    String title,
    String description,
    IconData icon,
    Color color,
    Map<String, dynamic> performance,
    bool isActive,
    VoidCallback onActivate,
    VoidCallback onDeactivate,
    CurrencyManager currencyManager,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade700,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isActive ? onDeactivate : onActivate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.red : const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isActive ? 'Deactivate' : 'Activate'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bot Performance Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Trading Balance', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '${performance['tradingBalance']} ETH',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Profit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '${currencyManager.currencySymbol}${performance['profit']}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Success Rate', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '${performance['successRate']}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _activateArbitrageBot(BuildContext context, TydChronosEcosystemService ecosystem) async {
    try {
      final result = await ecosystem.activateArbitrageBot();
      _showBotActivationSuccess(context, 'Arbitrage Bot', result);
    } catch (e) {
      _showBotActivationError(context, 'Arbitrage Bot', e.toString());
    }
  }

  void _activateLiquidityBot(BuildContext context, TydChronosEcosystemService ecosystem) async {
    try {
      final result = await ecosystem.activateLiquidityBot();
      _showBotActivationSuccess(context, 'Liquidity Bot', result);
    } catch (e) {
      _showBotActivationError(context, 'Liquidity Bot', e.toString());
    }
  }

  void _activateMarketMakingBot(BuildContext context, TydChronosEcosystemService ecosystem) async {
    try {
      final result = await ecosystem.activateMarketMakingBot();
      _showBotActivationSuccess(context, 'Market Making Bot', result);
    } catch (e) {
      _showBotActivationError(context, 'Market Making Bot', e.toString());
    }
  }

  void _deactivateBot(BuildContext context, TydChronosEcosystemService ecosystem) async {
    try {
      await ecosystem.deactivateAllBots();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All snipping bots deactivated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deactivating bots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBotActivationSuccess(BuildContext context, String botName, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('$botName Activated', style: const TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            Text('$botName is now active and monitoring opportunities', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Text('Smart Contract: ${result['contractAddress']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showBotActivationError(BuildContext context, String botName, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('$botName Activation Failed', style: const TextStyle(color: Colors.red)),
        content: Text(error, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showNetworkSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        final networks = ['Ethereum', 'Bitcoin', 'Arbitrum', 'Polygon', 'Optimism', 'zkSync'];
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Network',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...networks.map((network) => ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFD4AF37)),
                title: Text(network, style: const TextStyle(color: Colors.white)),
                trailing: widget.cryptoWallet.selectedNetwork == network
                    ? const Icon(Icons.check, color: Color(0xFFD4AF37))
                    : null,
                onTap: () {
                  setState(() {
                    widget.cryptoWallet.selectedNetwork = network;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencySelector() {
    final currencyManager = Provider.of<CurrencyManager>(context, listen: false);
    final currencies = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CNY': '¥', 'INR': '₹', 
      'NGN': '₦', 'CAD': '\$', 'AUD': '\$', 'BTC': '₿', 'ETH': 'Ξ'
    };
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...currencies.entries.map((currency) => ListTile(
                leading: Text(
                  currency.value,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                title: Text(currency.key, style: const TextStyle(color: Colors.white)),
                trailing: currencyManager.selectedCurrency == currency.key
                    ? const Icon(Icons.check, color: Color(0xFFD4AF37))
                    : null,
                onTap: () {
                  currencyManager.setCurrency(currency.key);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showWalletAddressDialog(String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Your TydChronos Address',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: Center(
                child: Text(
                  'QR Code\n$address',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      address,
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    color: const Color(0xFFD4AF37),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan QR code or copy address to receive funds',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}

// ==================== E-WALLET SCREEN ====================
class EWalletScreen extends StatefulWidget {
  final FiatWallet fiatWallet;

  const EWalletScreen({super.key, required this.fiatWallet});

  @override
  State<EWalletScreen> createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  int _eWalletSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currencyManager = Provider.of<CurrencyManager>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        title: const Text(
          'E-WALLET',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              _showTransferTydChronosDialog(context);
            },
            color: const Color(0xFFD4AF37),
            tooltip: 'Transfer TydChronos Wallet',
          ),
        ],
      ),
      body: _eWalletSelectedIndex == 0 ? _buildWalletTab(currencyManager) : _buildBankingTab(currencyManager),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _eWalletSelectedIndex,
        onTap: (index) {
          setState(() {
            _eWalletSelectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Banking'),
        ],
      ),
    );
  }

  // Transfer TydChronos Wallet Dialog for E-Wallet
  void _showTransferTydChronosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transfer TydChronos Wallet', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transfer fiat funds to another TydChronos Wallet', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient TydChronos Address',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Transfer Type: External TydChronos Wallet', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('🔒 Secure transfer with TydChronos protection', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transfer to TydChronos Wallet initiated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Transfer Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab(CurrencyManager currencyManager) {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Available Balance', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      balanceManager.formatBalance(widget.fiatWallet.balance, symbol: currencyManager.currencySymbol),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Trio buttons below Available Balance
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            Icons.arrow_upward,
                            'Withdraw',
                            Colors.red,
                            () {
                              _showWithdrawDialog(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            Icons.account_balance,
                            'Transfer Bank',
                            Colors.blue,
                            () {
                              _showTransferBankDialog(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            Icons.account_balance_wallet,
                            'Transfer TydChronos',
                            Colors.amber,
                            () {
                              _showTransferTydChronosDialog(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Added title for Recent Transactions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              ...widget.fiatWallet.transactions.map((transaction) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    transaction.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: transaction.amount > 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    transaction.type,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    transaction.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        balanceManager.formatBalance(transaction.amount.abs(), symbol: currencyManager.currencySymbol),
                        style: TextStyle(
                          color: transaction.amount > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.date,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  // Action Button Widget
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Withdraw Dialog
  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Withdraw Funds', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Withdraw funds to your bank account', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Bank Account',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('💸 1-3 business days processing', style: TextStyle(color: Colors.blue, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Withdrawal request submitted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Withdraw Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Transfer Bank Dialog
  void _showTransferBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Transfer to Bank', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transfer funds to another bank account', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient Account Number',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient Name',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('🔒 Secure bank transfer', style: TextStyle(color: Colors.green, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bank transfer initiated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Transfer Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankingTab(CurrencyManager currencyManager) {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: const Color(0xFFD4AF37),
              elevation: 0,
              bottom: const TabBar(
                indicatorColor: Color(0xFFD4AF37),
                labelColor: Color(0xFFD4AF37),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Accounts'),
                  Tab(text: 'Cards'),
                  Tab(text: 'Bills'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAccountsTab(balanceManager, currencyManager),
                _buildCardsTab(balanceManager, currencyManager),
                _buildBillsTab(balanceManager, currencyManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountsTab(BalanceVisibilityManager balanceManager, CurrencyManager currencyManager) {
    return ListView(
      children: [
        ...widget.fiatWallet.accounts.map((account) => Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance, color: Color(0xFFD4AF37)),
            title: Text(account.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(account.number, style: const TextStyle(color: Colors.grey)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(balanceManager.formatBalance(account.balance, symbol: currencyManager.currencySymbol), style: const TextStyle(color: Colors.white)),
                Text(account.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCardsTab(BalanceVisibilityManager balanceManager, CurrencyManager currencyManager) {
    return ListView.builder(
      itemCount: widget.fiatWallet.cards.length,
      itemBuilder: (context, index) {
        final card = widget.fiatWallet.cards[index];
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(card.number, style: const TextStyle(color: Colors.black, fontSize: 18)),
                const SizedBox(height: 10),
                Text('Expires ${card.expiry}', style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 10),
                Text('Balance: ${balanceManager.formatBalance(card.balance, symbol: currencyManager.currencySymbol)}', style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillsTab(BalanceVisibilityManager balanceManager, CurrencyManager currencyManager) {
    return ListView.builder(
      itemCount: widget.fiatWallet.bills.length,
      itemBuilder: (context, index) {
        final bill = widget.fiatWallet.bills[index];
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.receipt, color: Color(0xFFD4AF37)),
            title: Text(bill.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('Due: ${bill.dueDate}', style: const TextStyle(color: Colors.grey)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(balanceManager.formatBalance(bill.amount, symbol: currencyManager.currencySymbol), style: const TextStyle(color: Colors.white)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bill.status == 'Paid' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(bill.status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== SETTINGS & SECURITY SCREEN ====================
class SettingsSecurityScreen extends StatelessWidget {
  const SettingsSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyManager = Provider.of<CurrencyManager>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSecurityItem('Biometric Authentication', Icons.fingerprint, true),
                _buildSecurityItem('Two-Factor Authentication', Icons.security, true),
                _buildSecurityItem('Transaction PIN', Icons.pin, true),
                _buildSecurityItem('Volatility Protection', Icons.security, true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TydChronos Ecosystem',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem('DApp Connection', 'Connected', Icons.link),
                _buildSettingsItem('Smart Contracts', 'Active', Icons.code),
                _buildSettingsItem('Snipping Bots', '3 Available', Icons.smart_toy),
                _buildSettingsItem('Volatility Protection', 'Enabled', Icons.security),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Settings',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsItem('Currency', currencyManager.selectedCurrency, Icons.currency_exchange),
                _buildSettingsItem('Language', 'English', Icons.language),
                _buildSettingsItem('Theme', 'Dark', Icons.dark_mode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(String title, IconData icon, bool isEnabled) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) {},
        activeThumbColor: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildSettingsItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {},
    );
  }
}

// ==================== TRADING CONTROLLER ====================
class TradingController extends ChangeNotifier {
  bool _isTradingActive = false;
  double _tradingBalance = 0.0;
  
  bool get isTradingActive => _isTradingActive;
  double get tradingBalance => _tradingBalance;
  
  void toggleTrading() {
    _isTradingActive = !_isTradingActive;
    notifyListeners();
  }
  
  void updateTradingBalance(double amount) {
    _tradingBalance = amount;
    notifyListeners();
  }
}

// ==================== AUTOMATED TRADING SCREEN ====================
class AutomatedTradingScreen extends StatelessWidget {
  const AutomatedTradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
        elevation: 0,
        title: const Text(
          'AUTOMATED TRADING',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Automated Trading Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
