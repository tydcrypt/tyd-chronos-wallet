import 'package:flutter/material.dart';
import '../widgets/currency_selector.dart';
import '../services/currency_service.dart';

class OverviewScreen extends StatefulWidget {
  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String _selectedCurrency = 'USD';
  final double _totalNetWorth = 12500.00;
  final double _cryptoBalance = 8500.00;
  final double _bankingBalance = 4000.00;
  final double _tradingBalance = 2500.00;

  @override
  void initState() {
    super.initState();
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
        title: const Text('TydChronos Wallet'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          CurrencySelector(
            isCompact: true,
            onCurrencyChanged: _onCurrencyChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Net Worth Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Net Worth',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyService().formatCurrency(_totalNetWorth, _selectedCurrency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Balances Grid
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard(
                    'Crypto Balance',
                    _cryptoBalance,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBalanceCard(
                    'Banking Balance',
                    _bankingBalance,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard(
                    'Trading Balance',
                    _tradingBalance,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBalanceCard(
                    'Multi-Chain Assets',
                    3200.00,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionItem('ETH Received', '+0.5 ETH', Colors.green),
                  _buildTransactionItem('BTC Sent', '-0.1 BTC', Colors.red),
                  _buildTransactionItem('USD Deposit', '+500 USD', Colors.green),
                  _buildTransactionItem('Trading Fee', '-25 USD', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyService().formatCurrency(amount, _selectedCurrency),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String description, String amount, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            color == Colors.green ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(description),
        subtitle: const Text('2 hours ago'),
        trailing: Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
