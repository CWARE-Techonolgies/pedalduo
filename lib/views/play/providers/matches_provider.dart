import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../global/apis.dart';
import '../models/my_matches_model.dart';

class MatchesProvider extends ChangeNotifier {
  List<MyMatchesModel> _matches = [];
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  String _error = '';
  int _selectedTabIndex = 0;

  List<MyMatchesModel> get matches => _matches;
  bool get isLoading => _isLoading;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String get error => _error;
  int get selectedTabIndex => _selectedTabIndex;

  List<MyMatchesModel> get completedMatches =>
      _matches.where((match) => match.winnerTeamId != null).toList();

  List<MyMatchesModel> get pendingMatches =>
      _matches.where((match) => match.winnerTeamId == null).toList();

  // Get upcoming matches (matches with no winner)
  List<MyMatchesModel> get upcomingMatches {
    return _matches.where((match) => match.winnerTeamId == null).toList();
  }

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchMatches() async {
    if (_hasLoadedOnce) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _error = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(AppApis.myMatches),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success']) {
          _matches =
              (jsonData['data'] as List)
                  .map((matchJson) => MyMatchesModel.fromJson(matchJson))
                  .toList();
          _hasLoadedOnce = true;
        } else {
          _error = 'Failed to load matches';
        }
      } else {
        _error = 'Failed to load matches';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshMatches() {
    _hasLoadedOnce = false;
    fetchMatches();
  }
}