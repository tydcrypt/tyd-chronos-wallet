import 'package:flutter/material.dart';

class EthereumWalletScreen extends StatelessWidget {
  const EthereumWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethereum Wallet'),
      ),
      body: const Center(
        child: Text('Ethereum Wallet Screen'),
      ),
    );
  }
}