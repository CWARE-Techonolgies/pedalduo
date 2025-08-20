
// Player Model
class AllPlayersModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String registeredAt;
  final int totalTournaments;

  AllPlayersModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.registeredAt,
    required this.totalTournaments,
  });

  factory AllPlayersModel.fromJson(Map<String, dynamic> json) {
    return AllPlayersModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      registeredAt: json['registeredAt'],
      totalTournaments: json['totalTournaments'],
    );
  }
}


// Player Model
class TeamAddPlayersModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String createdAt;
  final List<dynamic> organizedTournaments;

  TeamAddPlayersModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.organizedTournaments,
  });

  int get totalTournaments => organizedTournaments.length;

  factory TeamAddPlayersModel.fromJson(Map<String, dynamic> json) {
    return TeamAddPlayersModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'],
      organizedTournaments: json['organized_tournaments'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
      'organized_tournaments': organizedTournaments,
    };
  }
}