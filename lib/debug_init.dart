import 'package:flutter/material.dart';

void main() {
  print("🎯 STEP 1: main() function STARTED");
  
  try {
    print("🎯 STEP 2: Attempting WidgetsFlutterBinding.ensureInitialized()");
    WidgetsFlutterBinding.ensureInitialized();
    print("✅ STEP 2: WidgetsFlutterBinding.ensureInitialized() SUCCESS");
  } catch (e) {
    print("❌ STEP 2: WidgetsFlutterBinding.ensureInitialized() FAILED: $e");
    return;
  }
  
  try {
    print("🎯 STEP 3: Attempting runApp()");
    runApp(MyApp());
    print("✅ STEP 3: runApp() SUCCESS");
  } catch (e) {
    print("❌ STEP 3: runApp() FAILED: $e");
    return;
  }
  
  print("✅ ALL STEPS COMPLETED SUCCESSFULLY");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("🎯 STEP 4: MyApp.build() called");
    
    // Use the simplest possible widget tree
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.black,
          child: Center(
            child: Text(
              'TydChronos Wallet',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
