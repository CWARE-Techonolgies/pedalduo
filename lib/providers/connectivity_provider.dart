import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _isCheckingConnection = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  bool get isConnected => _isConnected;
  bool get isCheckingConnection => _isCheckingConnection;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Also check connectivity every 10 seconds for more reliability
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isCheckingConnection) {
        _checkInternetConnection();
      }
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    // If no connectivity or only contains none, set as disconnected immediately
    if (results.isEmpty || results.every((result) => result == ConnectivityResult.none)) {
      _setConnectionStatus(false);
      return;
    }

    // If we have connectivity, double-check with actual internet connectivity
    await _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    _isCheckingConnection = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      _setConnectionStatus(response.statusCode == 200);
    } catch (e) {
      debugPrint('Internet check failed: $e');
      _setConnectionStatus(false);
    } finally {
      _isCheckingConnection = false;
      notifyListeners();
    }
  }
  void _setConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      notifyListeners();
    }
  }

  Future<void> checkConnection() async {
    await _checkInternetConnection();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}