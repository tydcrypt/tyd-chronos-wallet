import 'package:flutter/material.dart';

class ProgressiveLoader extends StatefulWidget {
  @override
  _ProgressiveLoaderState createState() => _ProgressiveLoaderState();
}

class _ProgressiveLoaderState extends State<ProgressiveLoader> {
  final Map<String, bool> _componentStatus = {
    'Basic UI': false,
    'WalletConnect': false,
    'Providers': false,
    'Assets': false,
    'Final Setup': false,
  };

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    // Simulate the actual loading sequence
    await Future.delayed(Duration(milliseconds: 100));
    setState(() => _componentStatus['Basic UI'] = true);
    
    await Future.delayed(Duration(milliseconds: 200));
    setState(() => _componentStatus['Providers'] = true);
    
    await Future.delayed(Duration(milliseconds: 150));
    setState(() => _componentStatus['Assets'] = true);
    
    await Future.delayed(Duration(milliseconds: 100));
    setState(() => _componentStatus['Final Setup'] = true);
    
    // WalletConnect takes longest - show progress
    await Future.delayed(Duration(milliseconds: 500));
    setState(() => _componentStatus['WalletConnect'] = true);
  }

  @override
  Widget build(BuildContext context) {
    final loadedCount = _componentStatus.values.where((status) => status).length;
    final totalCount = _componentStatus.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            FlutterLogo(size: 80),
            SizedBox(height: 30),
            
            // Progress indicator
            CircularProgressIndicator(),
            SizedBox(height: 20),
            
            // Loading text
            Text(
              'Loading Chronos Wallet...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            
            // Progress percentage
            Text(
              '${((loadedCount / totalCount) * 100).round()}%',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            
            // Component status list
            ..._componentStatus.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.hourglass_empty,
                      color: entry.value ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: entry.value ? Colors.green : Colors.grey,
                        fontWeight: entry.value ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )
            ).toList(),
          ],
        ),
      ),
    );
  }
}
