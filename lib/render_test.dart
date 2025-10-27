import 'package:flutter/material.dart';

void main() {
  print("🚀 [DEBUG] main() function STARTED");
  
  // Ensure Flutter binding is initialized FIRST
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ [DEBUG] WidgetsFlutterBinding.ensureInitialized() completed");
  
  runApp(MyApp());
  print("✅ [DEBUG] runApp() completed");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("✅ [DEBUG] MyApp.build() called");
    return MaterialApp(
      title: 'TydChronos Render Test',
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('TydChronos Wallet', style: TextStyle(color: Color(0xFFD4AF37))),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet, size: 50, color: Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                'TydChronos Wallet',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Rendering Successfully!',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('🎯 Button pressed! UI is interactive.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
                child: Text('Test Interaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
