import 'package:flutter/material.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  runApp(const UltraTest());
}

class UltraTest extends StatelessWidget {
  const UltraTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red,
          child: const Center(
            child: Text(
              'HELLO FLUTTER WEB',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
