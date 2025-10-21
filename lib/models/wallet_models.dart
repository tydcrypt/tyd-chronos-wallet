// Wallet data models for TydChronos Wallet

class CryptoWallet {
  String selectedNetwork = 'Ethereum';
  String selectedCurrency = 'USD';
  String walletAddress = '0x742d35Cc6634C0532925a3b8D123456';
  List<CryptoAsset> assets = [
    CryptoAsset(symbol: 'ETH', name: 'Ethereum', balance: 0.0, usdValue: 0.0, network: 'Ethereum', icon: '🟣'),
    CryptoAsset(symbol: 'BTC', name: 'Bitcoin', balance: 0.0, usdValue: 0.0, network: 'Bitcoin', icon: '🟡'),
    CryptoAsset(symbol: 'ARB', name: 'Arbitrum', balance: 0.0, usdValue: 0.0, network: 'Arbitrum', icon: '🔵'),
    CryptoAsset(symbol: 'MATIC', name: 'Polygon', balance: 0.0, usdValue: 0.0, network: 'Polygon', icon: '🟣'),
    CryptoAsset(symbol: 'OP', name: 'Optimism', balance: 0.0, usdValue: 0.0, network: 'Optimism', icon: '��'),
    CryptoAsset(symbol: 'ZK', name: 'zkSync', balance: 0.0, usdValue: 0.0, network: 'zkSync', icon: '🟢'),
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

class FiatWallet {
  double balance = 0.0;
  String selectedCurrency = 'USD';
  List<BankAccount> accounts = [
    BankAccount(name: 'Primary Checking', number: '**** 7890', balance: 0.0, type: 'Checking'),
    BankAccount(name: 'Savings Account', number: '**** 4567', balance: 0.0, type: 'Savings'),
  ];
  List<BankCard> cards = [
    BankCard(name: 'TydChronos Platinum', number: '**** 1234', expiry: '12/25', balance: 0.0),
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

class TradingBot {
  double tradingBalance = 0.0;
  bool isActive = true;
  double totalProfit = 0.0;
  double successRate = 0.0;
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
