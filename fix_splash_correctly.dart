// This shows the correct code structure for SplashScreen
// The key part is the navigation logic in _initializeApp method:

Future<void> _initializeApp() async {
  try {
    print('🔄 Starting app initialization...');

    // Initialize network mode manager
    final networkMode = Provider.of<NetworkModeManager>(context, listen: false);
    await networkMode.fetchLivePrices();

    setState(() {
      _initialized = true;
    });

    print('✅ App initialization completed, waiting 3 seconds...');

    // Wait for 3 seconds and then navigate
    await Future.delayed(const Duration(seconds: 3));

    if (mounted && !_navigationCompleted) {
      _navigationCompleted = true;
      
      // Check authentication status and navigate accordingly
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      if (authService.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TydChronosHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    } else {
      print('⚠️ Navigation skipped: mounted=$mounted, navigationCompleted=$_navigationCompleted');
    }
  } catch (e) {
    print('❌ Error during splash screen initialization: $e');
    // Even if there's an error, navigate to appropriate page after delay
    if (mounted && !_navigationCompleted) {
      _navigationCompleted = true;
      await Future.delayed(const Duration(seconds: 3));
      final authService = Provider.of<AuthenticationService>(context, listen: false);
      if (authService.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TydChronosHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }
}
