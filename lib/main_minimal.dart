import 'package:flutter/material.dart';

void main() {
  runApp(const TydChronosWalletApp());
}

class TydChronosWalletApp extends StatelessWidget {
  const TydChronosWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TydChronos',
      theme: ThemeData(
        primaryColor: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFFD4AF37),
                size: 64,
              ),
              SizedBox(height: 20),
              Text(
                'TydChronos Loaded!',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 24,
                ),
              ),
              Text(
                'Loading issue identified',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
