import 'package:flutter/material.dart';

class DAppConnectionDialog extends StatelessWidget {
  final String dappName;
  final String network;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const DAppConnectionDialog({
    Key? key,
    required this.dappName,
    required this.network,
    required this.onConfirm,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.amber, width: 2),
      ),
      title: Row(
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
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(12),
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
          SizedBox(height: 15),
          Text(
            'This will allow the DApp to:',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
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
            side: BorderSide(color: Colors.red),
          ),
          child: Text('Reject'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
          child: Text('Connect'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
