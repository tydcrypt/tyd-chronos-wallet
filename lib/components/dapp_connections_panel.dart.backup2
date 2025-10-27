import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/walletconnect_service.dart';

class DAppConnectionsPanel extends StatelessWidget {
  const DAppConnectionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final walletConnect = Provider.of<WalletConnectService>(context);

    return Container(
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
              const Icon(Icons.apps, color: Color(0xFFD4AF37)),
              const SizedBox(width: 8),
              const Text(
                'DApp Connections',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: walletConnect.isInitialized ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  walletConnect.isInitialized ? 'READY' : 'SETUP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (!walletConnect.isInitialized)
            const Column(
              children: [
                CircularProgressIndicator(color: Color(0xFFD4AF37)),
                SizedBox(height: 12),
                Text(
                  'Initializing TydChronos Wallet...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else if (walletConnect.activeSessions.isEmpty)
            Column(
              children: [
                const Icon(Icons.link_off, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'No DApps Connected',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'DApps in the TydChronos ecosystem can connect to your wallet using WalletConnect.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showConnectionInfo(context, walletConnect);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Show Connection Info'),
                ),
              ],
            )
          else
            Column(
              children: [
                ...walletConnect.activeSessions.map((session) => _buildDAppCard(context, session)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showConnectionInfo(context, walletConnect);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Connect Another DApp'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDAppCard(BuildContext context, dynamic session) {
    // Use dynamic to avoid SessionData type issues - access properties safely
    final peer = session.peer;
    final metadata = peer.metadata;
    
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: metadata.icons.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  metadata.icons.first,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.apps, color: Colors.black),
                  ),
                ),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: Colors.black),
              ),
        title: Text(
          metadata.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          metadata.url.replaceAll('https://', '').replaceAll('http://', ''),
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link_off, color: Colors.red),
          onPressed: () {
            _showDisconnectDialog(context, session);
          },
          tooltip: 'Disconnect DApp',
        ),
      ),
    );
  }

  void _showConnectionInfo(BuildContext context, WalletConnectService walletConnect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.qr_code, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text(
              'Connect DApp',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TydChronos Wallet is ready for DApp connections.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'WALLET READY',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Project ID: ${walletConnect.getWalletInfo()['projectId']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DApps: ${walletConnect.activeSessions.length} connected',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, dynamic session) {
    final walletConnect = Provider.of<WalletConnectService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Disconnect DApp',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Text(
          'Are you sure you want to disconnect from ${session.peer.metadata.name}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              walletConnect.disconnectSession(session.topic);
              Navigator.pop(context);
            },
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
