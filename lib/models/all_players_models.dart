
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