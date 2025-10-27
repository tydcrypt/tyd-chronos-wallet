import 'package:flutter/material.dart';
import 'package:tyd_chronos_wallet_new/core/ethereum/wallet_manager.dart';
import 'package:tyd_chronos_wallet_new/presentation/screens/ethereum/ethereum_wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WalletManager _walletManager = WalletManager();
  String? _walletAddress;
  String _selectedNetwork = 'Ethereum Mainnet';
  List<String> _networks = [
    'Ethereum Mainnet',
    'Goerli Testnet', 
    'Sepolia Testnet',
    'Polygon Mainnet',
    'Arbitrum One',
    'Optimism',
    'Avalanche C-Chain',
    'zkSync Era',
  ];

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  Future<void> _loadWalletAddress() async {
    _walletAddress = await _walletManager.getWalletAddress();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRYPTO'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          // Network Selector
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton<String>(
                value: _selectedNetwork,
                dropdownColor: Colors.blueGrey[800],
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                iconSize: 16,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedNetwork = newValue;
                    });
                  }
                },
                items: _networks.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.length > 15 ? '${value.substring(0, 15)}...' : value,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Wallet Address Display
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blueGrey[600],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _walletAddress != null 
                        ? '${_walletAddress!.substring(0, 6)}...${_walletAddress!.substring(_walletAddress!.length - 4)}'
                        : 'No Wallet',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Crypto Value Card
            _buildTotalValueCard(),
            const SizedBox(height: 24),
            
            // Multi-Chain Wallets Section
            _buildMultiChainWalletsSection(),
            
            // Recent Activity Section
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValueCard() {
    return Card(
      elevation: 4,
      color: Colors.blueGrey[800],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Crypto Value',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$0.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Connected to $_selectedNetwork',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiChainWalletsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Multi-Chain Wallets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your universal wallet address works across all EVM networks',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildWalletCard(
              'Ethereum',
              Icons.account_balance_wallet,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: _selectedNetwork),
                  ),
                );
              },
            ),
            _buildWalletCard(
              'Polygon',
              Icons.polyline,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: 'Polygon Mainnet'),
                  ),
                );
              },
            ),
            _buildWalletCard(
              'zkSync Era',
              Icons.bolt,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: 'zkSync Era'),
                  ),
                );
              },
            ),
            _buildWalletCard(
              'Arbitrum',
              Icons.show_chart,
              Colors.cyan,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: 'Arbitrum One'),
                  ),
                );
              },
            ),
            _buildWalletCard(
              'Optimism',
              Icons.offline_bolt,
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: 'Optimism'),
                  ),
                );
              },
            ),
            _buildWalletCard(
              'Avalanche',
              Icons.ac_unit,
              Colors.redAccent,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EthereumWalletScreen(initialNetwork: 'Avalanche C-Chain'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletCard(String name, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      color: Colors.blueGrey[800],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No recent transactions\nConnect to a network and start using your wallet!',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
