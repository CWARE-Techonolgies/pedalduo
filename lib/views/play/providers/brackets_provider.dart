import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../global/apis.dart';
import '../../../utils/app_utils.dart';
import '../brackets/all_brackets_views.dart';
import '../models/tournament_data.dart';
import 'tournament_provider.dart';

class Brackets extends ChangeNotifier {
  bool _isGeneratingBrackets = false;
  bool get isGeneratingBrackets => _isGeneratingBrackets;
  TournamentData? _tournamentData;
  bool _isLoading = false;
  String? _error;
  bool _nextRoundLoading = false;
  bool get nextRoundLoading => _nextRoundLoading;

  TournamentData? get tournamentData => _tournamentData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> showTournamentBrackets(
    BuildContext context,
    dynamic tournament,
    TournamentProvider provider,
    bool isOrganizer,
    String tournamentId,
    String tournamentName,
    int? winnerTeamId,
    String tournamentStatus,
    DateTime tournamentStartDate,
    DateTime tournamentEndDate,
  ) async {
    if (kDebugMode) {
      print('Showing brackets for tournament: ${tournament.id}');
    }
    _navigateToBracketsView(
      context,
      tournament,
      isOrganizer,
      tournamentId,
      tournamentName,
      winnerTeamId,
      tournamentStatus,
      tournamentStartDate,
      tournamentEndDate,
    );
  }

  Future<void> generateTournamentBrackets(
    BuildContext context,
    dynamic tournament,
    TournamentProvider provider,
  ) async {
    // Generate new brackets
    await _generateBrackets(context, tournament, provider);
  }

  Future<void> _generateBrackets(
    BuildContext context,
    dynamic tournament,
    TournamentProvider provider,
  ) async {
    try {
      _isGeneratingBrackets = true;
      notifyListeners();

      // Get auth token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call to generate brackets
      final response = await http.post(
        Uri.parse(
          '${AppApis.baseUrl}tournaments/${tournament.id}/generate-bracket',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        AppUtils.showSuccessSnackBar(
          context,
          'Brackets generated successfully!',
        );
        await provider.fetchMyTournaments(forceRefresh: true);
        await provider.fetchAllTournaments(forceRefresh: true);

        print('Brackets generated successfully');
      } else {
        throw Exception('Failed to generate brackets: ${response.statusCode}');
      }
    } catch (error) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      AppUtils.showFailureSnackBar(
        context,
        'Error generating brackets: $error',
      );

      print('Error generating brackets: $error');
    } finally {
      _isGeneratingBrackets = false;
      notifyListeners();
    }
  }

