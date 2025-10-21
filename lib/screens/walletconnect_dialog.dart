import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/walletconnect_service.dart';

class WalletConnectDialog extends StatefulWidget {
  final WalletConnectService walletConnect;

  const WalletConnectDialog({super.key, required this.walletConnect});

  @override
  State<WalletConnectDialog> createState() => _WalletConnectDialogState();
}

class _WalletConnectDialogState extends State<WalletConnectDialog> {
  final TextEditingController _dappUrlController = TextEditingController();
  bool _isConnecting = false;
  String? _connectionUri;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      title: const Text(
        'Connect to DApp',
        style: TextStyle(color: Color(0xFFD4AF37)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_connectionUri == null) ...[
            const Text(
              'Enter DApp URL to connect using WalletConnect',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dappUrlController,
              decoration: const InputDecoration(
                labelText: 'DApp URL',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular DApps:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildDAppChip('Uniswap', 'https://app.uniswap.org'),
                _buildDAppChip('OpenSea', 'https://opensea.io'),
                _buildDAppChip('Aave', 'https://app.aave.com'),
                _buildDAppChip('Compound', 'https://app.compound.finance'),
              ],
            ),
          ] else ...[
            const Text(
              'Scan QR Code with your mobile wallet',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _connectionUri!,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or copy this URI:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _connectionUri!.substring(0, 50) + '...',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontFamily: 'Monospace',
              ),
            ),
          ],
          if (_isConnecting) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37))),
            const SizedBox(height: 8),
            const Text(
              'Waiting for connection...',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (_connectionUri == null) ...[
          TextButton(
            onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _isConnecting ? null : _connectToDApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: const Text(
              'Connect',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              setState(() {
                _connectionUri = null;
                _isConnecting = false;
              });
            },
            child: const Text('Back', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ],
    );
  }

  Widget _buildDAppChip(String name, String url) {
    return ActionChip(
      label: Text(name, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      onPressed: () {
        _dappUrlController.text = url;
      },
    );
  }

  Future<void> _connectToDApp() async {
    final dappUrl = _dappUrlController.text.trim();
    if (dappUrl.isEmpty) {
      _showError('Please enter a DApp URL');
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      // This will trigger the WalletConnect connection process
      // For demo, we'll simulate the connection URI
      await widget.walletConnect.connectToDApp(dappUrl);
      
      // Simulate generating connection URI (in real app, this comes from WC)
      setState(() {
        _connectionUri = 'wc:${DateTime.now().millisecondsSinceEpoch}@1?bridge=https://bridge.walletconnect.org&key=demo_key';
        _isConnecting = false;
      });
      
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      _showError('Failed to connect: $e');
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _dappUrlController.dispose();
    super.dispose();
  }
}
