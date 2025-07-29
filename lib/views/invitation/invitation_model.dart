class Invitation {
  final int id;
  final String invitationCode;
  final String invitationType;
  final String status;
  final String? inviteeEmail;
  final String? inviteePhone;
  final String message;
  final DateTime expiresAt;
  final DateTime createdAt;
  final Team team;
  final Tournament tournament;
  final User? invitee;
  final User? inviter;

  Invitation({
    required this.id,
    required this.invitationCode,
    required this.invitationType,
    required this.status,
    this.inviteeEmail,
    this.inviteePhone,
    required this.message,
    required this.expiresAt,
    required this.createdAt,
    required this.team,
    required this.tournament,
    this.invitee,
    this.inviter,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? 0,
      invitationCode: json['invitation_code'] ?? '',
      invitationType: json['invitation_type'] ?? '',
      status: json['status'] ?? 'pending',
      inviteeEmail: json['invitee_email'],
      inviteePhone: json['invitee_phone'],
      message: json['message'] ?? '',
      expiresAt: DateTime.parse(
        json['expires_at'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      team: Team.fromJson(json['team'] ?? {}),
      tournament: Tournament.fromJson(json['tournament'] ?? {}),
      invitee: json['invitee'] != null ? User.fromJson(json['invitee']) : null,
      inviter: json['inviter'] != null ? User.fromJson(json['inviter']) : null,
    );
  }

  bool get isUniversal => invitationType == 'universal';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';
}

class Team {
  final int id;
  final String name;
  final int totalPlayers;

  Team({required this.id, required this.name, required this.totalPlayers});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Team',
      totalPlayers: json['total_players'] ?? 0,
    );
  }
}

class Tournament {
  final int id;
  final String title;
  final String location;
  final int playersPerTeam;
  final String gender;
  final DateTime tournamentStartDate;

  Tournament({
    required this.id,
    required this.title,
    required this.location,
    required this.playersPerTeam,
    required this.gender,
    required this.tournamentStartDate,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Tournament',
      location: json['location'] ?? 'TBD',
      playersPerTeam: json['players_per_team'] ?? 0,
      gender: json['gender'] ?? '',
      tournamentStartDate: DateTime.parse(
        json['tournament_start_date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
    );
  }

  String get initials {
    final names = name.split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0].substring(0, 1).toUpperCase();
    return '${names[0].substring(0, 1)}${names[1].substring(0, 1)}'
        .toUpperCase();
  }
}
