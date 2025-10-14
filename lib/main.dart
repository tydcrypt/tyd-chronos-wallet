import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bip39/bip39.dart' as bip39;
import 'services/ethereum_service.dart';

void main() {
  runApp(const TydChronosWalletApp());
}

class TydChronosWalletApp extends StatelessWidget {
  const TydChronosWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TydChronos',
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
      return '${symbol}••••••';
    }
    return '${symbol}${amount.toStringAsFixed(decimalPlaces)}';
  }

  String formatCryptoBalance(double amount, {int decimalPlaces = 4}) {
    if (!_balancesVisible) {
      return '••••••';
    }
    return amount.toStringAsFixed(decimalPlaces);
  }
}

// ==================== SIMPLE PROVIDER IMPLEMENTATION ====================

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
    Timer(const Duration(seconds: 10), () {
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
            _buildLogo(150),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'TydChronos',
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
              'Loading secure wallet services...',
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

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderLogo(size);
        },
      ),
    );
  }

  Widget _buildPlaceholderLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFD4AF37),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet,
          size: size * 0.6,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ==================== ENHANCED MODELS ====================

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

// ==================== MAIN APP WITH BALANCE TOGGLE ====================

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
    return BalanceProvider(
      balanceManager: _balanceManager,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildLogo(35),
          ),
          title: const Text(
            'TydChronos',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Balance Toggle Button
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
          unselectedItemColor: Colors.grey[600],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'OVERVIEW'),
            BottomNavigationBarItem(icon: Icon(Icons.currency_bitcoin), label: 'CRYPTO'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'E-WALLET'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFFD4AF37),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.account_balance_wallet,
              size: size * 0.6,
              color: Colors.black,
            ),
          ),
        );
      },
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
        return EWalletScreen(fiatWallet: _fiatWallet);
      case 3:
        return SettingsSecurityScreen();
      default:
        return OverviewScreen(
          cryptoWallet: _cryptoWallet,
          fiatWallet: _fiatWallet,
          tradingBot: _tradingBot,
        );
    }
  }
}

