import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pedalduo/services/shared_preference_service.dart';

class TennisApiService {
  static const String baseUrl = 'https://padelduo.duckdns.org';

  static Future<Map<String, dynamic>> getTennisScore(int matchId) async {
    try {
      final token = await SharedPreferencesService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/tournaments/matches/$matchId/tennis-score'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load tennis score');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateTennisScore({
    required int tournamentId,
    required int matchId,
    required String teamWhoScored,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/tournaments/$tournamentId/matches/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'team_who_scored': teamWhoScored,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update score');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateMatchWithNoShow({
    required int tournamentId,
    required int matchId,
    int? winnerTeamId,
    bool team1NoShow = false,
    bool team2NoShow = false,
  }) async {
    try {
      final token = await SharedPreferencesService.getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/tournaments/$tournamentId/matches/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'winner_team_id': winnerTeamId,
          'team1_no_show': team1NoShow,
          'team2_no_show': team2NoShow,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update match');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}