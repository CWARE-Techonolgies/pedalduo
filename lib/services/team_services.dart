import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          print('jsonData is $jsonData');
          return TeamsResponse.fromJson(jsonData['data']);
        } else {
          print('jsonData is $jsonData');
          final errorMsg = jsonData['message'] ?? 'API returned success: false';
          throw Exception(errorMsg);
        }
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching teams: $e');
      }
      throw Exception('Error fetching teams: $e');
    }
  }
}
