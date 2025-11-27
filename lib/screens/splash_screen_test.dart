import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'auth_dashboard.dart';  // Importing AuthScreen
import '../main.dart'; // Importing TydChronosHomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initialized = false;
  bool _navigationCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initialized = true;
      });

      // Wait for 3 seconds and then navigate
      await Future.delayed(const Duration(seconds: 3));

      if (mounted && !_navigationCompleted) {
        _navigationCompleted = true;
        final authService = Provider.of<AuthenticationService>(context, listen: false);
        if (false) {  // FORCE AUTH SCREEN FOR TESTING
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TydChronosHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthDashboard()),
          );
        }
      }
    } catch (e) {
      // Even if there's an error, navigate to appropriate page after delay
      if (mounted && !_navigationCompleted) {
        _navigationCompleted = true;
        await Future.delayed(const Duration(seconds: 3));
        final authService = Provider.of<AuthenticationService>(context, listen: false);
        if (false) {  // FORCE AUTH SCREEN FOR TESTING
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TydChronosHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthDashboard()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Color(0xFF1a1a1a),
              Color(0xFF2d1f00),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Tydchronos Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _initialized
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                  : const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      strokeWidth: 3,
                    ),
              const SizedBox(height: 20),
              const Text(
                'TydChronos Wallet',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Advanced Banking & Cryptocurrency Platform',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _initialized ? 'Ready! Launching app...' : 'Loading TydChronos Ecosystem...',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
