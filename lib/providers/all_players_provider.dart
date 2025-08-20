import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/all_players_models.dart';
import '../global/apis.dart';
import '../services/shared_preference_service.dart';

class AllPlayersProvider extends ChangeNotifier {
  List<AllPlayersModel> _players = [];
  List<AllPlayersModel> _filteredPlayers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isCreatingChat = false;
  String? _error;
  String? _creatingChatWithUser;

  // Getters
  List<AllPlayersModel> get players => _players;
  List<AllPlayersModel> get filteredPlayers => _filteredPlayers;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isCreatingChat => _isCreatingChat;
  String? get error => _error;
  String? get creatingChatWithUser => _creatingChatWithUser;

  // Load all players
  Future<void> loadPlayers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(Uri.parse(AppApis.allUsers));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final allPlayers = (data['data'] as List)
            .map((player) => AllPlayersModel.fromJson(player))
            .toList();

        // Get current user data to filter out from the list
        final currentUser = await SharedPreferencesService.getUserData();

        // Filter out current user from the players list
        _players = allPlayers.where((player) =>
        currentUser == null || player.id != currentUser.id).toList();

        _filteredPlayers = _players;
        _isLoading = false;
        _error = null;
      } else {
        throw Exception('Failed to load players');
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error loading players: ${e.toString()}';
    }
    notifyListeners();
  }

  // Filter players based on search query
  void filterPlayers(String query) {
    _isSearching = query.isNotEmpty;

    if (query.isEmpty) {
      _filteredPlayers = _players;
    } else {
      _filteredPlayers = _players
          .where(
            (player) =>
        player.name.toLowerCase().contains(query.toLowerCase()) ||
            player.email.toLowerCase().contains(query.toLowerCase()) ||
            player.phone.contains(query),
      )
          .toList();
    }
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _isSearching = false;
    _filteredPlayers = _players;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> checkDirectChatRoom(int userId) async {
    try {
      _isCreatingChat = true;
      _creatingChatWithUser = userId.toString();
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${AppApis.chatBaseUrl}api/chat/rooms/direct/exist/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _isCreatingChat = false;
      _creatingChatWithUser = null;

      print('✅ Status: ${response.statusCode}');
      print('✅ Response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Return the entire data object
        if (decoded['success'] == true) {
          notifyListeners();
          return decoded['data']; // This contains 'exists' and 'room'
        } else {
          print('ℹ️ No chat room found for user $userId');
          notifyListeners();
          return null;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to check chat room');
      }
    } catch (e) {
      _isCreatingChat = false;
      _creatingChatWithUser = null;
      _error = 'Error checking chat room: ${e.toString()}';
      print(_error);
      notifyListeners();
      return null;
    }
  }

  // Refresh players list
  Future<void> refresh() async {
    await loadPlayers();
  }
}