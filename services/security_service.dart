// Security Service
// Handles encryption, authentication, and security features

import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class SecurityService {
  late Encrypter _encrypter;
  
  SecurityService(String encryptionKey) {
    final key = Key.fromUtf8(encryptionKey.padRight(32));
    _encrypter = Encrypter(AES(key));
  }
  
  String encryptData(String data) {
    final iv = IV.fromLength(16);
    final encrypted = _encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }
  
  String decryptData(String encryptedData) {
    final iv = IV.fromLength(16);
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: iv);
  }
  
  bool validatePassword(String password) {
    // Basic password validation
    return password.length >= 8 &&
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }
}
