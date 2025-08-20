import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/apis.dart';
import '../views/play/models/team_model.dart';

class TeamService {
  static const String baseUrl = AppApis.myTeams;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<TeamsResponse> getTeams() async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (jsonData['success'] == true && jsonData['data'] != null) {
          if (kDebugMode) print('jsonData is $jsonData');
          return TeamsResponse.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to load teams');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching teams: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> getTeamInviteLink(String teamId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${AppApis.baseUrl}teams/$teamId/invite-link'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final code = body['data']?['invitation_code'];
        if (code == null) {
          throw Exception('Invitation code not found in response');
        }
        return 'https://padelduo.netlify.app/join-team/$code';
      } else {
        throw Exception(body['message'] ?? 'Failed to get invite link');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> copyAndShareInviteLink(String teamId) async {
    try {
      final inviteLink = await getTeamInviteLink(teamId);
      await Clipboard.setData(ClipboardData(text: inviteLink));

      const shareText = 'Join my team! Use this invite link:';
      final fullShareText = '$shareText\n\n$inviteLink';

      await Share.share(fullShareText, subject: 'Team Invite Link');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}