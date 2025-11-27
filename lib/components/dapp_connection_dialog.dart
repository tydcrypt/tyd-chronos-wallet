import 'package:flutter/material.dart';

class DAppConnectionDialog extends StatelessWidget {
  final String dappName;
  final String network;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const DAppConnectionDialog({
    super.key,
    required this.dappName,
    required this.network,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.amber, width: 2),
      ),
      title: const Row(
        children: [
          Icon(Icons.link, color: Colors.amber),
          SizedBox(width: 10),
          Text(
            'DApp Connection Request',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dappName wants to connect to your wallet',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Network:', network),
                _buildInfoRow('Permissions:', 'View address & request signatures'),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'This will allow the DApp to:',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildPermissionItem('View your wallet address'),
          _buildPermissionItem('Request transaction signatures'),
          _buildPermissionItem('Suggest transactions for approval'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onReject,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          child: const Text('Connect'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
