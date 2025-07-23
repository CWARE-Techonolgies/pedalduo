import 'package:flutter/material.dart';

import '../../../services/team_services.dart';
import '../models/team_model.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService();

  List<TeamModel> _captainTeams = [];
  List<TeamModel> _playerTeams = [];
  bool _isLoading = false;
  String? _error;

  List<TeamModel> get captainTeams => _captainTeams;
  List<TeamModel> get playerTeams => _playerTeams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TeamModel> get allTeams => [..._captainTeams, ..._playerTeams];
  bool get hasTeams => _captainTeams.isNotEmpty || _playerTeams.isNotEmpty;

  Future<void> fetchTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final teamsResponse = await _teamService.getTeams();
      _captainTeams = teamsResponse.captainTeams;
      _playerTeams = teamsResponse.playerTeams;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _captainTeams = [];
      _playerTeams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearTeams() {
    _captainTeams = [];
    _playerTeams = [];
    _error = null;
    notifyListeners();
  }
}