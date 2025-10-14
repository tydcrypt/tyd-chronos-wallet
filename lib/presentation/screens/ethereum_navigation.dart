import 'package:flutter/material.dart';
import 'ethereum/ethereum_wallet_screen.dart';

class EthereumNavigationScreen extends StatefulWidget {
  const EthereumNavigationScreen({super.key});

  @override
  State<EthereumNavigationScreen> createState() => _EthereumNavigationScreenState();
}

class _EthereumNavigationScreenState extends State<EthereumNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const EthereumWalletScreen(), // Ethereum Wallet
    const Placeholder(), // DeFi Protocols (to be implemented)
    const Placeholder(), // NFT Gallery (to be implemented)
    const Placeholder(), // Transaction History (to be implemented)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ethereum DeFi Wallet'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'DeFi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'NFTs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
