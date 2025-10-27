// Diagnostic script to identify the real issue
import 'package:flutter/material.dart';

void main() {
  debugPrint("🚀 Diagnostic app starting...");
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test basic Flutter functionality
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Flutter Web is Working!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('If you see this, basic Flutter works'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => debugPrint('Button pressed'),
                child: Text('Test Button'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  debugPrint("✅ Diagnostic app running");
}
