import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
  Set<String> _processingTopics = {}; // Track which topics are being processed

  NotificationSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEnablingNotifications => _isEnablingNotifications;

  // Check if a specific topic is being processed
  bool isTopicProcessing(String topic) => _processingTopics.contains(topic);

  Future<void> fetchNotificationSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(AppApis.getNotificationPreferences),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _settings = NotificationSettingsModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load notification settings');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enablePushNotifications() async {
    _isEnablingNotifications = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize FCM service
      await FCMService().initialize();

      // Request permission
      final messaging = FirebaseMessaging.instance;
      NotificationSettings permission = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (permission.authorizationStatus != AuthorizationStatus.authorized) {
        throw Exception('Notification permission denied');
      }

      // Get FCM token
      final fcmToken = await messaging.getToken();
      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      // Get device info
      final deviceInfo = await _getDeviceInfo();

      // Register FCM token
      await _registerFCMToken(fcmToken, deviceInfo);

      // Update local settings to show push as enabled immediately
      if (_settings != null) {
        _settings = _settings!.copyWith(pushEnabled: true);
        notifyListeners();
      }

      // Refresh settings to get updated status from server
      await fetchNotificationSettings();
    } catch (e) {
      _error = e.toString();
      // Revert local change if error occurred
      if (_settings != null) {
        _settings = _settings!.copyWith(pushEnabled: true);
        notifyListeners();
      }
    } finally {
      _isEnablingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> updateNotificationSetting(
    String category,
    String type,
    bool value,
  ) async {
    if (_settings == null) return;

    // Create topic name based on category
    final topicName = _getTopicName(category);

    // Add to processing set
    _processingTopics.add(topicName);

    // Update local setting immediately for responsive UI
    _updateLocalSetting(category, type, value);
    notifyListeners();

    try {
      if (value) {
        // Subscribe to topic
        await subscribeToTopic(topicName);
      } else {
        // Unsubscribe from topic
        await unsubscribeFromTopic(topicName);
      }
    } catch (e) {
      // Revert local change if API call failed
      _updateLocalSetting(category, type, !value);
      _error = 'Failed to update notification setting: ${e.toString()}';
    } finally {
      // Remove from processing set
      _processingTopics.remove(topicName);
      notifyListeners();
    }
  }

  String _getTopicName(String category) {
    // Map category to topic name - adjust these based on your backend topic naming
    switch (category) {
      case 'tournament_updates':
        return 'tournament_updates';
      case 'match_notifications':
        return 'match_notifications';
      case 'team_updates':
        return 'team_updates';
      case 'payment_confirmations':
        return 'payment_confirmations';
      case 'chat_messages':
        return 'chat_messages';
      case 'general_announcements':
        return 'general_announcements';
      case 'marketing_updates':
        return 'marketing_updates';
      default:
        return category;
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'deviceType': 'android',
        'deviceId':
            'android_${androidInfo.id}_${DateTime.now().millisecondsSinceEpoch}',
        'browser': null,
        'os': 'Android ${androidInfo.version.release}',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'deviceType': 'ios',
        'deviceId':
            'ios_${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}',
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

    final response = await http.post(
      Uri.parse(AppApis.registerFCM),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'token': fcmToken,
        'deviceType': deviceInfo['deviceType'],
        'deviceId': deviceInfo['deviceId'],
        'browser': deviceInfo['browser'],
        'os': deviceInfo['os'],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register FCM token');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(AppApis.subscribeToFCM),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'topics': [topic],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe to topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(AppApis.unsubscribeToFCM),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'topics': [topic],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unsubscribe from topic');
    }
  }

  void _updateLocalSetting(String category, String type, bool value) {
    if (_settings == null) return;

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
