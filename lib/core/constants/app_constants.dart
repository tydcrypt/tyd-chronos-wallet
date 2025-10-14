class AppConstants {
  static const String appName = 'TydChronos Wallet';
  static const String appVersion = '1.0.0';
  
  // Supported Networks
  static const List<String> supportedNetworks = [
    'ethereum',
    'bitcoin',
    'arbitrum',
    'polygon',
    'optimism',
    'zksync',
  ];
  
  // Banking Constants
  static const List<String> accountTypes = [
    'checking',
    'savings',
    'investment',
  ];
  
  // Security Settings
  static const int autoLockDuration = 300; // 5 minutes
  static const int maxLoginAttempts = 5;
}

class RouteConstants {
  static const String dashboard = '/';
  static const String banking = '/banking';
  static const String crypto = '/crypto';
  static const String trading = '/trading';
  static const String security = '/security';
  static const String settings = '/settings';
}