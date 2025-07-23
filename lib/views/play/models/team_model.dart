class TeamModel {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final TournamentModel tournament;

  TeamModel({
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
    required this.createdAt,
    required this.updatedAt,
    required this.tournament,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tournamentId: json['tournament_id'] ?? 0,
      captainId: json['captain_id'] ?? 0,
      totalPlayers: json['total_players'] ?? 0,
      isPaymentComplete: json['is_payment_complete'] ?? false,
      totalAmountPaid: json['total_amount_paid'] ?? '0.00',
      isEliminated: json['is_eliminated'] ?? false,
      matchesPlayed: json['matches_played'] ?? 0,
      matchesWon: json['matches_won'] ?? 0,
      finalPosition: json['final_position'] ?? 0,
      teamAvatar: json['team_avatar'],
      totalPerformancePoints: json['total_performance_points'] ?? '0.00',
      averagePerformance: json['average_performance'] ?? '0.00',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      tournament: TournamentModel.fromJson(json['tournament'] ?? {}),
    );
  }
}
class TournamentModel {
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
  final String rulesAndRegulations;
  final String status;
  final int registeredTeams;
  final int currentRound;
  final int? totalRounds;
  final int? winnerTeamId;
  final int? runnerUpTeamId;
  final String totalPrizePool;
  final int approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TournamentModel({
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
    required this.rulesAndRegulations,
    required this.status,
    required this.registeredTeams,
    required this.currentRound,
    this.totalRounds,
    this.winnerTeamId,
    this.runnerUpTeamId,
    required this.totalPrizePool,
    required this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      location: json['location'] ?? '',
      organizerId: json['organizer_id'] ?? 0,
      playersPerTeam: json['players_per_team'] ?? 0,
      totalTeams: json['total_teams'] ?? 0,
      packageType: json['package_type'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      maxTeams: json['max_teams'] ?? 0,
      packageFee: json['package_fee'] ?? '0.00',
      playerFee: json['player_fee'] ?? '0.00',
      gender: json['gender'] ?? '',
      registrationEndDate: json['registration_end_date'] != null
          ? DateTime.parse(json['registration_end_date'])
          : DateTime.now(),
      tournamentStartDate: json['tournament_start_date'] != null
          ? DateTime.parse(json['tournament_start_date'])
          : DateTime.now(),
      tournamentEndDate: json['tournament_end_date'] != null
          ? DateTime.parse(json['tournament_end_date'])
          : DateTime.now(),
      rulesAndRegulations: json['rules_and_regulations'] ?? '',
      status: json['status'] ?? '',
      registeredTeams: json['registered_teams'] ?? 0,
      currentRound: json['current_round'] ?? 1,
      totalRounds: json['total_rounds'],
      winnerTeamId: json['winner_team_id'],
      runnerUpTeamId: json['runner_up_team_id'],
      totalPrizePool: json['total_prize_pool'] ?? '0.00',
      approvedBy: json['approved_by'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

}

class TeamsResponse {
  final List<TeamModel> captainTeams;
  final List<TeamModel> playerTeams;

  TeamsResponse({
    required this.captainTeams,
    required this.playerTeams,
  });

  factory TeamsResponse.fromJson(Map<String, dynamic> json) {
    return TeamsResponse(
      captainTeams: (json['captain_teams'] as List)
          .map((team) => TeamModel.fromJson(team))
          .toList(),
      playerTeams: (json['player_teams'] as List)
          .map((team) => TeamModel.fromJson(team))
          .toList(),
    );
  }
}