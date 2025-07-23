class MyMatchesModel {
  final int id;
  final int tournamentId;
  final int roundNumber;
  final String roundName;
  final int matchNumber;
  final int team1Id;
  final int team2Id;
  final int? winnerTeamId;
  final bool isBye;
  final String? team1Score;
  final String? team2Score;
  final DateTime? matchDate;
  final String status;
  final bool team1NoShow;
  final bool team2NoShow;
  final Team team1;
  final Team team2;
  final Tournament tournament;

  MyMatchesModel({
    required this.id,
    required this.tournamentId,
    required this.roundNumber,
    required this.roundName,
    required this.matchNumber,
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
    required this.team1,
    required this.team2,
    required this.tournament,
  });

  factory MyMatchesModel.fromJson(Map<String, dynamic> json) {
    return MyMatchesModel(
      id: json['id'],
      tournamentId: json['tournament_id'],
      roundNumber: json['round_number'],
      roundName: json['round_name'],
      matchNumber: json['match_number'],
      team1Id: json['team1_id'],
      team2Id: json['team2_id'],
      winnerTeamId: json['winner_team_id'],
      isBye: json['is_bye'],
      team1Score: json['team1_score'],
      team2Score: json['team2_score'],
      matchDate: json['match_date'] != null ? DateTime.parse(json['match_date']) : null,
      status: json['status'],
      team1NoShow: json['team1_no_show'],
      team2NoShow: json['team2_no_show'],
      team1: Team.fromJson(json['team1']),
      team2: Team.fromJson(json['team2']),
      tournament: Tournament.fromJson(json['tournament']),
    );
  }
}

class Team {
  final int id;
  final String name;
  final int tournamentId;
  final int captainId;
  final int totalPlayers;
  final bool isPaymentComplete;
  final String totalAmountPaid;
  final bool isEliminated;
  final int matchesPlayed;
  final int matchesWon;
  final int? finalPosition;
  final String? teamAvatar;
  final String totalPerformancePoints;
  final String averagePerformance;

  Team({
    required this.id,
    required this.name,
    required this.tournamentId,
    required this.captainId,
    required this.totalPlayers,
    required this.isPaymentComplete,
    required this.totalAmountPaid,
    required this.isEliminated,
    required this.matchesPlayed,
    required this.matchesWon,
    this.finalPosition,
    this.teamAvatar,
    required this.totalPerformancePoints,
    required this.averagePerformance,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      tournamentId: json['tournament_id'],
      captainId: json['captain_id'],
      totalPlayers: json['total_players'],
      isPaymentComplete: json['is_payment_complete'],
      totalAmountPaid: json['total_amount_paid'],
      isEliminated: json['is_eliminated'],
      matchesPlayed: json['matches_played'],
      matchesWon: json['matches_won'],
      finalPosition: json['final_position'],
      teamAvatar: json['team_avatar'],
      totalPerformancePoints: json['total_performance_points'],
      averagePerformance: json['average_performance'],
    );
  }
}

class Tournament {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String location;
  final int organizerId;
  final int playersPerTeam;
  final int totalTeams;
  final String packageType;
  final String paymentStatus;
  final int maxTeams;
  final String packageFee;
  final String playerFee;
  final String gender;
  final DateTime registrationEndDate;
  final DateTime tournamentStartDate;
  final DateTime tournamentEndDate;
  final String? rulesAndRegulations;
  final String status;
  final int registeredTeams;
  final int currentRound;
  final int totalRounds;
  final int? winnerTeamId;
  final int? runnerUpTeamId;
  final String totalPrizePool;
  final int approvedBy;

  Tournament({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.location,
    required this.organizerId,
    required this.playersPerTeam,
    required this.totalTeams,
    required this.packageType,
    required this.paymentStatus,
    required this.maxTeams,
    required this.packageFee,
    required this.playerFee,
    required this.gender,
    required this.registrationEndDate,
    required this.tournamentStartDate,
    required this.tournamentEndDate,
    this.rulesAndRegulations,
    required this.status,
    required this.registeredTeams,
    required this.currentRound,
    required this.totalRounds,
    this.winnerTeamId,
    this.runnerUpTeamId,
    required this.totalPrizePool,
    required this.approvedBy,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      location: json['location'],
      organizerId: json['organizer_id'],
      playersPerTeam: json['players_per_team'],
      totalTeams: json['total_teams'],
      packageType: json['package_type'],
      paymentStatus: json['payment_status'],
      maxTeams: json['max_teams'],
      packageFee: json['package_fee'],
      playerFee: json['player_fee'],
      gender: json['gender'],
      registrationEndDate: DateTime.parse(json['registration_end_date']),
      tournamentStartDate: DateTime.parse(json['tournament_start_date']),
      tournamentEndDate: DateTime.parse(json['tournament_end_date']),
      rulesAndRegulations: json['rules_and_regulations'],
      status: json['status'],
      registeredTeams: json['registered_teams'],
      currentRound: json['current_round'],
      totalRounds: json['total_rounds'],
      winnerTeamId: json['winner_team_id'],
      runnerUpTeamId: json['runner_up_team_id'],
      totalPrizePool: json['total_prize_pool'],
      approvedBy: json['approved_by'],
    );
  }
}
