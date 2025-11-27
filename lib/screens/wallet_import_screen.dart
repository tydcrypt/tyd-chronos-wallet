import 'package:flutter/material.dart';
import '../services/wallet_manager_service.dart';

class WalletImportScreen extends StatefulWidget {
  const WalletImportScreen({super.key});

  @override
  State<WalletImportScreen> createState() => _WalletImportScreenState();
}

class _WalletImportScreenState extends State<WalletImportScreen> {
  final WalletManagerService _walletManager = WalletManagerService();
  final _walletNameController = TextEditingController();
  final _mnemonicController = TextEditingController();
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _walletNameController.text = 'Imported Wallet';
  }

  Future<void> _importWallet() async {
    if (_isImporting) return;

    setState(() => _isImporting = true);

    try {
      final walletName = _walletNameController.text.trim();
      final mnemonic = _mnemonicController.text.trim();

      if (walletName.isEmpty) {
        throw Exception('Please enter a wallet name');
      }

      if (mnemonic.split(' ').length != 12) {
        throw Exception('Please enter a valid 12-word recovery phrase');
      }

      await _walletManager.importWalletFromMnemonic(walletName, mnemonic);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
        title: const Text('Import Wallet'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Import Existing Wallet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Restore your wallet using your 12-word recovery phrase',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              // Wallet Name
              const Text(
                'Wallet Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _walletNameController,
                decoration: InputDecoration(
                  hintText: 'Enter wallet name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // Mnemonic Phrase
              const Text(
                'Recovery Phrase (12 words)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mnemonicController,
                decoration: InputDecoration(
                  hintText: 'Enter your 12-word recovery phrase separated by spaces',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                textCapitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter all 12 words in the correct order, separated by spaces',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 40),
              
              // Import Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isImporting ? null : _importWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isImporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Import Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
