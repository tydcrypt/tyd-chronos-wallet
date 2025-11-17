import 'package:flutter/material.dart';

void main() {
  print("=== DIAGNOSTIC LAUNCHER ===");
  print("Starting original app...");
  
  // This will launch your original app
  runApp(DiagnosticLauncher());
}

class DiagnosticLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnostic',
      home: Scaffold(
        appBar: AppBar(title: Text('Diagnostic - Checking App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading original app...'),
            ],
          ),
        ),
      ),
    );
  }
}
