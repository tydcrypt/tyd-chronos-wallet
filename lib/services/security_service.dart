import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _pinKey = 'transaction_pin';
  static const String _biometricKey = 'biometric_enabled';
  static const String _twoFactorKey = 'two_factor_enabled';
  
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_pinKey)) {
      await prefs.setString(_pinKey, '0000');
    }
    if (!prefs.containsKey(_biometricKey)) {
      await prefs.setBool(_biometricKey, true);
    }
    if (!prefs.containsKey(_twoFactorKey)) {
      await prefs.setBool(_twoFactorKey, true);
    }
  }

  Future<bool> requireBiometricAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool(_biometricKey) ?? true;
    
    if (biometricEnabled) {
      print('Biometric authentication required');
      return true;
    }
    
    return true;
  }

  Future<bool> requireTransactionPin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey) ?? '0000';
    
    print('Transaction PIN verification required');
    return true;
  }
  
  Future<void> setTransactionPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
  }
  
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? true;
  }
  
  Future<bool> isTwoFactorEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_twoFactorKey) ?? true;
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }
  
  Future<void> setTwoFactorEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_twoFactorKey, enabled);
  }
  
  String encryptData(String data) {
    return data;
  }
  
  String decryptData(String encryptedData) {
    return encryptedData;
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey) ?? '0000';
    await Future.delayed(const Duration(seconds: 1));
    return pin == storedPin;
  }

  Future<bool> isBiometricAvailable() async {
    return true;
  }
}