import 'package:flutter/material.dart';

void main() {
  debugPrint("🧪 Test: Main.dart is working");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 20),
              Text('TydChronos Wallet Test', style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text('If you see this, main.dart works!'),
            ],
          ),
        ),
      ),
    ),
  );
}
