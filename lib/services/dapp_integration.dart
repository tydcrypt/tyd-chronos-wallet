/// Minimal DApp integration that works with existing wallet structure
/// This file provides DApp connectivity without modifying existing functionality

import 'package:flutter/foundation.dart';

class DAppIntegration with ChangeNotifier {
  static final DAppIntegration _instance = DAppIntegration._internal();
  factory DAppIntegration() => _instance;
  DAppIntegration._internal();

  String? _connectedDApp;
  bool _hasPendingConnection = false;

  String? get connectedDApp => _connectedDApp;
  bool get hasPendingConnection => _hasPendingConnection;

  void setPendingConnection(String dappName) {
    _connectedDApp = dappName;
    _hasPendingConnection = true;
    notifyListeners();
  }

  void clearPendingConnection() {
    _hasPendingConnection = false;
    notifyListeners();
  }

  void completeConnection() {
    _hasPendingConnection = false;
    notifyListeners();
  }
}
