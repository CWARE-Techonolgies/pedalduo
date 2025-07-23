import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/chat/chat_room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../global/apis.dart';

class ChatRoomsProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  List<ChatRoom> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;

  List<ChatRoom> get directMessages =>
      _chatRooms.where((room) => room.type == 'direct').toList();

  List<ChatRoom> get teamChats =>
      _chatRooms.where((room) => room.type == 'team').toList();

  List<ChatRoom> get tournamentChats =>
      _chatRooms.where((room) => room.type == 'tournament').toList();

  Future<void> fetchChatRooms() async {
    if (_hasInitialized) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Retrieve the token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _error = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(AppApis.chatRooms),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _chatRooms =
              (data['data'] as List)
                  .map((room) => ChatRoom.fromJson(room))
                  .toList();
          _hasInitialized = true;
        } else {
          _error = 'Failed to load chat rooms';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('No auth token found');
      }

      final response = await http.post(
        Uri.parse('${AppApis.chatBaseUrl}api/chat/rooms/$id/read'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        print('Messages marked as read successfully.');
        refresh();
        notifyListeners();
      } else {
        print(
          'Failed to mark messages as read. Status: ${response.statusCode}',
        );
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void refresh() {
    _hasInitialized = false;
    fetchChatRooms();
  }
}
