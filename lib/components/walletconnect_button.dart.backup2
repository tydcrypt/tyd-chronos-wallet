import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/walletconnect_service_fixed.dart';

class WalletConnectButton extends StatelessWidget {
  const WalletConnectButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletConnectService>(
      builder: (context, walletConnect, child) {
        return IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: walletConnect.isConnected 
                    ? const Color(0xFFD4AF37) // Gold when connected
                    : Colors.white70,
              ),
              if (walletConnect.isConnected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () {
            if (walletConnect.isConnected) {
              _showConnectionInfo(context, walletConnect);
            } else {
              _connectToWallet(context, walletConnect);
            }
          },
          tooltip: walletConnect.isConnected 
              ? 'Connected to ${walletConnect.connectedWallet}'
              : 'Connect Wallet via Web3Modal',
        );
      },
    );
  }

  void _connectToWallet(BuildContext context, WalletConnectService walletConnect) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFD4AF37)),
              SizedBox(width: 12),
              Text('Opening wallet connection...'),
            ],
          ),
          backgroundColor: Colors.black87,
          duration: Duration(seconds: 3),
        ),
      );
      
      await walletConnect.connectToWallet();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConnectionInfo(BuildContext context, WalletConnectService walletConnect) {
    final info = walletConnect.getConnectionInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Tydchronos Wallet Connection',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected to: ${info['wallet'] ?? "Unknown Wallet"}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Address:',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SelectableText(
              info['address'] ?? 'No address',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'Monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Balance: ${info['balance']?.toStringAsFixed(4) ?? '0.0'} ETH',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Network: ${info['chain'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Connected via Web3Modal',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await walletConnect.disconnect();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disconnected from wallet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
