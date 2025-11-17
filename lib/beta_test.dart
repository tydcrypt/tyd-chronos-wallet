import 'package:flutter/material.dart';

void main() {
  debugPrint('=== BETA CHANNEL TEST ===');
  runApp(BetaTest());
}

class BetaTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beta Channel Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Beta Web Test'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.green,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'BETA CHANNEL WORKS!',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Flutter 3.38.0 Beta - Web Support',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Button pressed - app is interactive');
                  },
                  child: Text('Test Button'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
