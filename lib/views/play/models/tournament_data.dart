class TournamentResponse {
  final bool success;
  final TournamentData data;

  TournamentResponse({required this.success, required this.data});

  factory TournamentResponse.fromJson(Map<String, dynamic> json) {
    return TournamentResponse(
      success: json['success'] ?? false,
      data: TournamentData.fromJson(json['data'] ?? {}),
    );
  }
}

class TournamentData {
  final Map<String, TournamentRound> rounds;

  TournamentData({required this.rounds});

  factory TournamentData.fromJson(Map<String, dynamic> json) {
    Map<String, TournamentRound> rounds = {};

    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        rounds[key] = TournamentRound.fromJson(value);
      }
    });

    return TournamentData(rounds: rounds);
  }
}

class TournamentRound {
  final int roundNumber;
  final String roundName;
  final List<MyMatch> matches;

  TournamentRound({
    required this.roundNumber,
    required this.roundName,
    required this.matches,
  });

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      roundNumber: json['round_number'] ?? 0,
      roundName: json['round_name'] ?? '',
      matches:
          (json['matches'] as List?)
              ?.map((match) => MyMatch.fromJson(match))
              .toList() ??
          [],
    );
  }
}

class MyMatch {
  final int id;
  final int tournamentId;
  final int roundNumber;
  final String roundName;
  final int matchNumber;
  final String matchType;
  final int team1Id;
  final int team2Id;
  final int? winnerTeamId;
  final bool isBye;
  final String? team1Score;
  final String? team2Score;
  final String? matchDate;
  final String status;
  final bool team1NoShow;
  final bool team2NoShow;
  final String createdAt;
  final String updatedAt;
  final Team team1;
  final Team team2;

  MyMatch({
    required this.id,
    required this.tournamentId,
    required this.roundNumber,
    required this.roundName,
    required this.matchNumber,
    required this.matchType,
    required this.team1Id,
    required this.team2Id,
    this.winnerTeamId,
    required this.isBye,
    this.team1Score,
    this.team2Score,
    this.matchDate,
    required this.status,
    required this.team1NoShow,
    required this.team2NoShow,
    required this.createdAt,
    required this.updatedAt,
    required this.team1,
    required this.team2,
  });

  factory MyMatch.fromJson(Map<String, dynamic> json) {
    return MyMatch(
      id: json['id'] ?? 0,
      tournamentId: json['tournament_id'] ?? 0,
      roundNumber: json['round_number'] ?? 0,
      roundName: json['round_name'] ?? '',
      matchType: json['match_type'] ?? '',
      matchNumber: json['match_number'] ?? 0,
      team1Id: json['team1_id'] ?? 0,
      team2Id: json['team2_id'] ?? 0,
      winnerTeamId: json['winner_team_id'],
      isBye: json['is_bye'] ?? false,
      team1Score: json['team1_score'],
      team2Score: json['team2_score'],
      matchDate: json['match_date'],
      status: json['status'] ?? 'Scheduled',
      team1NoShow: json['team1_no_show'] ?? false,
      team2NoShow: json['team2_no_show'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      team1: Team.fromJson(json['team1'] ?? {}),
      team2: Team.fromJson(json['team2'] ?? {}),
    );
  }

  bool get isCompleted => status == 'Completed' || status == 'No Show';
  bool get isScheduled => matchDate != null && matchDate!.isNotEmpty;
  Team? get winnerTeam {
    if (winnerTeamId == null) return null;
    return winnerTeamId == team1Id ? team1 : team2;
  }
}

class Team {
  final int id;
  final String name;

  Team({required this.id, required this.name});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class ScheduleMatchRequest {
  final String matchDate;

  ScheduleMatchRequest({required this.matchDate});

  Map<String, dynamic> toJson() {
    return {'match_date': matchDate};
  }
}

class UpdateScoreRequest {
  final int? winnerTeamId;
  final int? team1Score;
  final int? team2Score;
  final String matchStatus;
  final bool? team1NoShow;
  final bool? team2NoShow;

  UpdateScoreRequest({
    this.winnerTeamId,
    this.team1Score,
    this.team2Score,
    required this.matchStatus,
    this.team1NoShow,
    this.team2NoShow,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {'match_status': matchStatus};

    if (winnerTeamId != null) data['winner_team_id'] = winnerTeamId;
    if (team1Score != null) data['team1_score'] = team1Score;
    if (team2Score != null) data['team2_score'] = team2Score;
    if (team1NoShow != null) data['team1_no_show'] = team1NoShow;
    if (team2NoShow != null) data['team2_no_show'] = team2NoShow;

    return data;
  }
}
