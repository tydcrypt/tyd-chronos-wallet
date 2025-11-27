import 'package:flutter/material.dart';
import '../widgets/currency_selector.dart';
import '../services/currency_service.dart';

class EWalletScreen extends StatefulWidget {
  @override
  _EWalletScreenState createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    final currency = await CurrencyService().getSelectedCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _onCurrencyChanged(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Wallet'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          CurrencySelector(
            isCompact: true,
            onCurrencyChanged: _onCurrencyChanged,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Wallet'),
            Tab(text: 'Banking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Wallet Tab
          _buildWalletTab(),
          // Banking Tab
          _buildBankingTab(),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cryptocurrency Assets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildCryptoItem('Bitcoin', 'BTC', 0.5, 45000, Colors.orange),
                _buildCryptoItem('Ethereum', 'ETH', 3.2, 3500, Colors.blue),
                _buildCryptoItem('Cardano', 'ADA', 5000, 1.2, Colors.blue[800]!),
                _buildCryptoItem('Polkadot', 'DOT', 120, 25, Colors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banking Accounts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildBankAccountItem('Main Checking', '**** 4589', 4000.00),
                _buildBankAccountItem('Savings Account', '**** 1234', 15000.00),
                _buildBankAccountItem('Business Account', '**** 7890', 25000.00),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoItem(String name, String symbol, double amount, double price, Color color) {
    final totalValue = amount * price;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            symbol.substring(0, 2),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name),
        subtitle: Text('$amount $symbol'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyService().formatCurrency(totalValue, _selectedCurrency),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$$price',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountItem(String name, String accountNumber, double balance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: const Icon(Icons.account_balance, color: Colors.green),
        ),
        title: Text(name),
        subtitle: Text(accountNumber),
        trailing: Text(
          CurrencyService().formatCurrency(balance, _selectedCurrency),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
