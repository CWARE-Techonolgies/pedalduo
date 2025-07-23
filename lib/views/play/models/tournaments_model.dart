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
  final int? totalRounds;
  final int? winnerTeamId;
  final int? runnerUpTeamId;
  final String totalPrizePool;
  final int? approvedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Organizer organizer;
  final List<dynamic> teams;
  final List<dynamic> payments;

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
    this.totalRounds,
    this.winnerTeamId,
    this.runnerUpTeamId,
    required this.totalPrizePool,
    this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.organizer,
    required this.teams,
    required this.payments,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
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
      packageFee: json['package_fee'] ?? '',
      playerFee: json['player_fee'] ?? '',
      gender: json['gender'] ?? '',
      registrationEndDate: DateTime.tryParse(json['registration_end_date'] ?? '') ?? DateTime.now(),
      tournamentStartDate: DateTime.tryParse(json['tournament_start_date'] ?? '') ?? DateTime.now(),
      tournamentEndDate: DateTime.tryParse(json['tournament_end_date'] ?? '') ?? DateTime.now(),
      rulesAndRegulations: json['rules_and_regulations'],
      status: json['status'] ?? '',
      registeredTeams: json['registered_teams'] ?? 0,
      currentRound: json['current_round'] ?? 0,
      totalRounds: json['total_rounds'],
      winnerTeamId: json['winner_team_id'],
      runnerUpTeamId: json['runner_up_team_id'],
      totalPrizePool: json['total_prize_pool'] ?? '0.00',
      approvedBy: json['approved_by'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      organizer: json['organizer'] != null
          ? Organizer.fromJson(json['organizer'])
          : Organizer(id: 0, name: '', phone: ''),
      teams: json['teams'] ?? [],
      payments: json['payments'] ?? [],
    );
  }
}

class Organizer {
  final int id;
  final String name;
  final String phone;

  Organizer({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}