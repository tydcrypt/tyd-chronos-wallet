import 'package:flutter/material.dart';

void main() {
  print("=== BYPASSING SPLASH SCREEN ===");
  runApp(BypassApp());
}

class BypassApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tydchronos Wallet - Bypass',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: DiagnosticHome(),
    );
  }
}

class DiagnosticHome extends StatefulWidget {
  @override
  _DiagnosticHomeState createState() => _DiagnosticHomeState();
}

class _DiagnosticHomeState extends State<DiagnosticHome> {
  @override
  void initState() {
    super.initState();
    print("DiagnosticHome initialized - UI should be visible");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tydchronos Wallet - DIAGNOSTIC'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.lightGreen[50],
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 20),
                Text(
                  'APP IS WORKING!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('The issue is in your SplashScreen or navigation'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkOriginalApp,
                  child: Text('Test Original App Content'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkOriginalApp() {
    print("Testing if we can access original app components...");
  }
}
