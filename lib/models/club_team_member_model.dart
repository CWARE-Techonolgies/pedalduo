// models/club_team_models.dart
import 'dart:convert';

class ClubTeamMember {
  final int id;
  final String name;
  final String email;
  final ClubTeamMemberDetails? clubTeamMember;

  ClubTeamMember({
    required this.id,
    required this.name,
    required this.email,
    this.clubTeamMember,
  });

  factory ClubTeamMember.fromJson(Map<String, dynamic> json) {
    return ClubTeamMember(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      clubTeamMember: json['ClubTeamMember'] != null
          ? ClubTeamMemberDetails.fromJson(json['ClubTeamMember'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'ClubTeamMember': clubTeamMember?.toJson(),
    };
  }
}

class ClubTeamMemberDetails {
  final int id;
  final int clubTeamId;
  final int memberId;
  final bool isCaptain;
  final String joinedAt;
  final String createdAt;
  final String updatedAt;

  ClubTeamMemberDetails({
    required this.id,
    required this.clubTeamId,
    required this.memberId,
    required this.isCaptain,
    required this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClubTeamMemberDetails.fromJson(Map<String, dynamic> json) {
    return ClubTeamMemberDetails(
      id: json['id'] as int,
      clubTeamId: json['club_team_id'] as int,
      memberId: json['member_id'] as int,
      isCaptain: json['is_captain'] as bool,
      joinedAt: json['joined_at'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_team_id': clubTeamId,
      'member_id': memberId,
      'is_captain': isCaptain,
      'joined_at': joinedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Add new classes for tournament registration info
class RegisteredTournament {
  final int id;
  final String title;
  final String description;
  final String location;
  final String status;
  final String registrationEndDate;
  final String tournamentStartDate;
  final String tournamentEndDate;
  final String totalPrizePool;
  final int playersPerTeam;
  final int maxTeams;
  final int registeredTeams;
  final String gender;

  RegisteredTournament({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.registrationEndDate,
    required this.tournamentStartDate,
    required this.tournamentEndDate,
    required this.totalPrizePool,
    required this.playersPerTeam,
    required this.maxTeams,
    required this.registeredTeams,
    required this.gender,
  });

  factory RegisteredTournament.fromJson(Map<String, dynamic> json) {
    return RegisteredTournament(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: json['location'] as String,
      status: json['status'] as String,
      registrationEndDate: json['registration_end_date'] as String,
      tournamentStartDate: json['tournament_start_date'] as String,
      tournamentEndDate: json['tournament_end_date'] as String,
      totalPrizePool: json['total_prize_pool'] as String,
      playersPerTeam: json['players_per_team'] as int,
      maxTeams: json['max_teams'] as int,
      registeredTeams: json['registered_teams'] as int,
      gender: json['gender'] as String,
    );
  }
}

class TournamentTeam {
  final int id;
  final String name;
  final int totalPlayers;
  final bool isEliminated;
  final String createdAt;

  TournamentTeam({
    required this.id,
    required this.name,
    required this.totalPlayers,
    required this.isEliminated,
    required this.createdAt,
  });

  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      id: json['id'] as int,
      name: json['name'] as String,
      totalPlayers: json['total_players'] as int,
      isEliminated: json['is_eliminated'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }
}

class ClubTeam {
  final int id;
  final String name;
  final int captainId;
  final String gender;
  final bool isPrivate;
  final int totalMembers;
  final int maxMembers;
  final String? avatar;
  final String createdAt;
  final String updatedAt;
  final ClubTeamMember? captain;
  final List<ClubTeamMember> members;
  // Add tournament registration fields
  final bool alreadyRegistered;
  final RegisteredTournament? registeredTournament;
  final TournamentTeam? tournamentTeam;

  ClubTeam({
    required this.id,
    required this.name,
    required this.captainId,
    required this.gender,
    required this.isPrivate,
    required this.totalMembers,
    required this.maxMembers,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.captain,
    required this.members,
    this.alreadyRegistered = false,
    this.registeredTournament,
    this.tournamentTeam,
  });
  bool get isRegisteredForTournament => alreadyRegistered && registeredTournament != null;

  factory ClubTeam.fromJson(Map<String, dynamic> json) {
    return ClubTeam(
      id: json['id'] as int,
      name: json['name'] as String,
      captainId: json['captain_id'] as int,
      gender: json['gender'] as String,
      isPrivate: json['is_private'] as bool,
      totalMembers: json['total_members'] as int,
      maxMembers: json['max_members'] as int,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      captain: json['captain'] != null
          ? ClubTeamMember.fromJson(json['captain'])
          : null,
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => ClubTeamMember.fromJson(member))
          .toList() ??
          [],
      alreadyRegistered: json['alreadyRegistered'] as bool? ?? false,
      registeredTournament: json['registeredTournament'] != null
          ? RegisteredTournament.fromJson(json['registeredTournament'])
          : null,
      tournamentTeam: json['tournamentTeam'] != null
          ? TournamentTeam.fromJson(json['tournamentTeam'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'captain_id': captainId,
      'gender': gender,
      'is_private': isPrivate,
      'total_members': totalMembers,
      'max_members': maxMembers,
      'avatar': avatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'captain': captain?.toJson(),
      'members': members.map((member) => member.toJson()).toList(),
      'alreadyRegistered': alreadyRegistered,
      'registeredTournament': registeredTournament,
      'tournamentTeam': tournamentTeam,
    };
  }

  ClubTeam copyWith({
    int? id,
    String? name,
    int? captainId,
    String? gender,
    bool? isPrivate,
    int? totalMembers,
    int? maxMembers,
    String? avatar,
    String? createdAt,
    String? updatedAt,
    ClubTeamMember? captain,
    List<ClubTeamMember>? members,
    bool? alreadyRegistered,
    RegisteredTournament? registeredTournament,
    TournamentTeam? tournamentTeam,
  }) {
    return ClubTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      captainId: captainId ?? this.captainId,
      gender: gender ?? this.gender,
      isPrivate: isPrivate ?? this.isPrivate,
      totalMembers: totalMembers ?? this.totalMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      captain: captain ?? this.captain,
      members: members ?? this.members,
      alreadyRegistered: alreadyRegistered ?? this.alreadyRegistered,
      registeredTournament: registeredTournament ?? this.registeredTournament,
      tournamentTeam: tournamentTeam ?? this.tournamentTeam,
    );
  }

  String get formattedCreatedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return createdAt;
    }
  }
}

class CreateTeamRequest {
  final String name;
  final bool isPrivate;
  final String? avatar;

  CreateTeamRequest({
    required this.name,
    required this.isPrivate,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_private': isPrivate,
      if (avatar != null) 'avatar': avatar,
    };
  }
}

class TransferCaptaincyRequest {
  final int newCaptainId;

  TransferCaptaincyRequest({
    required this.newCaptainId,
  });

  Map<String, dynamic> toJson() {
    return {
      'new_captain_id': newCaptainId,
    };
  }
}

class UpdatePrivacyRequest {
  final bool isPrivate;

  UpdatePrivacyRequest({
    required this.isPrivate,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_private': isPrivate,
    };
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
    );
  }
}

class TournamentRegistrationRequest {
  final int tournamentId;
  final List<int> selectedPlayerIds;

  TournamentRegistrationRequest({
    required this.tournamentId,
    required this.selectedPlayerIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'selected_player_ids': selectedPlayerIds,
    };
  }
}

class TournamentRegistrationResponse {
  final bool isPaymentComplete;
  final String totalAmountPaid;
  final bool isEliminated;
  final int matchesPlayed;
  final int matchesWon;
  final String totalPerformancePoints;
  final String averagePerformance;
  final int id;
  final String name;
  final int tournamentId;
  final int captainId;
  final int parentTeamId;
  final int totalPlayers;
  final String updatedAt;
  final String createdAt;
  final int? finalPosition;

  TournamentRegistrationResponse({
    required this.isPaymentComplete,
    required this.totalAmountPaid,
    required this.isEliminated,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.totalPerformancePoints,
    required this.averagePerformance,
    required this.id,
    required this.name,
    required this.tournamentId,
    required this.captainId,
    required this.parentTeamId,
    required this.totalPlayers,
    required this.updatedAt,
    required this.createdAt,
    this.finalPosition,
  });

  factory TournamentRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return TournamentRegistrationResponse(
      isPaymentComplete: json['is_payment_complete'] as bool,
      totalAmountPaid: json['total_amount_paid'] as String,
      isEliminated: json['is_eliminated'] as bool,
      matchesPlayed: json['matches_played'] as int,
      matchesWon: json['matches_won'] as int,
      totalPerformancePoints: json['total_performance_points'] as String,
      averagePerformance: json['average_performance'] as String,
      id: json['id'] as int,
      name: json['name'] as String,
      tournamentId: json['tournament_id'] as int,
      captainId: json['captain_id'] as int,
      parentTeamId: json['parent_team_id'] as int,
      totalPlayers: json['total_players'] as int,
      updatedAt: json['updatedAt'] as String,
      createdAt: json['createdAt'] as String,
      finalPosition: json['final_position'] as int?,
    );
  }
}