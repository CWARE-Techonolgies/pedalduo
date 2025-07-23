class MyTournament {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
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
  final int? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MyTournament({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
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
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyTournament.fromJson(Map<String, dynamic> json) {
    return MyTournament(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
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
      registrationEndDate: DateTime.parse(json['registration_end_date']),
      tournamentStartDate: DateTime.parse(json['tournament_start_date']),
      tournamentEndDate: DateTime.parse(json['tournament_end_date']),
      rulesAndRegulations: json['rules_and_regulations'] ?? '',
      status: json['status'] ?? '',
      registeredTeams: json['registered_teams'] ?? 0,
      currentRound: json['current_round'] ?? 1,
      totalRounds: json['total_rounds'],
      winnerTeamId: json['winner_team_id'],
      runnerUpTeamId: json['runner_up_team_id'],
      totalPrizePool: json['total_prize_pool'] ?? '0.00',
      approvedBy: json['approved_by'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'organizer_id': organizerId,
      'players_per_team': playersPerTeam,
      'total_teams': totalTeams,
      'package_type': packageType,
      'payment_status': paymentStatus,
      'max_teams': maxTeams,
      'package_fee': packageFee,
      'player_fee': playerFee,
      'gender': gender,
      'registration_end_date': registrationEndDate.toIso8601String(),
      'tournament_start_date': tournamentStartDate.toIso8601String(),
      'tournament_end_date': tournamentEndDate.toIso8601String(),
      'rules_and_regulations': rulesAndRegulations,
      'status': status,
      'registered_teams': registeredTeams,
      'current_round': currentRound,
      'total_rounds': totalRounds,
      'winner_team_id': winnerTeamId,
      'runner_up_team_id': runnerUpTeamId,
      'total_prize_pool': totalPrizePool,
      'approved_by': approvedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
