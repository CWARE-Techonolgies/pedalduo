import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../enums/scoring_states.dart';
import '../models/scoring_system_model.dart';
import '../services/tennis_api_service.dart';

class TennisScoringProvider extends ChangeNotifier {
  // State
  TennisScoringState _state = TennisScoringState.initial;
  TennisMatch? _match;
  TennisScore? _tennisScore;
  String? _error;
  String? _winner;
  String? _updatingTeam;

  // No-show states
  bool _team1NoShow = false;
  bool _team2NoShow = false;
  bool _bothNoShow = false;

  // Getters
  TennisScoringState get state => _state;
  TennisMatch? get match => _match;
  String? get updatingTeam => _updatingTeam;
  TennisScore? get tennisScore => _tennisScore;
  String? get error => _error;
  String? get winner => _winner;
  bool get team1NoShow => _team1NoShow;
  bool get team2NoShow => _team2NoShow;
  bool get bothNoShow => _bothNoShow;

  bool get isLoading => _state == TennisScoringState.loading;
  bool get isUpdating => _state == TennisScoringState.updating;
  bool get isError => _state == TennisScoringState.error;
  bool get isMatchCompleted => _state == TennisScoringState.matchCompleted;
  bool get hasData => _match != null && _tennisScore != null;
  bool isTeamUpdating(String team) =>
      _state == TennisScoringState.updating && _updatingTeam == team;

