// providers/club_team_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedalduo/global/apis.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedalduo/views/play/models/tournaments_model.dart';
import '../models/club_team_member_model.dart';
import '../services/create_team_api_services.dart';

class CreateTeamProvider extends ChangeNotifier {
  // API Endpoints
  static String createClubTeam = "${AppApis.baseUrl}club-teams";
  static String userClubTeam = "${AppApis.baseUrl}club-teams/my-team";
  static String publicTeamsTeam = "${AppApis.baseUrl}club-teams/public-teams";
  static String getClubTeamById = "${AppApis.baseUrl}club-teams";
  static String joinPublicTeam = "${AppApis.baseUrl}club-teams";
  static String transferCaptaincy = "${AppApis.baseUrl}club-teams";
  static String teamPrivacyUpdate = "${AppApis.baseUrl}club-teams";
  static String removeMemberFromTeam = "${AppApis.baseUrl}club-teams";
  static String leaveClubTeam = "${AppApis.baseUrl}club-teams";

  // State variables
  ClubTeam? _myTeam;
  List<ClubTeam> _publicTeams = [];
  List<ClubTeam> _myTeams = [];

  // Loading states
  bool _isLoading = false;
  bool _isCreatingTeam = false;
  bool _isJoiningTeam = false;
  bool _isLeavingTeam = false;
  bool _isTransferringCaptaincy = false;
  bool _isUpdatingPrivacy = false;
  bool _isRemovingMember = false;
  Map<int, bool> _teamActionLoading = {};

  String? _errorMessage;
  String? _successMessage;
  bool _isWithdrawingFromTournament = false;
  bool _isRegisteringForTournament = false;
  List<Tournament> _availableTournaments = [];

  // Add these getters
  bool get isRegisteringForTournament => _isRegisteringForTournament;
  List<Tournament> get availableTournaments => _availableTournaments;
  bool get isWithdrawingFromTournament => _isWithdrawingFromTournament;

  ClubTeam? get myTeam => _myTeam;
  List<ClubTeam> get publicTeams => _publicTeams;
  List<ClubTeam> get myTeams => _myTeams;
  bool get isLoading => _isLoading;
  bool get isCreatingTeam => _isCreatingTeam;
  bool get isJoiningTeam => _isJoiningTeam;
  bool get isLeavingTeam => _isLeavingTeam;
  bool get isTransferringCaptaincy => _isTransferringCaptaincy;
  bool get isUpdatingPrivacy => _isUpdatingPrivacy;
  bool get isRemovingMember => _isRemovingMember;
  bool isTeamActionLoading(int teamId) => _teamActionLoading[teamId] ?? false;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasTeams => _myTeams.isNotEmpty;
  int get teamCount => _myTeams.length;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Create Club Team
  Future<bool> createTeam(CreateTeamRequest request) async {
    _isCreatingTeam = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse(createClubTeam),
        headers: _getHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(
          responseData,
          (data) => ClubTeam.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _setSuccess('Team created successfully!');
          await fetchMyTeam(); // Refresh to get captain status properly
          return true;
        } else {
          _setError(apiResponse.message ?? 'Failed to create team');
          return false;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to create team');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isCreatingTeam = false;
      notifyListeners();
    }
  }

  // 2. Get User's Club Team
  Future<void> fetchMyTeam() async {
    _isLoading = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(userClubTeam),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          responseData,
          (data) => ClubTeam.fromJson(data),
        );

