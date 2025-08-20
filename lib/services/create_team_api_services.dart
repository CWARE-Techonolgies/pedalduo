// services/club_team_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pedalduo/global/apis.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/club_team_member_model.dart';

class ClubTeamApiService {
  static const String baseUrl = AppApis.baseUrl;

  // API Endpoints
  static const String createClubTeam = "${baseUrl}club-teams";
  static const String userClubTeam = "${baseUrl}club-teams/my-team";
  static const String publicTeamsTeam = "${baseUrl}club-teams/public-teams";
  static const String getClubTeamById = "${baseUrl}club-teams";
  static const String joinPublicTeam = "${baseUrl}club-teams";
  static const String transferCaptaincy = "${baseUrl}club-teams";
  static const String teamPrivacyUpdate = "${baseUrl}club-teams";
  static const String removeMemberFromTeam = "${baseUrl}club-teams";
  static const String leaveClubTeam = "${baseUrl}club-teams";

  // Get auth token from shared preferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with auth token
  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  static Future<ApiResponse<TournamentRegistrationResponse>> registerForTournament(
      int teamId,
      TournamentRegistrationRequest request,
      ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl${'club-teams'}/$teamId/register-tournament'),
        headers: _getHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      return _handleResponse(
        response,
            (data) => ApiResponse<TournamentRegistrationResponse>(
          success: data['success'] as bool,
          data: data['data'] != null
              ? TournamentRegistrationResponse.fromJson(data['data'])
              : null,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }




  // Handle API response
  static T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return parser(responseData);
    } else {
      throw ClubTeamApiException(
        message: responseData['message'] ?? 'API request failed',
        statusCode: response.statusCode,
      );
    }
  }

  // 1. Create Club Team
  static Future<ApiResponse<ClubTeam>> createTeam(
    CreateTeamRequest request,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse(createClubTeam),
        headers: _getHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<ClubTeam>(
          success: data['success'] as bool,
          data: data['data'] != null ? ClubTeam.fromJson(data['data']) : null,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 2. Get User's Club Team
  static Future<ApiResponse<ClubTeam>> getMyTeam() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(userClubTeam),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<ClubTeam>(
          success: data['success'] as bool,
          data: data['data'] != null ? ClubTeam.fromJson(data['data']) : null,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 3. Get Public Teams
  static Future<ApiResponse<List<ClubTeam>>> getPublicTeams() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(publicTeamsTeam),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<List<ClubTeam>>(
          success: data['success'] as bool,
          data:
              data['data'] != null
                  ? (data['data'] as List<dynamic>)
                      .map((team) => ClubTeam.fromJson(team))
                      .toList()
                  : null,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 4. Get Club Team By ID
  static Future<ApiResponse<ClubTeam>> getTeamById(int teamId) async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$getClubTeamById/$teamId'),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<ClubTeam>(
          success: data['success'] as bool,
          data: data['data'] != null ? ClubTeam.fromJson(data['data']) : null,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 5. Join Public Team
  static Future<ApiResponse<String>> joinTeam(int teamId) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$joinPublicTeam/$teamId/request-join'),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<String>(
          success: data['success'] as bool,
          data: data['message'] as String?,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 6. Transfer Captaincy
  static Future<ApiResponse<String>> transferCaptaincyToMember(
    int teamId,
    int newCaptainId,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$transferCaptaincy/$teamId/transfer-captain'),
        headers: _getHeaders(token),
        body: jsonEncode(
          TransferCaptaincyRequest(newCaptainId: newCaptainId).toJson(),
        ),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<String>(
          success: data['success'] as bool,
          data: data['message'] as String?,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 7. Update Team Privacy
  static Future<ApiResponse<String>> updateTeamPrivacy(
    int teamId,
    bool isPrivate,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$teamPrivacyUpdate/$teamId/privacy'),
        headers: _getHeaders(token),
        body: jsonEncode(UpdatePrivacyRequest(isPrivate: isPrivate).toJson()),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<String>(
          success: data['success'] as bool,
          data: data['message'] as String?,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 8. Remove Member from Team
  static Future<ApiResponse<String>> removeMember(
    int teamId,
    int memberId,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('$removeMemberFromTeam/$teamId/members/$memberId'),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<String>(
          success: data['success'] as bool,
          data: data['message'] as String?,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }

  // 9. Leave Club Team
  static Future<ApiResponse<String>> leaveTeam(int teamId) async {
    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('$leaveClubTeam/$teamId/leave'),
        headers: _getHeaders(token),
      );

      return _handleResponse(
        response,
        (data) => ApiResponse<String>(
          success: data['success'] as bool,
          data: data['message'] as String?,
          message: data['message'] as String?,
        ),
      );
    } catch (e) {
      throw ClubTeamApiException(message: 'Network error: ${e.toString()}');
    }
  }
}

// Custom exception class for API errors
class ClubTeamApiException implements Exception {
  final String message;
  final int? statusCode;

  ClubTeamApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ClubTeamApiException: $message';
}