  // Load tennis score
  Future<void> loadTennisScore(int matchId) async {
    try {
      _setState(TennisScoringState.loading);
      _error = null;

      final response = await TennisApiService.getTennisScore(matchId);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        _match = TennisMatch.fromJson(data['match']);
        _tennisScore = TennisScore.fromJson(data['tennis_score']);
        print('score of the match $response');
        // Check if match is already completed
        if (_match?.status == 'Completed') {
          _setState(TennisScoringState.matchCompleted);
        } else {
          _setState(TennisScoringState.loaded);
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      _error = e.toString();
      _setState(TennisScoringState.error);
    }
  }

  // Updated logic for full matches requiring 2 sets
  Future<void> addPoint(String team) async {
    // Guard against multiple rapid calls
    if (_state == TennisScoringState.updating || _match == null) {
      if (kDebugMode) {
        print('⚠️ AddPoint ignored - already updating or no match');
      }
      return;
    }

    // For full matches, check if we should even allow more points
    if (_match!.matchType == 'full_match' && _tennisScore != null) {
      // Check if someone already has 2+
      if (_tennisScore!.sets.team1 >= 2 || _tennisScore!.sets.team2 >= 2) {
        if (kDebugMode) {
          print(
            '🚨 Full match already completed - preventing additional points',
          );
          print(
            'Sets: Team1=${_tennisScore!.sets.team1}, Team2=${_tennisScore!.sets.team2}',
          );
        }
        _winner = _tennisScore!.sets.team1 >= 2 ? 'team1' : 'team2';
        _setState(TennisScoringState.matchCompleted);
        return;
      }
    }

    try {
      _updatingTeam = team;
      _setState(TennisScoringState.updating);
      HapticFeedback.lightImpact();

      if (kDebugMode) {
        print('\n=== 🎾 ADDING POINT FOR $team ===');
        print('Match Type: ${_match!.matchType}');
        if (_tennisScore != null) {
          print(
            'Before: Sets T1=${_tennisScore!.sets.team1}, T2=${_tennisScore!.sets.team2}',
          );
          print(
            'Before: Games T1=${_tennisScore!.games.team1}, T2=${_tennisScore!.games.team2}',
          );
          print('Sets History Count: ${_tennisScore!.setsHistory.length}');
        }
      }

      final response = await TennisApiService.updateTennisScore(
        tournamentId: _match!.tournamentId,
        matchId: _match!.id,
        teamWhoScored: team,
      );

      _updatingTeam = null;

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Update match data
        if (data['match'] != null) {
          final matchData = data['match'];

          if (matchData.containsKey('team1') &&
              matchData.containsKey('team2')) {
            final updatedMatch = TennisMatch.fromJson(matchData);

            // For full matches, override server completion logic
            String actualStatus = updatedMatch.status;
            if (_match!.matchType == 'full_match') {
              // Force status based on our 2-set rule
              actualStatus = 'Ongoing'; // We'll determine completion ourselves
            }

            _match = TennisMatch(
              id: updatedMatch.id,
              tournamentId: updatedMatch.tournamentId,
              roundName: updatedMatch.roundName,
              matchNumber: updatedMatch.matchNumber,
              matchType: updatedMatch.matchType,
              team1:
                  updatedMatch.team1.name != 'Unknown Team'
                      ? updatedMatch.team1
                      : _match!.team1,
              team2:
                  updatedMatch.team2.name != 'Unknown Team'
                      ? updatedMatch.team2
                      : _match!.team2,
              status: actualStatus,
            );
          } else {
            String correctedStatus = matchData['status'] ?? _match!.status;
            if (_match!.matchType == 'full_match') {
              correctedStatus = 'Ongoing'; // We control completion
            }

            _match = TennisMatch(
              id: _match!.id,
              tournamentId: _match!.tournamentId,
              roundName: _match!.roundName,
              matchNumber: _match!.matchNumber,
              matchType: _match!.matchType,
              team1: _match!.team1,
              team2: _match!.team2,
              status: correctedStatus,
            );
          }
        }

        // Update tennis score
        if (data['tennis_score'] != null) {
          _tennisScore = TennisScore.fromJson(data['tennis_score']);

          if (kDebugMode) {
            print('\n=== 📊 UPDATED SCORES ===');
            print(
              'Sets T1=${_tennisScore!.sets.team1}, T2=${_tennisScore!.sets.team2}',
            );
            print(
              'Games T1=${_tennisScore!.games.team1}, T2=${_tennisScore!.games.team2}',
            );
            print('Sets History Count: ${_tennisScore!.setsHistory.length}');

            // Show sets history
            for (int i = 0; i < _tennisScore!.setsHistory.length; i++) {
              var set = _tennisScore!.setsHistory[i];
              print(
                '  Set [$i]: Set#${set.setNumber}, T1=${set.team1Games}-${set.team2Games}, Winner=${set.winner}',
              );
            }
          }
        }

        // Apply completion logic based on match type
        if (_match!.matchType == 'full_match') {
          // For full matches: need 2 sets to win (represents 2 actual sets won)
          final team1Sets = _tennisScore!.sets.team1;
          final team2Sets = _tennisScore!.sets.team2;

          if (kDebugMode) {
            print('\n=== 🎯 FULL MATCH LOGIC (2 SETS TO WIN) ===');
            print('Team1 sets: $team1Sets (need 2 to win)');
            print('Team2 sets: $team2Sets (need 2 to win)');
            print('Server completion decision: IGNORED');
          }

          if (team1Sets >= 2) {
            _winner = 'team1';
            _setState(TennisScoringState.matchCompleted);
            if (kDebugMode)
              print(
                '🏆 FULL MATCH COMPLETED - Team1 wins with $team1Sets sets',
              );
          } else if (team2Sets >= 2) {
            _winner = 'team2';
            _setState(TennisScoringState.matchCompleted);
            if (kDebugMode)
              print(
                '🏆 FULL MATCH COMPLETED - Team2 wins with $team2Sets sets',
              );
          } else {
            _setState(TennisScoringState.loaded);
            if (kDebugMode)
              print(
                '🔄 Full match continues - Team1: $team1Sets, Team2: $team2Sets (need 2 to win)',
              );
          }
        } else {
          // Single set matches - use server decision
          bool serverSaysCompleted = data['is_completed'] == true;
          String? serverWinner = data['winner'];

          if (kDebugMode) {
            print('\n=== 🎾 SINGLE SET MATCH ===');
            print(
              'Server completed: $serverSaysCompleted, winner: $serverWinner',
            );
          }

          if (serverSaysCompleted) {
            _winner = serverWinner;
            _setState(TennisScoringState.matchCompleted);
          } else {
            _setState(TennisScoringState.loaded);
          }
        }
      } else {
        throw Exception(
          'Failed to update score: ${response['message'] ?? 'Invalid response'}',
        );
      }
    } catch (e) {
      _updatingTeam = null;
      _error = e.toString();
      _setState(TennisScoringState.error);

      if (kDebugMode) {
        print('\n=== ❌ ERROR ===');
        print('Error: $e');
      }
    }
  }

