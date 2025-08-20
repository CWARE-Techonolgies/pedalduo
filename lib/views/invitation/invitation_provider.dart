import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../global/apis.dart';
import '../../utils/app_utils.dart';
import 'invitation_model.dart';

class InvitationsProvider extends ChangeNotifier {
  List<Invitation> _sentInvitations = [];
  List<Invitation> _receivedInvitations = [];
  bool _isLoadingSent = true;
  bool _isLoadingReceived = true;
  bool _isProcessingInvitation = false;
  String? _authToken;
  String? _errorMessage;

  List<Invitation> get sentInvitations => _sentInvitations;
  List<Invitation> get receivedInvitations => _receivedInvitations;
  bool get isLoadingSent => _isLoadingSent;
  bool get isLoadingReceived => _isLoadingReceived;
  bool get isProcessingInvitation => _isProcessingInvitation;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> initialize() async {
    await _loadAuthToken();
    if (_authToken != null) {
      await Future.wait([fetchSentInvitations(), fetchReceivedInvitations()]);
    }
  }

  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
    } catch (e) {
      _errorMessage = 'Failed to load authentication token';
      notifyListeners();
    }
  }

  Future<void> fetchSentInvitations() async {
    if (_authToken == null) {
      _errorMessage = 'No authentication token found';
      _isLoadingSent = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingSent = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(AppApis.sentInvitations),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('the sent invitation $data');
        if (data['success'] == true) {
          _sentInvitations =
              (data['data'] as List)
                  .map((json) => Invitation.fromJson(json))
                  .toList();
          _sentInvitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch sent invitations';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoadingSent = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceivedInvitations() async {
    if (_authToken == null) {
      _errorMessage = 'No authentication token found';
      _isLoadingReceived = false;
      notifyListeners();
      return;
    }

    try {
      _isLoadingReceived = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(AppApis.recievedInvitations),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('recived invitation $data');
        if (data['success'] == true) {
          _receivedInvitations =
              (data['data'] as List)
                  .map((json) => Invitation.fromJson(json))
                  .toList();

          _receivedInvitations.sort((a, b) {
            if (a.isPending && !b.isPending) return -1;
            if (!a.isPending && b.isPending) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });
        } else {
          _errorMessage =
              data['message'] ?? 'Failed to fetch received invitations';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoadingReceived = false;
      notifyListeners();
    }
  }

  Future<bool> acceptInvitation(
      String invitationCode,
      BuildContext context,
      ) async {
    if (_authToken == null) {
      _errorMessage = 'No authentication token found';
      return false;
    }

    try {
      _isProcessingInvitation = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}team-invitations/$invitationCode/accept'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final invitationIndex = _receivedInvitations.indexWhere(
                (inv) => inv.invitationCode == invitationCode,
          );
          if (invitationIndex != -1) {
            final currentInvitation = _receivedInvitations[invitationIndex];
            final updatedInvitation = Invitation(
              id: currentInvitation.id,
              invitationCode: currentInvitation.invitationCode,
              invitationType: currentInvitation.invitationType,
              status: 'accepted',
              inviteeEmail: currentInvitation.inviteeEmail,
              inviteePhone: currentInvitation.inviteePhone,
              message: currentInvitation.message,
              expiresAt: currentInvitation.expiresAt,
              createdAt: currentInvitation.createdAt,
              team: currentInvitation.team,
              tournament: currentInvitation.tournament,
              invitee: currentInvitation.invitee,
              inviter: currentInvitation.inviter,
            );
            _receivedInvitations[invitationIndex] = updatedInvitation;

            _receivedInvitations.sort((a, b) {
              if (a.isPending && !b.isPending) return -1;
              if (!a.isPending && b.isPending) return 1;
              return b.createdAt.compareTo(a.createdAt);
            });
          }
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to accept invitation';
          AppUtils.showFailureDialog(
            context,
            'Failed to accept invitation',
            _errorMessage!,
          );
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        AppUtils.showFailureDialog(
          context,
          'Failed to accept invitation',
          _errorMessage!,
        );
        return false;
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        _errorMessage = data['message'] ?? 'Invalid invitation or team is full';
        AppUtils.showFailureDialog(
          context,
          'Failed to accept invitation',
          _errorMessage!,
        );
        return false;
      } else if (response.statusCode == 404) {
        _errorMessage = 'Invitation not found or expired';
        AppUtils.showFailureDialog(
          context,
          'Failed to accept invitation',
          _errorMessage!,
        );
        return false;
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        AppUtils.showFailureDialog(
          context,
          'Failed to accept invitation',
          _errorMessage!,
        );
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      AppUtils.showFailureDialog(
        context,
        'Failed to accept invitation',
        _errorMessage!,
      );
      return false;
    } finally {
      _isProcessingInvitation = false;
      notifyListeners();
    }
  }

  Future<bool> declineInvitation(String invitationCode) async {
    if (_authToken == null) {
      _errorMessage = 'No authentication token found';
      return false;
    }

    try {
      _isProcessingInvitation = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${AppApis.baseUrl}team-invitations/$invitationCode/decline'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final invitationIndex = _receivedInvitations.indexWhere(
                (inv) => inv.invitationCode == invitationCode,
          );
          if (invitationIndex != -1) {
            final currentInvitation = _receivedInvitations[invitationIndex];
            final updatedInvitation = Invitation(
              id: currentInvitation.id,
              invitationCode: currentInvitation.invitationCode,
              invitationType: currentInvitation.invitationType,
              status: 'rejected',
              inviteeEmail: currentInvitation.inviteeEmail,
              inviteePhone: currentInvitation.inviteePhone,
              message: currentInvitation.message,
              expiresAt: currentInvitation.expiresAt,
              createdAt: currentInvitation.createdAt,
              team: currentInvitation.team,
              tournament: currentInvitation.tournament,
              invitee: currentInvitation.invitee,
              inviter: currentInvitation.inviter,
            );
            _receivedInvitations[invitationIndex] = updatedInvitation;

            _receivedInvitations.sort((a, b) {
              if (a.isPending && !b.isPending) return -1;
              if (!a.isPending && b.isPending) return 1;
              return b.createdAt.compareTo(a.createdAt);
            });
          }
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Failed to decline invitation';
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        return false;
      } else if (response.statusCode == 404) {
        _errorMessage = 'Invitation not found or expired';
        return false;
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isProcessingInvitation = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchSentInvitations(), fetchReceivedInvitations()]);
  }

  Future<void> refreshSentInvitations() async {
    await fetchSentInvitations();
  }

  Future<void> refreshReceivedInvitations() async {
    await fetchReceivedInvitations();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  int get pendingReceivedCount {
    return _receivedInvitations
        .where((invitation) => invitation.isPending)
        .length;
  }

  int get expiredInvitationsCount {
    final now = DateTime.now();
    return _receivedInvitations
        .where(
          (invitation) =>
      invitation.expiresAt.isBefore(now) && invitation.isPending,
    )
        .length;
  }

  List<Invitation> getInvitationsByStatus(
      List<Invitation> invitations,
      String status,
      ) {
    return invitations
        .where(
          (invitation) =>
      invitation.status.toLowerCase() == status.toLowerCase(),
    )
        .toList();
  }

  bool teamHasSpace(Invitation invitation) {
    return invitation.team.totalPlayers < invitation.team.maxPlayers;
  }

  bool isInvitationExpired(Invitation invitation) {
    return DateTime.now().isAfter(invitation.expiresAt);
  }

  bool hasTournamentStarted(Invitation invitation) {
    // Since tournament data might be missing, we'll assume tournament hasn't started
    if (invitation.tournament == null) return false;
    return DateTime.now().isAfter(invitation.tournament!.tournamentStartDate);
  }

  List<Invitation> get actionableReceivedInvitations {
    return _receivedInvitations
        .where(
          (invitation) =>
      invitation.isPending &&
          !isInvitationExpired(invitation) &&
          teamHasSpace(invitation) &&
          !hasTournamentStarted(invitation),
    )
        .toList();
  }

  // Modified to handle cases where tournament data might be missing
  Future<bool> handleInvitationAction(
      BuildContext context,
      String invitationCode,
      String action, {
        Function(String)? onSuccess,
      }) async {
    bool result = false;
    _isProcessingInvitation = true;
    notifyListeners();

    try {
      if (action.toLowerCase() == 'accept') {
        result = await acceptInvitation(invitationCode, context);
      } else if (action.toLowerCase() == 'decline') {
        result = await declineInvitation(invitationCode);
      }

      if (result) {
        onSuccess?.call('Invitation ${action.toLowerCase()}ed successfully');
        return true;
      } else {
        AppUtils.showFailureDialog(
          context,
          'Failed to ${action.toLowerCase()} invitation',
          _errorMessage ?? 'Something went wrong',
        );
        return false;
      }
    } finally {
      _isProcessingInvitation = false;
      notifyListeners();
    }
  }
}