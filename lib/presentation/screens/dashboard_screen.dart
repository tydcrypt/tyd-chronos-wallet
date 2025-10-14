import 'package:flutter/material.dart';
// Remove unused import: 'package:tyd_chronos_wallet/core/constants/app_constants.dart'

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: const Center(
        child: Text(
          'Dashboard Screen - Under Development',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
