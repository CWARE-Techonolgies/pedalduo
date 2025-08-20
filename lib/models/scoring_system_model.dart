// lib/models/tennis_models.dart

class Team {
  final int id;
  final String name;
  final List<Player> players;

  Team({
    required this.id,
    required this.name,
    required this.players,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Team',
      players: (json['players'] as List?)
          ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'players': players.map((p) => p.toJson()).toList(),
    };
  }
}

class Player {
  final int id;
  final String name;
  final String? imageUrl;

  Player({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Player',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
    };
  }
}

class TennisMatch {
  final int id;
  final int tournamentId;
  final String roundName;
  final int matchNumber;
  final String matchType;
  final Team team1;
  final Team team2;
  final String status;

  TennisMatch({
    required this.id,
    required this.tournamentId,
    required this.roundName,
    required this.matchNumber,
    required this.matchType,
    required this.team1,
    required this.team2,
    required this.status,
  });

  factory TennisMatch.fromJson(Map<String, dynamic> json) {
    return TennisMatch(
      id: json['id'] ?? 0,
      tournamentId: json['tournament_id'] ?? 0,
      roundName: json['round_name'] ?? 'Round ${json['round_number'] ?? 1}',
      matchNumber: json['match_number'] ?? 1,
      matchType: json['match_type'] ?? 'one_set_9',
      team1: Team.fromJson(json['team1'] ?? {}),
      team2: Team.fromJson(json['team2'] ?? {}),
      status: json['status'] ?? 'Ongoing',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'round_name': roundName,
      'match_number': matchNumber,
      'match_type': matchType,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'status': status,
    };
  }
}

class TennisScore {
  final CurrentGame currentGame;
  final Games games;
  final Sets sets;
  final List<SetHistory> setsHistory;
  final bool inTiebreak;
  final int tiebreakTarget;

  TennisScore({
    required this.currentGame,
    required this.games,
    required this.sets,
    required this.setsHistory,
    required this.inTiebreak,
    required this.tiebreakTarget,
  });

  factory TennisScore.fromJson(Map<String, dynamic> json) {
    return TennisScore(
      currentGame: CurrentGame.fromJson(json['current_game'] ?? {}),
      games: Games.fromJson(json['games'] ?? {}),
      sets: Sets.fromJson(json['sets'] ?? {}),
      setsHistory: (json['sets_history'] as List?)
          ?.map((s) => SetHistory.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      inTiebreak: json['in_tiebreak'] ?? false,
      tiebreakTarget: json['tiebreak_target'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_game': currentGame.toJson(),
      'games': games.toJson(),
      'sets': sets.toJson(),
      'sets_history': setsHistory.map((s) => s.toJson()).toList(),
      'in_tiebreak': inTiebreak,
      'tiebreak_target': tiebreakTarget,
    };
  }
}

class CurrentGame {
  final String team1Points;
  final String team2Points;
  final int team1ActualPoints;
  final int team2ActualPoints;
  final bool isDeuce;
  final bool isGoldenPoint;
  final bool inTiebreak;
  final String servingTeam;

  CurrentGame({
    required this.team1Points,
    required this.team2Points,
    required this.team1ActualPoints,
    required this.team2ActualPoints,
    required this.isDeuce,
    required this.isGoldenPoint,
    required this.inTiebreak,
    required this.servingTeam,
  });

  factory CurrentGame.fromJson(Map<String, dynamic> json) {
    return CurrentGame(
      team1Points: json['team1_points'] ?? 'love',
      team2Points: json['team2_points'] ?? 'love',
      team1ActualPoints: json['team1_actual_points'] ?? 0,
      team2ActualPoints: json['team2_actual_points'] ?? 0,
      isDeuce: json['is_deuce'] ?? false,
      isGoldenPoint: json['is_golden_point'] ?? false,
      inTiebreak: json['in_tiebreak'] ?? false,
      servingTeam: json['serving_team'] ?? 'team1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team1_points': team1Points,
      'team2_points': team2Points,
      'team1_actual_points': team1ActualPoints,
      'team2_actual_points': team2ActualPoints,
      'is_deuce': isDeuce,
      'is_golden_point': isGoldenPoint,
      'in_tiebreak': inTiebreak,
      'serving_team': servingTeam,
    };
  }
}

class Games {
  final int team1;
  final int team2;

  Games({required this.team1, required this.team2});

  factory Games.fromJson(Map<String, dynamic> json) {
    return Games(
      team1: json['team1'] ?? 0,
      team2: json['team2'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team1': team1,
      'team2': team2,
    };
  }
}

class Sets {
  final int team1;
  final int team2;

  Sets({required this.team1, required this.team2});

  factory Sets.fromJson(Map<String, dynamic> json) {
    return Sets(
      team1: json['team1'] ?? 0,
      team2: json['team2'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team1': team1,
      'team2': team2,
    };
  }
}

class SetHistory {
  final int setNumber;
  final int team1Games;
  final int team2Games;
  final String winner;
  final TiebreakScore? tiebreak;

  SetHistory({
    required this.setNumber,
    required this.team1Games,
    required this.team2Games,
    required this.winner,
    this.tiebreak,
  });

  factory SetHistory.fromJson(Map<String, dynamic> json) {
    return SetHistory(
      setNumber: json['set_number'] ?? 1,
      team1Games: json['team1_games'] ?? 0,
      team2Games: json['team2_games'] ?? 0,
      winner: json['winner'] ?? '',
      tiebreak: json['tiebreak'] != null
          ? TiebreakScore.fromJson(json['tiebreak'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'team1_games': team1Games,
      'team2_games': team2Games,
      'winner': winner,
      'tiebreak': tiebreak?.toJson(),
    };
  }
}

class TiebreakScore {
  final int team1;
  final int team2;
  final String winner;

  TiebreakScore({
    required this.team1,
    required this.team2,
    required this.winner,
  });

  factory TiebreakScore.fromJson(Map<String, dynamic> json) {
    return TiebreakScore(
      team1: json['team1'] ?? 0,
      team2: json['team2'] ?? 0,
      winner: json['winner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team1': team1,
      'team2': team2,
      'winner': winner,
    };
  }
}