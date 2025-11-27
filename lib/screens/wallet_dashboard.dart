import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ethereum_service.dart';
import '../services/price_feed_service.dart';

class WalletDashboard extends StatefulWidget {
  @override
  _WalletDashboardState createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWallet();
    });
  }

  void _initializeWallet() async {
    // Initialize wallet data - this runs after the widget is built
    final ethService = Provider.of<EthereumService>(context, listen: false);
    final priceService = Provider.of<PriceFeedService>(context, listen: false);

    try {
      // Load initial data
      await priceService.getCryptoPrices(['ethereum', 'bitcoin']);
      // Additional initialization here
      print('Wallet dashboard initialized successfully');
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Tydchronos Wallet',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Color(0xFFFFD700)),
            onPressed: () {
              // Profile action
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Color(0xFF2d1f00),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2d1f00),
                      Color(0xFF4a3c00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFFFD700).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Tydchronos!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your decentralized finance companion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Features grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Wallet',
                      color: Color(0xFFFFD700),
                    ),
                    _buildFeatureCard(
                      icon: Icons.swap_horiz,
                      title: 'Swap',
                      color: Color(0xFF00FF00),
                    ),
                    _buildFeatureCard(
                      icon: Icons.trending_up,
                      title: 'Portfolio',
                      color: Color(0xFF00BFFF),
                    ),
                    _buildFeatureCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      color: Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle feature tap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
