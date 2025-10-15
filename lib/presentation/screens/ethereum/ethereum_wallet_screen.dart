import 'package:flutter/material.dart';
import 'package:tyd_chronos_wallet_new/core/ethereum/wallet_manager.dart';
import 'package:tyd_chronos_wallet_new/core/utils/format_utils.dart';

class EthereumWalletScreen extends StatefulWidget {
  final String? initialNetwork;

  const EthereumWalletScreen({Key? key, this.initialNetwork}) : super(key: key);

  @override
  _EthereumWalletScreenState createState() => _EthereumWalletScreenState();
}

class _EthereumWalletScreenState extends State<EthereumWalletScreen> {
  final WalletManager _walletManager = WalletManager();
  String? _ethAddress;
  double _ethBalance = 0.0;
  bool _isLoading = true;
  String _selectedNetwork = 'Ethereum Mainnet';
  List<String> _availableNetworks = [
    'Ethereum Mainnet',
    'Goerli Testnet',
    'Sepolia Testnet',
    'Polygon Mainnet',
    'Polygon Mumbai',
    'Arbitrum One',
    'Optimism',
    'Avalanche C-Chain',
    'zkSync Era',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialNetwork != null) {
      _selectedNetwork = widget.initialNetwork!;
    }
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      _ethAddress = await _walletManager.getWalletAddress();
      _ethBalance = await _walletManager.getBalance(_selectedNetwork);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading wallet data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _switchNetwork(String network) async {
    setState(() {
      _isLoading = true;
      _selectedNetwork = network;
    });
    _ethBalance = await _walletManager.getBalance(network);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethereum Wallet'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: _selectedNetwork,
              dropdownColor: Colors.blueGrey[800],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _switchNetwork(newValue);
                }
              },
              items: _availableNetworks.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Network Info Card
                  _buildNetworkInfoCard(),
                  const SizedBox(height: 24),
                  
                  // Balance Card
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  
                  // Wallet Address
                  _buildWalletAddressSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildNetworkInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Connected Network',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedNetwork,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This wallet will interact with the selected network. '
              'Switch networks to access different blockchain environments.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    bool isTestnet = _selectedNetwork.toLowerCase().contains('testnet') || 
                    _selectedNetwork.toLowerCase().contains('mumbai');
    
    return Card(
      elevation: 4,
      color: isTestnet ? Colors.orange[800] : Colors.blueGrey[800],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              '$_selectedNetwork Balance',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              FormatUtils.formatCurrency(_ethBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_ethBalance.toStringAsFixed(6)} ETH',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (isTestnet) ...[
              const SizedBox(height: 8),
              const Text(
                'TESTNET - Use faucet to get test ETH',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        _buildActionButton(Icons.send, 'Send', Colors.blue, () {}),
        _buildActionButton(Icons.call_received, 'Receive', Colors.green, () {}),
        _buildActionButton(Icons.swap_horiz, 'Swap', Colors.orange, () {}),
        _buildActionButton(Icons.shopping_cart, 'Buy', Colors.purple, () {}),
        _buildActionButton(Icons.attach_money, 'Sell', Colors.red, () {}),
        _buildActionButton(Icons.stacked_line_chart, 'Stake', Colors.teal, () {}),
        _buildActionButton(Icons.bridge, 'Bridge', Colors.indigo, () {}),
        _buildActionButton(Icons.auto_awesome, 'AI Trade', Colors.amber, () {}),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletAddressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Address',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _ethAddress ?? 'No address generated',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: _ethAddress != null 
                      ? () {
                          // Implement copy to clipboard
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This address works across all EVM-compatible networks. '
              'Your balance may vary between networks.',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
