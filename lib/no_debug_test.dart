import 'package:flutter/material.dart';

void main() {
  // Simple direct execution - no debug dependencies
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'TydChronos Wallet - Direct Render',
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
