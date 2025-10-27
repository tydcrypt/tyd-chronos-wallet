import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ethereum_service.dart';
import '../services/currency_service.dart';
import '../services/price_feed_service.dart';

class WalletDashboard extends StatefulWidget {
  @override
  _WalletDashboardState createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  void _initializeWallet() async {
    // Initialize wallet data
    final ethService = Provider.of<EthereumService>(context, listen: false);
    final priceService = Provider.of<PriceFeedService>(context, listen: false);
    
    try {
      // Load initial data
      await priceService.getCryptoPrices(['ethereum', 'bitcoin']);
      // Additional initialization here
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TydChronos Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.account_balance_wallet), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // Balance Card
            _buildBalanceCard(),
            SizedBox(height: 16),
            // Quick Actions
            _buildQuickActions(),
            SizedBox(height: 16),
            // Recent Transactions
            _buildRecentTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Send transaction
          _showSendDialog();
        },
        child: Icon(Icons.send),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 8),
            Text('\$0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('ETH', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('0.0', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('BTC', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('0.0', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('USD', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('0.0', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.download, 'Receive', Colors.blue),
        _buildActionButton(Icons.upload, 'Send', Colors.green),
        _buildActionButton(Icons.swap_horiz, 'Swap', Colors.orange),
        _buildActionButton(Icons.account_balance, 'Buy', Colors.purple),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildTransactionItem('Received ETH', '+0.1 ETH', Colors.green),
                    _buildTransactionItem('Sent BTC', '-0.05 BTC', Colors.red),
                    _buildTransactionItem('Swapped', 'ETH to USDC', Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color, child: Icon(Icons.account_balance_wallet, color: Colors.white)),
      title: Text(title),
      subtitle: Text('2 hours ago'),
      trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Wallet'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Markets'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation
      },
    );
  }

  void _showSendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Crypto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Recipient Address')),
            TextField(decoration: InputDecoration(labelText: 'Amount')),
            TextField(decoration: InputDecoration(labelText: 'Memo (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () {}, child: Text('Send')),
        ],
      ),
    );
  }
}
