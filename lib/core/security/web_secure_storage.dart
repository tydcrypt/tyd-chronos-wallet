// Web-compatible secure storage for browser environment
import 'package:flutter/foundation.dart';

class WebSecureStorage {
  static final Map<String, String> _memoryStorage = {};
  
  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      // For web, use localStorage or sessionStorage
      try {
        _memoryStorage[key] = value;
        // Also try to use browser localStorage if available
        if (hasLocalStorage) {
          localStorage[key] = value;
        }
      } catch (e) {
        // Fallback to memory storage
        _memoryStorage[key] = value;
      }
    }
  }
  
  Future<String?> read(String key) async {
    if (kIsWeb) {
      try {
        // Try browser storage first
        if (hasLocalStorage && localStorage.containsKey(key)) {
          return localStorage[key];
        }
        // Fallback to memory storage
        return _memoryStorage[key];
      } catch (e) {
        return _memoryStorage[key];
      }
    }
    return null;
  }
  
  Future<void> delete(String key) async {
    if (kIsWeb) {
      _memoryStorage.remove(key);
      if (hasLocalStorage) {
        localStorage.remove(key);
      }
    }
  }
  
  bool get hasLocalStorage {
    try {
      return const bool.fromEnvironment('dart.library.js_util') &&
             const bool.hasEnvironment('dart.library.js');
    } catch (e) {
      return false;
    }
  }
  
  // Mock localStorage for web
  dynamic get localStorage {
    return _MemoryLocalStorage();
  }
}

class _MemoryLocalStorage {
  final Map<String, String> _storage = {};
  
  String? operator [](String key) => _storage[key];
  
  void operator []=(String key, String value) {
    _storage[key] = value;
  }
  
  bool containsKey(String key) => _storage.containsKey(key);
  
  void remove(String key) => _storage.remove(key);
}