// ==================== OVERVIEW SCREEN WITH BALANCE TOGGLE ====================

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
    double totalNetWorth = cryptoWallet.totalValueUSD + fiatWallet.balance + (tradingBot.tradingBalance * 3000);

    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Net Worth Balance
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
                      balanceManager.formatBalance(totalNetWorth),
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

              // Balance Breakdown
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard('Crypto', balanceManager.formatBalance(cryptoWallet.totalValueUSD), Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceCard('Banking', balanceManager.formatBalance(fiatWallet.balance), Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard('Trading', balanceManager.formatBalance(tradingBot.tradingBalance * 3000), Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(), // Empty for alignment
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Multi-Chain Assets Section
              _buildMultiChainAssets(balanceManager),
            ],
          ),
        );
      },
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

  Widget _buildMultiChainAssets(BalanceVisibilityManager balanceManager) {
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
                        balanceManager.formatBalance(asset.usdValue),
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

// ==================== CRYPTO SCREEN WITH ETHEREUM WALLET ====================

class CryptoScreen extends StatefulWidget {
  final CryptoWallet cryptoWallet;
  final TradingBot tradingBot;

  const CryptoScreen({super.key, required this.cryptoWallet, required this.tradingBot});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  int _cryptoSelectedIndex = 0;
  final EthereumService _ethereumService = EthereumService();
  String? _mnemonic;
  String? _ethereumAddress;
  double _balance = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingWallet();
  }

  Future<void> _checkExistingWallet() async {
    final address = await _ethereumService.getAddress();
    if (address != null) {
      setState(() {
        _ethereumAddress = address;
      });
      _getBalance();
    }
  }

  Future<void> _createNewWallet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _mnemonic = bip39.generateMnemonic();
      await _ethereumService.createWalletFromMnemonic(_mnemonic!);
      final address = await _ethereumService.getAddress();
      
      setState(() {
        _ethereumAddress = address;
        _isLoading = false;
      });
      
      _showMnemonicDialog(_mnemonic!);
      _getBalance();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to create wallet: $e');
    }
  }

  Future<void> _getBalance() async {
    if (_ethereumAddress == null) return;
    
    try {
      final balance = await _ethereumService.getBalance();
      setState(() {
        _balance = balance;
      });
    } catch (e) {
      _showError('Failed to get balance: $e');
    }
  }

  void _showMnemonicDialog(String mnemonic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('🔐 Backup Your Wallet', style: TextStyle(color: Color(0xFFD4AF37))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write down these 12 words in order and store them securely:',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD4AF37)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: Text(
                  mnemonic,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '⚠️ Never share these words! Anyone with this phrase can access your funds.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Your Ethereum Address:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SelectableText(
                _ethereumAddress ?? 'Generating...',
                style: TextStyle(
                  fontFamily: 'Monospace',
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('I have saved it securely', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showFaucetInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('💧 Get Test ETH', style: TextStyle(color: Color(0xFFD4AF37))),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('For Goerli Testnet:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _buildFaucetLink('https://goerli-faucet.pk910.de/'),
                _buildFaucetLink('https://faucet.quicknode.com/ethereum/goerli'),
                _buildFaucetLink('https://goerlifaucet.com/'),
                SizedBox(height: 16),
                Text('For Sepolia Testnet:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _buildFaucetLink('https://sepolia-faucet.pk910.de/'),
                _buildFaucetLink('https://faucet.quicknode.com/ethereum/sepolia'),
                _buildFaucetLink('https://sepolia-faucet.com/'),
                SizedBox(height: 16),
                Text(
                  'Send 0.001 ETH to test transactions. Verify on Etherscan.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFaucetLink(String url) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: () {
          _showError('Open: $url');
        },
        child: Text(
          url,
          style: TextStyle(
            color: Colors.blue[400],
            decoration: TextDecoration.underline,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _onCryptoItemTapped(int index) {
    setState(() {
      _cryptoSelectedIndex = index;
    });
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

  void _showWalletQR() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Wallet Address',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cryptoWallet.walletAddress,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan QR Code',
              style: TextStyle(color: Colors.grey),
            ),
            // QR code placeholder
            Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: const Center(
                child: Text('QR Code', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    final currencies = {'USD': '\$', 'EUR': '€', 'GBP': '£', 'NGN': '₦'};
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
                trailing: widget.cryptoWallet.selectedCurrency == currency.key
                    ? const Icon(Icons.check, color: Color(0xFFD4AF37))
                    : null,
                onTap: () {
                  setState(() {
                    widget.cryptoWallet.selectedCurrency = currency.key;
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

  @override
  Widget build(BuildContext context) {
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
          // Network Selector
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showNetworkSelector,
            color: const Color(0xFFD4AF37),
            tooltip: 'Select Network',
          ),
          // Wallet Address/QR
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showWalletQR,
            color: const Color(0xFFD4AF37),
            tooltip: 'Wallet Address',
          ),
          // Currency Selector
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: _showCurrencySelector,
            color: const Color(0xFFD4AF37),
            tooltip: 'Select Currency',
          ),
        ],
      ),
      body: _cryptoSelectedIndex == 0 ? _buildCryptoWalletTab() : _buildTradingTab(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[600],
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

  Widget _buildCryptoWalletTab() {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ethereum Wallet Section
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
                        Icon(Icons.currency_bitcoin, color: Color(0xFFD4AF37)),
                        SizedBox(width: 8),
                        Text(
                          'Ethereum Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    if (_ethereumAddress == null) ...[
                      Text(
                        'No Ethereum wallet found. Create one to start using DeFi features.',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      SizedBox(height: 16),
                      _isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                          : ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Create New Wallet'),
                              onPressed: _createNewWallet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                    ] else ...[
                      // Wallet Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address:', style: TextStyle(color: Colors.grey[400])),
                          SelectableText(
                            _ethereumAddress!,
                            style: TextStyle(
                              fontFamily: 'Monospace',
                              fontSize: 12,
                              color: Colors.grey[300],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Balance:', style: TextStyle(color: Colors.grey[400])),
                              Text(
                                '${_balance.toStringAsFixed(4)} ETH',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.refresh),
                                  label: Text('Refresh'),
                                  onPressed: _getBalance,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFFD4AF37),
                                    side: BorderSide(color: Color(0xFFD4AF37)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.water_drop),
                                  label: Text('Get ETH'),
                                  onPressed: _showFaucetInfo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[800],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Total Crypto Value
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
                      balanceManager.formatBalance(widget.cryptoWallet.totalValueUSD),
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

              // Crypto Quick Actions
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: [
                  _buildCryptoActionItem(Icons.arrow_upward, 'Send', Colors.red),
                  _buildCryptoActionItem(Icons.arrow_downward, 'Receive', Colors.green),
                  _buildCryptoActionItem(Icons.swap_horiz, 'Swap', Colors.blue),
                  _buildCryptoActionItem(Icons.qr_code_scanner, 'Scan', Colors.purple),
                  _buildCryptoActionItem(Icons.currency_bitcoin, 'Buy', Colors.orange),
                  _buildCryptoActionItem(Icons.sell, 'Sell', Colors.red),
                  _buildCryptoActionItem(Icons.account_balance, 'Stake', Colors.teal),
                  _buildCryptoActionItem(Icons.account_balance_wallet, 'Bridge', Colors.cyan),
                ],
              ),
              const SizedBox(height: 20),

              // Other Blockchain Wallets Section
              Text(
                'Multi-Chain Wallets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildChainCard('Polygon', Icons.polyline, Colors.purple),
                  _buildChainCard('Bitcoin', Icons.currency_bitcoin, Colors.orange),
                  _buildChainCard('zkSync Era', Icons.bolt, Colors.blue),
                  _buildChainCard('Arbitrum', Icons.settings, Colors.cyan),
                  _buildChainCard('Optimism', Icons.flash_on, Colors.red),
                  _buildChainCard('Avalanche', Icons.ac_unit, Colors.red[300]!),
                ],
              ),
              SizedBox(height: 20),

              // Crypto Assets List
              ...widget.cryptoWallet.assets.map((asset) => Container(
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
                        balanceManager.formatBalance(asset.usdValue),
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
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChainCard(String name, IconData icon, Color color) {
    return Card(
      color: Color(0xFF1A1A1A),
      child: InkWell(
        onTap: () {
          _showError('$name wallet coming soon!');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoActionItem(IconData icon, String label, Color color) {
    return Container(
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
    );
  }

  Widget _buildTradingTab() {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Trading Bot Status
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy, color: Color(0xFFD4AF37), size: 30),
                        const SizedBox(width: 12),
                        const Text(
                          'AI Trading Bot',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.tradingBot.isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.tradingBot.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Trading Balance', style: TextStyle(color: Colors.grey)),
                            Text(
                              balanceManager.formatCryptoBalance(widget.tradingBot.tradingBalance),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const Text('ETH', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Total Profit', style: TextStyle(color: Colors.grey)),
                            Text(
                              balanceManager.formatBalance(widget.tradingBot.totalProfit),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Success Rate', style: TextStyle(color: Colors.grey)),
                            Text(
                              '${widget.tradingBot.successRate}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'EXECUTE TRADE',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'SELL ASSETS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== E-WALLET SCREEN WITH BALANCE TOGGLE ====================

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
            icon: const Icon(Icons.history),
            onPressed: () {},
            color: const Color(0xFFD4AF37),
            tooltip: 'Transactions',
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {},
            color: const Color(0xFFD4AF37),
            tooltip: 'Activities',
          ),
        ],
      ),
      body: _eWalletSelectedIndex == 0 ? _buildWalletTab() : _buildBankingTab(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[600],
        currentIndex: _eWalletSelectedIndex,
        onTap: _onEWalletItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Banking'),
        ],
      ),
    );
  }

  void _onEWalletItemTapped(int index) {
    setState(() {
      _eWalletSelectedIndex = index;
    });
  }

  Widget _buildWalletTab() {
    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance
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
                      balanceManager.formatBalance(widget.fiatWallet.balance),
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

              // Quick Actions
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  _buildEWalletActionItem('Transfer TydChronos', Icons.send, Colors.blue),
                  _buildEWalletActionItem('Transfer Bank', Icons.account_balance, Colors.green),
                  _buildEWalletActionItem('Withdraw', Icons.arrow_upward, Colors.orange),
                  _buildEWalletActionItem('Transaction History', Icons.history, Colors.purple),
                ],
              ),
              const SizedBox(height: 20),

              // Recent Transactions
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
                        balanceManager.formatBalance(transaction.amount.abs()),
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

  Widget _buildEWalletActionItem(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildBankingTab() {
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
                _buildAccountsTab(balanceManager),
                _buildCardsTab(balanceManager),
                _buildBillsTab(balanceManager),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountsTab(BalanceVisibilityManager balanceManager) {
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
                Text(balanceManager.formatBalance(account.balance), style: const TextStyle(color: Colors.white)),
                Text(account.type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCardsTab(BalanceVisibilityManager balanceManager) {
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
                Text('Balance: ${balanceManager.formatBalance(card.balance)}', style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillsTab(BalanceVisibilityManager balanceManager) {
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
                Text(balanceManager.formatBalance(bill.amount), style: const TextStyle(color: Colors.white)),
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

          // Security Settings
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
                _buildSecurityItem('Backup Recovery Phrase', Icons.backup, false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App Settings
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
                _buildSettingsItem('Currency', 'USD', Icons.currency_exchange),
                _buildSettingsItem('Language', 'English', Icons.language),
                _buildSettingsItem('Theme', 'Dark', Icons.dark_mode),
                _buildSettingsItem('Notifications', 'On', Icons.notifications),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About
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
                  'About',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAboutItem('Version', '1.0.0', Icons.info),
                _buildAboutItem('Privacy Policy', 'View', Icons.privacy_tip),
                _buildAboutItem('Terms of Service', 'View', Icons.description),
                _buildAboutItem('Support', 'Contact', Icons.support),
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

  Widget _buildAboutItem(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(value, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {},
    );
  }
}