        if (apiResponse.success) {
          if (apiResponse.data != null) {
            _myTeam = apiResponse.data;
            _myTeams = [apiResponse.data!];
          } else {
            // No team exists
            _myTeams = [];
            _myTeam = null;
          }
        } else {
          _setError(apiResponse.message ?? 'Failed to fetch team');
        }
      } else {
        if (responseData['message'] != null) {
          _setError(responseData['message']);
        }
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Get Public Teams
  Future<void> fetchPublicTeams() async {
    _isLoading = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(publicTeamsTeam),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          responseData,
          (data) =>
              (data as List).map((team) => ClubTeam.fromJson(team)).toList(),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _publicTeams = apiResponse.data!;
        } else {
          _setError(apiResponse.message ?? 'Failed to fetch public teams');
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to fetch public teams');
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Get Club Team By ID
  Future<ClubTeam?> getTeamById(int teamId) async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$getClubTeamById/$teamId'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          responseData,
          (data) => ClubTeam.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data;
        } else {
          _setError(apiResponse.message ?? 'Failed to fetch team details');
          return null;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to fetch team details');
        return null;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return null;
    }
  }

  // 5. Join Public Team
  Future<bool> joinTeam(int teamId) async {
    _teamActionLoading[teamId] = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$joinPublicTeam/$teamId/request-join'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess(
            responseData['message'] ?? 'Successfully joined the team',
          );
          await fetchMyTeam(); // Refresh my team data
          await fetchPublicTeams(); // Refresh public teams
          return true;
        } else {
          _setError(responseData['message'] ?? 'Failed to join team');
          return false;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to join team');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _teamActionLoading[teamId] = false;
      notifyListeners();
    }
  }

  // 6. Transfer Captaincy
  Future<bool> transferCaptaincyToMember(int teamId, int newCaptainId) async {
    _isTransferringCaptaincy = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$transferCaptaincy/$teamId/transfer-captain'),
        headers: _getHeaders(token),
        body: jsonEncode(
          TransferCaptaincyRequest(newCaptainId: newCaptainId).toJson(),
        ),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess(
            responseData['message'] ?? 'Captaincy transferred successfully',
          );
          await fetchMyTeam(); // Refresh team data
          return true;
        } else {
          _setError(responseData['message'] ?? 'Failed to transfer captaincy');
          return false;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to transfer captaincy');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isTransferringCaptaincy = false;
      notifyListeners();
    }
  }

  // 7. Update Team Privacy
  Future<bool> updateTeamPrivacy(int teamId, bool isPrivate) async {
    _isUpdatingPrivacy = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.put(
        Uri.parse('$teamPrivacyUpdate/$teamId/privacy'),
        headers: _getHeaders(token),
        body: jsonEncode(UpdatePrivacyRequest(isPrivate: isPrivate).toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess(responseData['message'] ?? 'Privacy settings updated');
          await fetchMyTeam(); // Refresh team data
          return true;
        } else {
          _setError(
            responseData['message'] ?? 'Failed to update privacy settings',
          );
          return false;
        }
      } else {
        _setError(
          responseData['message'] ?? 'Failed to update privacy settings',
        );
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isUpdatingPrivacy = false;
      notifyListeners();
    }
  }

  // 8. Remove Member from Team
  Future<bool> removeMember(int teamId, int memberId) async {
    _isRemovingMember = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('$removeMemberFromTeam/$teamId/members/$memberId'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess(responseData['message'] ?? 'Member removed successfully');
          await fetchMyTeam(); // Refresh team data
          return true;
        } else {
          _setError(responseData['message'] ?? 'Failed to remove member');
          return false;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to remove member');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isRemovingMember = false;
      notifyListeners();
    }
  }

  // 9. Leave Club Team
  Future<bool> leaveTeam(int teamId) async {
    _isLeavingTeam = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('$leaveClubTeam/$teamId/leave'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess(responseData['message'] ?? 'Left club team successfully');
          _myTeam = null;
          fetchPublicTeams();
          _myTeams.clear();
          return true;
        } else {
          _setError(responseData['message'] ?? 'Failed to leave team');
          return false;
        }
      } else {
        _setError(responseData['message'] ?? 'Failed to leave team');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isLeavingTeam = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailableTournaments() async {
    _isLoading = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('${AppApis.getAllTournament}'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          final List<dynamic> tournamentList = responseData['data'];
          // Filter only approved tournaments
          _availableTournaments =
              tournamentList
                  .map((json) => Tournament.fromJson(json))
                  .where(
                    (tournament) =>
                        tournament.status.toLowerCase() == 'approved',
                  )
                  .toList();
        } else {
          _setError('Failed to fetch tournaments');
        }
      } else {
        _setError('Failed to fetch tournaments');
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerTeamForTournament({
    required int teamId,
    required int tournamentId,
    required List<int> selectedPlayerIds,
  }) async {
    _isRegisteringForTournament = true;
    clearMessages();
    notifyListeners();

    try {
      final request = TournamentRegistrationRequest(
        tournamentId: tournamentId,
        selectedPlayerIds: selectedPlayerIds,
      );

      final response = await ClubTeamApiService.registerForTournament(
        teamId,
        request,
      );

      if (response.success && response.data != null) {
        final registeredTeamId =
            response.data!.id.toString(); // <-- use the ID from API response
        await _processPayment(registeredTeamId);
        await fetchMyTeam();
        return true;
      } else {
        _setError(response.message ?? 'Failed to register for tournament');
        return false;
      }
    } catch (e) {
      if (e is ClubTeamApiException) {
        _setError(e.message);
      } else {
        _setError('Network error: ${e.toString()}');
      }
      return false;
    } finally {
      _isRegisteringForTournament = false;
      notifyListeners();
    }
  }

  Future<void> _processPayment(String teamId) async {
    try {
      debugPrint('🔍 Starting _processPayment...');
      debugPrint('➡️ Team ID received: $teamId');
      debugPrint('➡️ Payment URL: ${AppApis.baseUrl}teams/$teamId/payment');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        debugPrint('❌ Authentication token not found in SharedPreferences');
        throw Exception('Authentication token not found');
      }

      debugPrint('✅ Auth token retrieved (length: ${token.length})');

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}teams/$teamId/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📡 Payment request sent...');
      debugPrint('➡️ Status Code: ${response.statusCode}');
      debugPrint('➡️ Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('🎉 Payment processed successfully for team $teamId');
      } else {
        debugPrint('⚠️ Payment failed. Status: ${response.statusCode}');
        debugPrint('➡️ Response Body: ${response.body}');
        _setError('Payment could not be completed. Please try again later.');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _processPayment: $e');
      debugPrint('🪲 StackTrace: $stackTrace');
    }
  }

  Future<bool> withdrawFromTournament(int teamId) async {
    _isWithdrawingFromTournament = true;
    clearMessages();
    notifyListeners();

    try {
      final token = await _getAuthToken();
      final response = await http.delete(
        Uri.parse('${AppApis.baseUrl}teams/$teamId/withdraw'),
        headers: _getHeaders(token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          _setSuccess('Successfully withdrawn from tournament');
          await fetchMyTeam();
          return true;
        } else {
          _setError(
            responseData['message'] ?? 'Failed to withdraw from tournament',
          );
          return false;
        }
      } else {
        _setError(
          responseData['message'] ?? 'Failed to withdraw from tournament',
        );
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _isWithdrawingFromTournament = false;
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([fetchMyTeam(), fetchPublicTeams()]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
