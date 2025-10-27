import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 20),
            Text('Compilation Successful!', 
                 style: TextStyle(fontSize: 24, color: Colors.white)),
            Text('TydChronos Wallet', 
                 style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    ),
  ));
}
