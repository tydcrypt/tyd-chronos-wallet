import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthDashboard extends StatefulWidget {
  final VoidCallback? onAuthenticationSuccess;

  const AuthDashboard({super.key, this.onAuthenticationSuccess});

  @override
  State<AuthDashboard> createState() => _AuthDashboardState();
}

class _AuthDashboardState extends State<AuthDashboard> {
  bool _showSignIn = true;

  void _toggleAuthMode() {
    setState(() {
      _showSignIn = !_showSignIn;
    });
  }

  void _onAuthSuccess() {
    widget.onAuthenticationSuccess?.call();
  }

  BoxDecoration get _backgroundDecoration {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black,
          Color(0xFF1a1a1a),
          Colors.black,
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _backgroundDecoration,
        child: Stack(
          children: [
            // Animated gold accent background elements
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: _showSignIn ? -100 : -50,
              right: _showSignIn ? -50 : -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              bottom: _showSignIn ? -50 : -100,
              left: _showSignIn ? -100 : -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      const Color(0xFFFFD700).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: _showSignIn
                  ? SignInScreen(
                      onSignUpPressed: _toggleAuthMode,
                      onSignInSuccess: _onAuthSuccess,
                    )
                  : SignUpScreen(
                      onSignInPressed: _toggleAuthMode,
                      onSignUpSuccess: _onAuthSuccess,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
