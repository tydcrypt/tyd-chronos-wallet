import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/ethereum/wallet_manager.dart';

class EthereumWalletScreen extends StatefulWidget {
  const EthereumWalletScreen({super.key});

  @override
  State<EthereumWalletScreen> createState() => _EthereumWalletScreenState();
}

class _EthereumWalletScreenState extends State<EthereumWalletScreen> {
  final EthereumWalletManager _walletManager = EthereumWalletManager();
  String? _address;
  String? _privateKey;
  String? _mnemonic;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingWallet();
  }

  Future<void> _checkExistingWallet() async {
    final exists = await _walletManager.walletExists();
    if (exists) {
      _address = await _walletManager.getCurrentAddress();
      setState(() {});
    }
  }

  Future<void> _createNewWallet() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wallet = await _walletManager.generateNewWallet();
      setState(() {
        _address = wallet['address'];
        _privateKey = wallet['privateKey'];
        _mnemonic = wallet['mnemonic'];
      });
    } catch (e) {
      _showError('Failed to create wallet: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importFromPrivateKey() async {
    final privateKey = await _showTextInputDialog('Enter Private Key');
    if (privateKey != null && privateKey.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        _address = await _walletManager.importFromPrivateKey(privateKey);
        setState(() {});
      } catch (e) {
        _showError('Invalid private key: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importFromMnemonic() async {
    final mnemonic = await _showTextInputDialog('Enter Mnemonic Phrase');
    if (mnemonic != null && mnemonic.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        _address = await _walletManager.importFromMnemonic(mnemonic);
        setState(() {});
      } catch (e) {
        _showError('Invalid mnemonic: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<String?> _showTextInputDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ethereum Wallet'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_address == null) ...[
                    _buildCreateWalletSection(),
                  ] else ...[
                    _buildWalletInfoSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCreateWalletSection() {
    return Column(
      children: [
        const Text(
          'Create or Import Ethereum Wallet',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _createNewWallet,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Create New Wallet'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _importFromPrivateKey,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            side: const BorderSide(color: Color(0xFFD4AF37)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Import from Private Key'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _importFromMnemonic,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            side: const BorderSide(color: Color(0xFFD4AF37)),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Import from Mnemonic'),
        ),
      ],
    );
  }

  Widget _buildWalletInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Ethereum Wallet',
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            'Address: ${_address!.substring(0, 10)}...${_address!.substring(_address!.length - 8)}',
            style: const TextStyle(color: Colors.white),
          ),
          if (_privateKey != null) ...[
            const SizedBox(height: 10),
            Text(
              'Private Key: ${_privateKey!.substring(0, 10)}...',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
          if (_mnemonic != null) ...[
            const SizedBox(height: 10),
            const Text(
              'Mnemonic: (safely stored)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to DeFi screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Access DeFi Protocols'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () async {
            await _walletManager.clearWallet();
            setState(() {
              _address = null;
              _privateKey = null;
              _mnemonic = null;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Clear Wallet'),
        ),
      ],
    );
  }
}
