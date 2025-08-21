// services/notification_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/apis.dart';
import 'notification_model.dart';


class NotificationService {
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<int> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse(AppApis.unreadNotifications),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Unread Count Response: ${response.statusCode}');
        print('Unread Count Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get unread count');
      }
    } catch (e) {
      if (kDebugMode) print('Unread Count Error: $e');
      rethrow;
    }
  }

  static Future<NotificationResponse> getAllNotifications({
    int page = 1,
    int limit = 10,
    bool unreadOnly = false,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      String url = '${AppApis.getAllNotifications}?page=$page&limit=$limit';
      if (unreadOnly) {
        url += '&unread_only=true';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Get Notifications Response: ${response.statusCode}');
        print('Get Notifications Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if response is successful
        if (data['success'] == true) {
          return NotificationResponse.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get notifications');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get notifications');
      }
    } catch (e) {
      if (kDebugMode) print('Get Notifications Error: $e');
      rethrow;
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.patch(
        Uri.parse('${AppApis.readOneNotification}$notificationId/read'),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Mark as Read Response: ${response.statusCode}');
        print('Mark as Read Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark as read');
      }
    } catch (e) {
      if (kDebugMode) print('Mark as Read Error: $e');
      rethrow;
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.patch(
        Uri.parse(AppApis.readAllNotification),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Mark All as Read Response: ${response.statusCode}');
        print('Mark All as Read Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      if (kDebugMode) print('Mark All as Read Error: $e');
      rethrow;
    }
  }

  static Future<void> deleteNotification(int notificationId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${AppApis.deleteOneNotification}$notificationId'),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Delete Notification Response: ${response.statusCode}');
        print('Delete Notification Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete notification');
      }
    } catch (e) {
      if (kDebugMode) print('Delete Notification Error: $e');
      rethrow;
    }
  }

  static Future<void> deleteAllNotifications() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse(AppApis.deleteALlNotification),
        headers: _getHeaders(token),
      );

      if (kDebugMode) {
        print('Delete All Notifications Response: ${response.statusCode}');
        print('Delete All Notifications Body: ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete all notifications');
      }
    } catch (e) {
      if (kDebugMode) print('Delete All Notifications Error: $e');
      rethrow;
    }
  }
}