import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../global/apis.dart';
import '../helper/fcm_service.dart';
import '../models/notification_settings_model.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationSettingsModel? _settings;
  bool _isLoading = false;
  String? _error;
  bool _isEnablingNotifications = false;
  Set<String> _processingCategories = {};

  NotificationSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEnablingNotifications => _isEnablingNotifications;

  // Check if a specific category is being processed
  bool isCategoryProcessing(String category) => _processingCategories.contains(category);

  /// Fetch notification settings from server
  Future<void> fetchNotificationSettings() async {
    if (kDebugMode) {
      print('📱 Fetching notification settings...');
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      if (kDebugMode) {
        print('🔑 Making GET request to: ${AppApis.getNotificationPreferences}');
      }
      final response = await http.get(
        Uri.parse(AppApis.getNotificationPreferences),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _settings = NotificationSettingsModel.fromJson(data['data']);
        if (kDebugMode) {
          print('✅ Settings loaded successfully');
          print('📊 Push enabled: ${_settings?.pushEnabled}');
        }

      } else {
        throw Exception('Failed to load notification settings: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching settings: $e');
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register FCM token with server - can be called from anywhere
  Future<bool> registerFCMToken() async {
    if (kDebugMode) {
      print('🚀 Starting FCM token registration...');
    }

    try {

      // Get FCM token
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();

      if (fcmToken == null) {
        if (kDebugMode) {
          print('❌ Failed to get FCM token');
        }
        throw Exception('Failed to get FCM token');
      }

      if (kDebugMode) {
        print('🔑 FCM Token obtained: ${fcmToken.substring(0, 20)}...');
      }

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      if (kDebugMode) {
        print('📱 Device info: $deviceInfo');
      }

      // Register FCM token
      await _registerFCMToken(fcmToken, deviceInfo);

      if (kDebugMode) {
        print('✅ FCM token registered successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registering FCM token: $e');
      }
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Enable push notifications (UI flow)
  Future<void> enablePushNotifications() async {
    if (kDebugMode) {
      print('🔔 Enabling push notifications...');
    }
    _isEnablingNotifications = true;
    _error = null;
    notifyListeners();

    try {
      // Register FCM token
      bool success = await registerFCMToken();

      if (!success) {
        throw Exception('Failed to register FCM token');
      }

      // Update local settings to show push as enabled immediately
      if (_settings != null) {
        _settings = _settings!.copyWith(pushEnabled: true);
        notifyListeners();
      }

      // Refresh settings to get updated status from server
      await fetchNotificationSettings();

      if (kDebugMode) {
        print('✅ Push notifications enabled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enabling push notifications: $e');
      }
      _error = e.toString();
      // Revert local change if error occurred
      if (_settings != null) {
        _settings = _settings!.copyWith(pushEnabled: false);
        notifyListeners();
      }
    } finally {
      _isEnablingNotifications = false;
      notifyListeners();
    }
  }

  /// Update notification setting (toggle push/email for specific category)
  Future<void> updateNotificationSetting(
      String category,
      String type, // 'push' or 'email'
      bool value,
      ) async {
    if (_settings == null) return;

    if (kDebugMode) {
      print('🔄 Updating $category -> $type to $value');
    }

    // Add to processing set
    _processingCategories.add(category);

    // Update local setting immediately for responsive UI
    _updateLocalSetting(category, type, value);
    notifyListeners();

    try {
      // Call update API
      await _updateNotificationPreferences();
      if (kDebugMode) {
        print('✅ Successfully updated $category -> $type to $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating $category -> $type: $e');
      }
      // Revert local change if API call failed
      _updateLocalSetting(category, type, !value);
      _error = 'Failed to update notification setting: ${e.toString()}';
    } finally {
      // Remove from processing set
      _processingCategories.remove(category);
      notifyListeners();
    }
  }

  Future<void> _updateNotificationPreferences() async {
    if (_settings == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final requestBody = {
      'push_enabled': _settings!.pushEnabled,
      'tournament_updates': _settings!.tournamentUpdates,
      'match_notifications': _settings!.matchNotifications,
      'team_updates': _settings!.teamUpdates,
      'payment_confirmations': _settings!.paymentConfirmations,
      'general_announcements': _settings!.generalAnnouncements,
      'chat_messages': _settings!.chatMessages,
      'marketing_updates': _settings!.marketingUpdates,
    };

    if (kDebugMode) {
      print('📤 Sending PUT request to update preferences');
      print('📤 Request body: ${json.encode(requestBody)}');
    }


    final response = await http.put(
      Uri.parse(AppApis.updateNotificationPreferences),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (kDebugMode) {
      print('📥 Update response status: ${response.statusCode}');
      print('📥 Update response body: ${response.body}');
    }


    if (response.statusCode != 200) {
      throw Exception('Failed to update notification preferences: ${response.statusCode}');
    }
  }

  /// Logout FCM - call this when user logs out
  Future<void> logoutFCM() async {
    if (kDebugMode) {
      print('🚪 Logging out FCM...');
    }

    try {
      final deviceInfo = await _getDeviceInfo();
      final deviceId = deviceInfo['deviceId'];

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (kDebugMode) {
          print('⚠️ No auth token found for FCM logout');
        }
        return;
      }

      if (kDebugMode) {
        print('📤 Sending FCM logout request for device: $deviceId');
      }

      final response = await http.post(
        Uri.parse(AppApis.logoutFCM), // You need to add this to your AppApis
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'device_id': deviceId,
        }),
      );

      if (kDebugMode) {
        print('📥 FCM logout response status: ${response.statusCode}');
        print('📥 FCM logout response body: ${response.body}');
      }


      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ FCM logout successful');
        }

        // Clear local notification settings
        _settings = null;
        _error = null;
        notifyListeners();

        // Unsubscribe from all FCM topics
        final messaging = FirebaseMessaging.instance;
        await messaging.deleteToken();
        if (kDebugMode) {
          print('🗑️ FCM token deleted locally');
        }

      } else {
        if (kDebugMode) {
          print('❌ FCM logout failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during FCM logout: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceType': 'android',
        'deviceId': 'android_${androidInfo.id}_${DateTime.now().millisecondsSinceEpoch}',
        'browser': null,
        'os': 'Android ${androidInfo.version.release}',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceType': 'ios',
        'deviceId': 'ios_${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}',
        'browser': null,
        'os': 'iOS ${iosInfo.systemVersion}',
      };
    } else {
      // For web or other platforms
      return {
        'deviceType': 'web',
        'deviceId': 'web_${DateTime.now().millisecondsSinceEpoch}',
        'browser': 'Unknown',
        'os': 'Unknown',
      };
    }
  }

  Future<void> _registerFCMToken(
      String fcmToken,
      Map<String, dynamic> deviceInfo,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final requestBody = {
      'token': fcmToken,
      'deviceType': deviceInfo['deviceType'],
      'deviceId': deviceInfo['deviceId'],
      'browser': deviceInfo['browser'],
      'os': deviceInfo['os'],
    };

    if (kDebugMode) {
      print('📤 Registering FCM token with server');
      print('📤 Request body: ${json.encode(requestBody)}');
    }


    final response = await http.post(
      Uri.parse(AppApis.registerFCM),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (kDebugMode) {
      print('📥 FCM registration response status: ${response.statusCode}');
      print('📥 FCM registration response body: ${response.body}');
    }


    if (response.statusCode != 200) {
      throw Exception('Failed to register FCM token: ${response.statusCode}');
    }
  }

  void _updateLocalSetting(String category, String type, bool value) {
    if (_settings == null) return;

    if (kDebugMode) {
      print('🔄 Updating local setting: $category -> $type = $value');
    }

    switch (category) {
      case 'tournament_updates':
        _settings!.tournamentUpdates[type] = value;
        break;
      case 'match_notifications':
        _settings!.matchNotifications[type] = value;
        break;
      case 'team_updates':
        _settings!.teamUpdates[type] = value;
        break;
      case 'payment_confirmations':
        _settings!.paymentConfirmations[type] = value;
        break;
      case 'chat_messages':
        _settings!.chatMessages[type] = value;
        break;
      case 'general_announcements':
        _settings!.generalAnnouncements[type] = value;
        break;
      case 'marketing_updates':
        _settings!.marketingUpdates[type] = value;
        break;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}