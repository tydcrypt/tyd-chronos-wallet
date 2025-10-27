import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/walletconnect_service.dart';
import '../components/dapp_connections_panel.dart';
import '../models/wallet_models.dart';  // Fixed import path

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
                            '${networkMode.currentNetwork} Mode',
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
                        'Switch to ${networkMode.isTestnetMode ? 'Mainnet' : 'Testnet'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                    child: _buildBalanceCard(
                      'Crypto', 
                      networkMode.getNetworkAdjustedBalance(cryptoWallet.totalValueUSD), 
                      Colors.orange
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceCard(
                      'Banking', 
                      networkMode.getNetworkAdjustedBalance(fiatWallet.balance), 
                      Colors.blue
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Trading', 
                      networkMode.getNetworkAdjustedBalance(tradingBot.tradingBalance * 3000), 
                      Colors.green
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(), // Empty for alignment
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Multi-Chain Assets Section
              _buildMultiChainAssets(balanceManager, networkMode),
              const SizedBox(height: 20),

              // ETHEREUM ACCESS SECTION
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

              // DAPP CONNECTIONS SECTION - NEWLY ADDED
              DAppConnectionsPanel(),
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

  Widget _buildMultiChainAssets(BalanceVisibilityManager balanceManager, NetworkModeManager networkMode) {
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
            final adjustedValue = networkMode.getAdjustedBalance(asset.usdValue);
            
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
                        adjustedValue > 0 ? '\$${adjustedValue.toStringAsFixed(2)}' : '••••••',
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