  String getMatchProgress() {
    if (_match == null || _tennisScore == null) return '';

    switch (_match!.matchType) {
      case 'one_set_6':
      case 'one_set_9':
        return 'Single Set Match';

      case 'full_match':
        final team1Sets = _tennisScore!.sets.team1;
        final team2Sets = _tennisScore!.sets.team2;
        final totalSetsAwarded = team1Sets + team2Sets;
        if (totalSetsAwarded <= 1) {
          return 'First Set';
        } else if (totalSetsAwarded <= 2) {
          return 'Second Set';
        } else {
          return 'Final Set';
        }

      default:
        return '';
    }
  }

  // Helper to check if widget is still mounted
  bool get mounted => hasListeners;

  // Handle no-show
  Future<void> handleNoShow() async {
    if (_state == TennisScoringState.updating || _match == null) return;

    try {
      _setState(TennisScoringState.updating);

      int? winnerTeamId;
      String? winner;

      if (_bothNoShow) {
        winnerTeamId = null;
        winner = null;
      } else if (_team1NoShow && !_team2NoShow) {
        winnerTeamId = _match!.team2.id;
        winner = 'team2';
      } else if (_team2NoShow && !_team1NoShow) {
        winnerTeamId = _match!.team1.id;
        winner = 'team1';
      }

      await TennisApiService.updateMatchWithNoShow(
        tournamentId: _match!.tournamentId,
        matchId: _match!.id,
        winnerTeamId: winnerTeamId,
        team1NoShow: _team1NoShow,
        team2NoShow: _team2NoShow,
      );

      // Set winner for dialog display
      _winner = winner;
      _setState(TennisScoringState.matchCompleted);
    } catch (e) {
      _error = e.toString();
      _setState(TennisScoringState.error);
    }
  }

  // Update no-show states
  void updateNoShowState({
    bool? team1NoShow,
    bool? team2NoShow,
    bool? bothNoShow,
  }) {
    if (bothNoShow != null) {
      _bothNoShow = bothNoShow;
      if (_bothNoShow) {
        _team1NoShow = true;
        _team2NoShow = true;
      } else {
        _team1NoShow = false;
        _team2NoShow = false;
      }
    } else {
      if (team1NoShow != null) _team1NoShow = team1NoShow;
      if (team2NoShow != null) _team2NoShow = team2NoShow;
    }
    notifyListeners();
  }

  // Helper method to get match type display
  String getMatchTypeDisplay() {
    if (_match == null) return 'Tennis Match';

    switch (_match!.matchType) {
      case 'one_set_6':
        return 'Quick Match (6 Games)';
      case 'one_set_9':
        return 'Long Match (9 Games)';
      case 'full_match':
        return 'Full Tournament Match (Best of 3 Sets)';
      default:
        return 'Tennis Match';
    }
  }

  // Format points for display
  String formatPointsDisplay(String points) {
    switch (points.toLowerCase()) {
      case 'love':
        return '0';
      case '15':
        return '15';
      case '30':
        return '30';
      case '40':
        return '40';
      case 'adv':
      case 'advantage':
        return 'AD';
      default:
        return points.toUpperCase();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _state = TennisScoringState.initial;
    _match = null;
    _tennisScore = null;
    _error = null;
    _winner = null;
    _team1NoShow = false;
    _team2NoShow = false;
    _bothNoShow = false;
    _updatingTeam = null;
    notifyListeners();
  }

  // Private helper to set state
  void _setState(TennisScoringState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