  void _navigateToBracketsView(
    BuildContext context,
    dynamic tournament,
    bool isOrganizer,
    final String tournamentId,
    final String tournamentName,
    int? winnerTeamId,
    final String tournamentStatus,
    final DateTime tournamentStartDate,
    final DateTime tournamentEndDate,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder:
            (_) => AllBracketsViews(
              isOrganizer: isOrganizer,
              tournamentId: tournamentId,
              tournamentName: tournamentName,
              tournamentStatus: tournamentStatus,
              winnerTeamId: winnerTeamId,
              tournamentEndDate: tournamentEndDate,
              tournamentStartDate: tournamentStartDate,
            ),
      ),
    );
  }

  Future<void> fetchTournamentData(String tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppApis.baseUrl}tournaments/$tournamentId/bracket'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final tournamentResponse = TournamentResponse.fromJson(jsonResponse);
        _tournamentData = tournamentResponse.data;
        _error = null;
      } else {
        _error = 'Failed to load tournament data';
      }
    } catch (e) {
      _error = 'Network error: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleMatch(
      int matchId,
      String matchDate,
      String tournamentId,
      String matchType,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final request = {
        "match_date": matchDate,
        "match_type": matchType,
      };

      if (kDebugMode) {
        print('match date is $matchDate');
        print('match type is $matchType');
      }

      final response = await http.put(
        Uri.parse(
          '${AppApis.baseUrl}tournaments/$tournamentId/matches/$matchId/dateAndType',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request),
      );

      if (kDebugMode) {
        print("Status: ${response.statusCode}");
        print("Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        await fetchTournamentData(tournamentId);
        return true;
      } else {
        String errorMessage = 'Failed to schedule match';

        try {
          final responseBody = json.decode(response.body);
          errorMessage = responseBody['message'] ?? errorMessage;
        } catch (_) {
          if (kDebugMode) {
            print("Non-JSON error response: ${response.body}");
          }
        }

        _error = errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error scheduling match: $e';
      if (kDebugMode) {
        print(_error);
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMatchScore(
    int matchId,
    UpdateScoreRequest request,
    String tournamentId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Authentication token not found';
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse(
          '${AppApis.baseUrl}tournaments/$tournamentId/matches/${matchId.toString()}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        // Refresh tournament data
        await fetchTournamentData(tournamentId);
        return true;
      } else {
        _error = 'Failed to update match score';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating match score: $e';
      notifyListeners();
      return false;
    }
  }

  bool canGenerateNextRound() {
    if (_tournamentData == null) return false;

    // Check if all matches in the latest round are completed
    final rounds = _tournamentData!.rounds.values.toList();
    if (rounds.isEmpty) return false;

    final latestRound = rounds.reduce(
      (a, b) => a.roundNumber > b.roundNumber ? a : b,
    );
    return latestRound.matches.every((match) => match.isCompleted);
  }

  List<TournamentRound> getSortedRounds() {
    if (_tournamentData == null) return [];

    final rounds = _tournamentData!.rounds.values.toList();
    rounds.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    return rounds;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> generateNextRound(
    String tournamentId,
    BuildContext context,
  ) async {
    _nextRoundLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        debugPrint('❌ Auth token not found');
        _nextRoundLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
        '${AppApis.baseUrl}tournaments/$tournamentId/next-round',
      );

      debugPrint('🔁 Sending POST to: $url');
      debugPrint('🔐 Token: $token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Next round processed: $data');
        AppUtils.showSuccessSnackBar(context, 'New Round Unlocked');
        fetchTournamentData(tournamentId);
      } else {
        debugPrint('❌ Failed to process next round: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('🔥 Exception in nextRound: $e');
      debugPrint('📌 Stacktrace: $stack');
    } finally {
      _nextRoundLoading = false;
      notifyListeners();
    }
  }

  Future<void> shareTournamentScore(
      String tournamentId,
      BuildContext context,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        AppUtils.showFailureSnackBar(context, 'Authentication token not found');
        return;
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}tournaments/$tournamentId/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final shareUrl = responseData['data']['share_url'];
          await Share.share(
            'Check out this tournament scorecard: $shareUrl',
            subject: 'Tournament Scorecard',
          );
        } else {
          AppUtils.showFailureSnackBar(
              context,
              responseData['message'] ?? 'Failed to generate share link'
          );
        }
      } else {
        final responseData = json.decode(response.body);
        AppUtils.showFailureSnackBar(
            context,
            responseData['message'] ?? 'Only organizers and participants can share tournaments'
        );
      }
    } catch (e) {
      AppUtils.showFailureSnackBar(
          context,
          'Error sharing tournament: $e'
      );
    }
  }

  Future<void> shareMatchScore(
      int matchId,
      String tournamentId,
      BuildContext context,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        AppUtils.showFailureSnackBar(context, 'Authentication token not found');
        return;
      }

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}tournaments/$tournamentId/matches/$matchId/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final shareUrl = responseData['data']['share_url'];
          await Share.share(
            'Check out this match scorecard: $shareUrl',
            subject: 'Match Scorecard',
          );
        } else {
          AppUtils.showFailureSnackBar(
              context,
              responseData['message'] ?? 'Failed to generate share link'
          );
        }
      } else {
        final responseData = json.decode(response.body);
        AppUtils.showFailureSnackBar(
            context,
            responseData['message'] ?? 'Only organizers and participants can share matches'
        );
      }
    } catch (e) {
      AppUtils.showFailureSnackBar(
          context,
          'Error sharing match: $e'
      );
    }
  }
}
