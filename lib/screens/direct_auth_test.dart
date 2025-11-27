import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';
import 'auth_screen.dart';

class DirectAuthTest extends StatelessWidget {
  const DirectAuthTest({super.key});

  @override
  Widget build(BuildContext context) {
    // Force logout and show AuthScreen immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      authService.logout();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37))),
            SizedBox(height: 20),
            Text('Loading AuthScreen...', style: TextStyle(color: Color(0xFFD4AF37))),
          ],
        ),
      ),
    );
  }
}
