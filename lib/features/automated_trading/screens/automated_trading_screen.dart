import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/trading_controller.dart';

class AutomatedTradingScreen extends StatelessWidget {
  const AutomatedTradingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automated Trading'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<TradingController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_motion, size: 64, color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  'Automated Trading',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Limit orders, trading signals, and risk management',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Coming Soon',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
