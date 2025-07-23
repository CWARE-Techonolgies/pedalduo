import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../global/apis.dart';

class ServerHealthProvider extends ChangeNotifier {
  bool _isServerHealthy = true;
  bool _isCheckingHealth = false;
  Timer? _healthCheckTimer;
  Map<String, dynamic>? _lastHealthData;

  bool get isServerHealthy => _isServerHealthy;
  bool get isCheckingHealth => _isCheckingHealth;
  Map<String, dynamic>? get lastHealthData => _lastHealthData;

  // Replace with your actual health endpoint
  static const String _healthEndpoint = AppApis.baseUrl;

  ServerHealthProvider() {
    // Start periodic health checks when provider is created
    _startPeriodicHealthCheck();
  }

  void _startPeriodicHealthCheck() {
    // Check health every 30 seconds
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isCheckingHealth) {
        _checkServerHealthSilently();
      }
    });
  }

  /// Check server health and update status
  Future<void> checkServerHealth() async {
    _isCheckingHealth = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_healthEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _lastHealthData = data;

        // Check if the service is healthy based on your API response structure
        final isHealthy = _parseHealthStatus(data);
        _setServerHealthStatus(isHealthy);
      } else {
        debugPrint('Health check failed with status: ${response.statusCode}');
        _setServerHealthStatus(false);
      }
    } catch (e) {
      debugPrint('Health check error: $e');
      _setServerHealthStatus(false);
    } finally {
      _isCheckingHealth = false;
      notifyListeners();
    }
  }

  /// Silent health check (without showing loading state)
  Future<void> _checkServerHealthSilently() async {
    try {
      final response = await http.get(
        Uri.parse(_healthEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _lastHealthData = data;

        final isHealthy = _parseHealthStatus(data);
        _setServerHealthStatus(isHealthy);
      } else {
        _setServerHealthStatus(false);
      }
    } catch (e) {
      debugPrint('Silent health check error: $e');
      _setServerHealthStatus(false);
    }
  }

  /// Parse the health status from your API response
  bool _parseHealthStatus(Map<String, dynamic> data) {
    try {
      // Based on your API response structure
      final String status = data['status'] ?? 'unhealthy';
      final Map<String, dynamic> summary = data['summary'] ?? {};
      final int unhealthyCount = summary['unhealthy'] ?? 1;

      // Server is healthy if status is 'healthy' and no unhealthy components
      return status == 'healthy' && unhealthyCount == 0;
    } catch (e) {
      debugPrint('Error parsing health status: $e');
      return false;
    }
  }

  void _setServerHealthStatus(bool isHealthy) {
    if (_isServerHealthy != isHealthy) {
      _isServerHealthy = isHealthy;
      notifyListeners();
    }
  }

  /// Get detailed health information for debugging
  String getHealthSummary() {
    if (_lastHealthData == null) return 'No health data available';

    try {
      final summary = _lastHealthData!['summary'] ?? {};
      final total = summary['total'] ?? 0;
      final healthy = summary['healthy'] ?? 0;
      final unhealthy = summary['unhealthy'] ?? 0;

      return 'Services: $healthy/$total healthy, $unhealthy unhealthy';
    } catch (e) {
      return 'Error reading health data';
    }
  }

  /// Get backend status
  String getBackendStatus() {
    if (_lastHealthData == null) return 'Unknown';

    try {
      final backend = _lastHealthData!['components']?['backend'];
      return backend?['status'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get database status
  String getDatabaseStatus() {
    if (_lastHealthData == null) return 'Unknown';

    try {
      final database = _lastHealthData!['components']?['backend']?['database'];
      return database?['status'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get chat service status
  String getChatServiceStatus() {
    if (_lastHealthData == null) return 'Unknown';

    try {
      final chatService = _lastHealthData!['components']?['chatService'];
      return chatService?['status'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }
}