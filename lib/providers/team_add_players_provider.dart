import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../global/apis.dart';
import '../../../services/shared_preference_service.dart';
import '../models/all_players_models.dart';

class TeamAddPlayersProvider extends ChangeNotifier {
  List<TeamAddPlayersModel> _players = [];
  List<TeamAddPlayersModel> _filteredPlayers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  int? _addingPlayerId;
  String? _error;

  // Getters
  List<TeamAddPlayersModel> get players => _players;
  List<TeamAddPlayersModel> get filteredPlayers => _filteredPlayers;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  int? get addingPlayerId => _addingPlayerId;
  String? get error => _error;

  // Load all players and filter out current user
  Future<void> loadPlayers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 🔑 Get token from SharedPreferences
      final token = await SharedPreferencesService.getToken();
      if (token == null) {
        throw Exception("No authentication token found");
      }

      final response = await http.get(
        Uri.parse(AppApis.eligibleUsers),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 👈 Add token here
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final allPlayers = (data['data'] as List)
            .map((player) => TeamAddPlayersModel.fromJson(player))
            .toList();

        print('data of eligible users $data');

        // Get current user data to filter out from the list
        final currentUser = await SharedPreferencesService.getUserData();

        // Filter out current user from the players list
        _players = allPlayers
            .where((player) =>
        currentUser == null || player.id != currentUser.id)
            .toList();

        _filteredPlayers = _players;
        _isLoading = false;
        _error = null;
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
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

  // Add player to team
  Future<bool> addPlayerToTeam(int playerId, String teamId, String baseUrl) async {
    try {
      _addingPlayerId = playerId;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${baseUrl}teams/${teamId}/invite-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "invitee_id": playerId,
          "message": "Hey, come join our team for the tournament!"
        }),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 && (body['success'] == true)) {
        _addingPlayerId = null;
        notifyListeners();
        return true;
      } else {
        _error = body['message'] ?? 'Failed to invite player. Please try again.';
        _addingPlayerId = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _addingPlayerId = null;
      notifyListeners();
      return false;
    }
  }

  // Refresh players list
  Future<void> refresh() async {
    await loadPlayers();
  }
}