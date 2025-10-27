import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/walletconnect_adapter.dart';
import '../components/dapp_connections_panel.dart';
import '../models/wallet_models.dart';

// Your existing OverviewScreen class with DApp connections added
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
    final walletConnect = Provider.of<WalletConnectService>(context);
    
    // Use network-adjusted balances
    double totalNetWorth = networkMode.getAdjustedBalance(
      cryptoWallet.totalValueUSD + fiatWallet.balance + (tradingBot.tradingBalance * 3000)
    );

    return BalanceConsumer(
      builder: (context, balanceManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Network Mode Indicator
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
                            '\${networkMode.currentNetwork} Mode',
                            style: TextStyle(
                              color: networkMode.isTestnetMode ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            networkMode.currentNetworkSubtitle,
                            style: const TextStyle(
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
                        'Switch to \${networkMode.isTestnetMode ? 'Mainnet' : 'Testnet'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ... ALL YOUR EXISTING OVERVIEW CONTENT REMAINS THE SAME ...

              // ETHEREUM ACCESS SECTION (YOUR EXISTING CODE)
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
                          'Ethereum Access',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (walletConnect.ethereumAddress == null) ...[
                      const Text(
                        'No Ethereum wallet found. Create one to start using DeFi features.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create New Wallet'),
                        onPressed: () {
                          // Wallet creation is handled automatically
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      // Wallet Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Ethereum Address:', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD4AF37)),
                            ),
                            child: SelectableText(
                              walletConnect.ethereumAddress!,
                              style: const TextStyle(
                                fontFamily: 'Monospace',
                                fontSize: 12,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Network Status:', style: TextStyle(color: Colors.grey)),
                              Text(
                                'Ready',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 20),

              // ========== NEW: DAPP CONNECTIONS SECTION ==========
              DAppConnectionsPanel(),
            ],
          ),
        );
      },
    );
  }

  // ... YOUR EXISTING _buildBalanceCard AND _buildMultiChainAssets METHODS ...
}
