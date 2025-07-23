import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/all_players_models.dart';
import '../global/apis.dart';

class AddPlayersProvider extends ChangeNotifier {
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
        _players =
            (data['data'] as List)
                .map((player) => AllPlayersModel.fromJson(player))
                .toList();
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
      _filteredPlayers =
          _players
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

  // Create chat with user
// Update your createChatWithUser method in AddPlayersProvider:

  Future<bool> createChatWithUser(int otherUserId, String userName) async {
    try {
      _isCreatingChat = true;
      _creatingChatWithUser = userName;
      _error = null;
      notifyListeners();

      // Get auth token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare request body
      final requestBody = json.encode({'otherUserId': otherUserId});

      // Make API call
      final response = await http.post(
        Uri.parse(AppApis.directChatWithUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _isCreatingChat = false;
          _creatingChatWithUser = null;
          notifyListeners();
          return true; // Success
        } else {
          print('Failed to create chat: ${data['message'] ?? 'Unknown error'}');
          throw Exception(
            'Failed to create chat: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        print('Failed to create chat: ${response.statusCode}');
        throw Exception('Failed to create chat: ${response.statusCode}');
      }
    } catch (e) {
      _isCreatingChat = false;
      _creatingChatWithUser = null;
      _error = 'Error creating chat: ${e.toString()}';
      print('Error creating chat: ${e.toString()}');
      notifyListeners();
      return false; // Failure
    }
  }
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh players list
  Future<void> refresh() async {
    await loadPlayers();
  }
}
