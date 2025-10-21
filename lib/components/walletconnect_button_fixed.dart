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
          icon: Icon(
            walletConnect.isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
            color: walletConnect.isConnected ? Colors.green : const Color(0xFFD4AF37),
          ),
          onPressed: () => _showWalletConnectDialog(context, walletConnect),
          tooltip: walletConnect.isConnected 
              ? 'Connected to ${walletConnect.connectedWallet}'
              : 'Connect Wallet',
        );
      },
    );
  }

  void _showWalletConnectDialog(BuildContext context, WalletConnectService walletConnect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          walletConnect.isConnected ? 'Wallet Connected' : 'Connect Wallet',
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (walletConnect.isConnected) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 16),
              Text('Connected to: ${walletConnect.connectedWallet}', 
                   style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  walletConnect.disconnect();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Disconnect'),
              ),
            ] else ...[
              const Icon(Icons.account_balance_wallet, color: Color(0xFFD4AF37), size: 50),
              const SizedBox(height: 16),
              const Text('Connect to external wallet', 
                       style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  walletConnect.connectToWallet();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Connect Wallet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
